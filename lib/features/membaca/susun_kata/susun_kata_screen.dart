import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/layout/moci_stage.dart';
import '../../../app/routes.dart';
import '../../../app/theme/menu_theme.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_metrics.dart';
import '../../../app/theme/moci_text.dart';
import '../../../core/audio/audio_providers.dart';
import '../../../core/audio/narrator.dart';
import '../../../core/audio/sfx.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/content/katalog.dart';
import '../../../core/lang.dart';
import '../../../core/prefs/prefs_controller.dart';
import '../../../core/progress/progress_controller.dart';
import '../../../core/providers.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/game/game_glyphs.dart';
import '../../../widgets/game/progress_dots.dart';
import '../../../widgets/moci_illustration.dart';
import '../../../widgets/moci_mascot.dart';
import '../../../widgets/pressable.dart';
import '../../hadiah/hadiah_controller.dart';
import '../membaca_providers.dart';
import '../susun_kata/susun_kata_game.dart';
import '../susun_kata/susun_tile.dart';
import '../widgets/membaca_pill.dart';
import '../widgets/membaca_top_bar.dart';

const _accent = Color(0xFFE0661A);
const _accentShadow = Color(0xFFA9480D);
const _putih = MociColors.white;
const _tintaSoft = MociColors.inkSoft;
const _hijau = MociColors.correct;
const _hijauShadow = MociColors.correctShadow;

class SusunKataScreen extends ConsumerStatefulWidget {
  const SusunKataScreen({super.key, this.awal});

  /// Level dari `?level=`; selain 2/3 diabaikan.
  final String? awal;

  static ValueKey<int> levelKey(int level) => ValueKey(100 + level);
  static ValueKey<int> tileKey(int i) => ValueKey(200 + i);
  static ValueKey<int> slotKey(int i) => ValueKey(300 + i);
  static const hearKey = ValueKey<String>('susun-kata-hear');
  static const nextKey = ValueKey<String>('susun-kata-next');

  @override
  ConsumerState<SusunKataScreen> createState() => _SusunKataScreenState();
}

class _SusunKataScreenState extends ConsumerState<SusunKataScreen> {
  late final Katalog _katalog;
  late final Narrator _narrator;
  late SusunKataGame _game;
  bool _benar = false;
  bool _salah = false;
  bool _selesai = false;

  /// Penghitung timer pengosongan: ronde, level, bahasa, atau tutup layar
  /// membatalkan timer yang masih jalan.
  int _timerGen = 0;

  /// Ronde baru memasang ulang keping, jadi jeda ketuk 400 ms milik keping
  /// lama tidak ikut terbawa ke ronde berikutnya.
  int _rondeGen = 0;

  late final Set<String> _kisi;

  @override
  void initState() {
    super.initState();
    _katalog = ref.read(katalogProvider);
    _narrator = ref.read(narratorProvider);
    _kisi = _katalog.sukuKata.semua.toSet();
    final diminta = int.tryParse(widget.awal ?? '');
    final level = levelTersedia.contains(diminta) ? diminta! : 2;
    _game = SusunKataGame(
      kata: _kataUntuk(ref.read(prefsProvider).lang),
      random: ref.read(membacaRandomProvider),
      level: level,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catat();
      _bacaAwal();
    });
  }

  @override
  void dispose() {
    _timerGen++;
    _narrator.stop();
    super.dispose();
  }

  List<KataEntry> _kataUntuk(AppLang lang) {
    final kata = _katalog.kata;
    return lang == AppLang.en ? kata.en : kata.id;
  }

  void _catat() {
    ref.read(progressProvider.notifier).setLastActivity(Routes.susunKata, {
      'level': '${_game.level}',
    });
  }

  Future<void> _baca(List<NarrationLine> baris) {
    final narrator = ref.read(narratorProvider);
    return narrator.sayAll(baris, ref.read(prefsProvider).lang);
  }

  NarrationLine _kataLine([KataEntry? entry]) {
    final e = entry ?? _game.ronde.entry;
    return NarrationLine(jenis: 'kata', id: e.item, text: e.kata);
  }

  NarrationLine _sukuLine(String suku) =>
      NarrationLine(jenis: 'suku', id: suku, text: suku);

  NarrationLine _uiLine(String id, String text) =>
      NarrationLine(jenis: 'ui', id: id, text: text);

  void _bacaAwal() {
    final l10n = context.l10n;
    _baca([_uiLine('susunKataIns', l10n.susunKataIns), _kataLine()]);
  }

  void _ketukTile(int i) {
    if (_selesai) return;
    final suku = _game.ronde.tiles[i];
    final hasil = _game.ketuk(i);
    switch (hasil) {
      case SusunKetuk.dipakai || SusunKetuk.penuh:
        return;
      case SusunKetuk.mengisi:
        setState(() {
          _salah = false;
          _benar = false;
        });
        _baca([_sukuLine(suku)]);
      case SusunKetuk.benar:
        final entry = _game.ronde.entry;
        setState(() {
          _benar = true;
          _salah = false;
        });
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        _baca([
          _uiLine('susunKataYes', context.l10n.susunKataYes),
          for (final s in entry.suku) _sukuLine(s),
          _kataLine(entry),
        ]);
        for (final s in entry.suku) {
          if (_kisi.contains(s)) {
            ref
                .read(progressProvider.notifier)
                .markItem('membaca', 'dibaca', s);
          }
        }
      case SusunKetuk.salah:
        final l10n = context.l10n;
        setState(() => _salah = true);
        ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
        _baca([_uiLine('susunKataTryAgain', l10n.susunKataTryAgain)]);
        _jadwalkanKosong();
    }
  }

  void _jadwalkanKosong() {
    final gen = ++_timerGen;
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted || gen != _timerGen) return;
      setState(() {
        _game.kosongkan();
        _salah = false;
      });
    });
  }

  void _lanjut() {
    if (_selesai || !_game.ronde.benar) return;
    if (_game.nomor >= rondePerLevel) {
      _selesai = true;
      _hadiah();
      return;
    }
    _timerGen++;
    setState(() {
      _rondeGen++;
      _game.berikutnya();
      _benar = false;
      _salah = false;
    });
    _baca([_kataLine()]);
  }

  Future<void> _hadiah() async {
    final bahasa = ref.read(prefsProvider).lang.name;
    final level = _game.level;
    final award = await ref
        .read(hadiahProvider)
        .finishGame(
          gameId: 'membaca/susun-kata',
          roundId:
              '$bahasa-$level-'
              '${ref.read(clockProvider).now().microsecondsSinceEpoch}',
        );
    if (!mounted) return;
    context.push(
      Routes.hebat,
      extra: HebatArgs(
        award: award,
        replayRoute: '${Routes.susunKata}?level=$level',
      ),
    );
  }

  void _gantiLevel(int level) {
    if (_selesai || level == _game.level) return;
    _timerGen++;
    setState(() {
      _rondeGen++;
      _game.gantiLevel(level);
      _benar = false;
      _salah = false;
    });
    _catat();
    _baca([_kataLine()]);
  }

  void _gantiBahasa(AppLang lang) {
    _timerGen++;
    setState(() {
      _rondeGen++;
      _game = SusunKataGame(
        kata: _kataUntuk(lang),
        random: ref.read(membacaRandomProvider),
        level: _game.level,
      );
      _benar = false;
      _salah = false;
      _selesai = false;
    });
    _catat();
    _baca([_kataLine()]);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(prefsProvider.select((p) => p.lang), (prev, next) {
      if (prev == next) return;
      _gantiBahasa(next);
    });
    final l10n = context.l10n;
    return MociStage(
      theme: MenuTheme.membaca,
      tablet: (context) => _panggung(l10n),
    );
  }

  Widget _panggung(AppLocalizations l10n) {
    return Stack(
      children: [
        Positioned(left: 0, right: 0, top: 0, child: const MembacaTopBar()),
        Positioned(left: 70, top: 120, child: _pilihLevel(l10n)),
        Positioned(
          right: 70,
          top: 136,
          child: ProgressDots(
            count: rondePerLevel,
            current: _game.nomor - 1,
            semanticLabel: l10n.susunKataProgress,
            activeColor: _accent,
          ),
        ),
        Positioned(
          left: 70,
          top: 186,
          width: 1040,
          height: 400,
          child: _kartu(l10n),
        ),
        Positioned(left: 0, right: 0, top: 628, child: _keping()),
        const Positioned(left: 20, top: 690, child: MociMascot(size: 120)),
      ],
    );
  }

  Widget _pilihLevel(AppLocalizations l10n) {
    return Semantics(
      container: true,
      label: l10n.susunKataLevel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final level in levelTersedia) ...[
            if (level != levelTersedia.first) const SizedBox(width: 10),
            MembacaPill(
              key: SusunKataScreen.levelKey(level),
              label: level == 2 ? l10n.susunKataLevel2 : l10n.susunKataLevel3,
              selected: _game.level == level,
              onTap: () => _gantiLevel(level),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kartu(AppLocalizations l10n) {
    final entry = _game.ronde.entry;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _putih,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF7C9A5),
            offset: const Offset(0, 14),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 40,
            top: 30,
            width: 290,
            height: 290,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 60,
            top: 40,
            child: MociIllustration(
              entry.item,
              size: 250,
              semanticLabel: entry.kata,
            ),
          ),
          Positioned(
            left: 145,
            top: 300,
            child: MociPressable(
              key: SusunKataScreen.hearKey,
              onTap: () => _baca([_kataLine()]),
              color: const Color(0xFFFFB020),
              shadowColor: const Color(0xFFE0870B),
              depth: 7,
              borderRadius: BorderRadius.circular(39),
              semanticLabel: l10n.susunKataHear,
              clickSound: false,
              minTouch: MociSize.minTouchTablet,
              child: const SizedBox(
                width: 78,
                height: 78,
                child: Center(child: GameGlyph(GameGlyphKind.listen, size: 40)),
              ),
            ),
          ),
          Positioned(
            left: 380,
            top: 34,
            width: 620,
            child: Text(
              l10n.susunKataIns,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MociText.label.copyWith(fontSize: 20, color: _tintaSoft),
            ),
          ),
          Positioned(left: 380, top: 76, child: _barisKotak(l10n)),
          Positioned(
            left: 380,
            top: 258,
            width: 620,
            height: 120,
            child: _status(l10n),
          ),
        ],
      ),
    );
  }

  Widget _barisKotak(AppLocalizations l10n) {
    final ronde = _game.ronde;
    final dua = ronde.slots.length == 2;
    final lebar = dua ? 250.0 : 190.0;
    final fontSize = dua ? 76.0 : 60.0;
    return Row(
      children: [
        for (var i = 0; i < ronde.slots.length; i++) ...[
          if (i > 0) const SizedBox(width: 18),
          _kotak(i, ronde, lebar, fontSize, l10n),
        ],
      ],
    );
  }

  Widget _kotak(
    int i,
    SusunRonde ronde,
    double lebar,
    double fontSize,
    AppLocalizations l10n,
  ) {
    final idx = ronde.slots[i];
    final label =
        '${l10n.susunKataSlot(i + 1)}: '
        '${idx == null ? l10n.susunKataEmpty : ronde.tiles[idx]}';
    final Widget isi;
    if (idx == null) {
      isi = CustomPaint(
        painter: const _DashedBorderPainter(),
        child: Container(
          width: lebar,
          height: 150,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F2),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Text(
            '?',
            style: TextStyle(
              fontFamily: MociFonts.fredoka,
              fontWeight: FontWeight.w700,
              fontSize: 60,
              color: Color(0xFFF7C9A5),
            ),
          ),
        ),
      );
    } else {
      final color = _benar ? _hijau : susunTileColor(idx);
      final shadow = _benar ? _hijauShadow : susunTileShadow(idx);
      final kotak = Container(
        width: lebar,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _putih, width: 6),
          boxShadow: [
            BoxShadow(color: shadow, offset: const Offset(0, 8), blurRadius: 0),
          ],
        ),
        child: Text(
          ronde.tiles[idx],
          style: MociText.title.copyWith(
            fontSize: fontSize,
            color: _putih,
            letterSpacing: 2,
          ),
        ),
      );
      // Kotak terisi bisa diketuk untuk mengeluarkan kepingnya, kecuali saat
      // kata sudah benar.
      isi = _benar
          ? kotak
          : MociPressable(
              onTap: () {
                setState(() {
                  ronde.slots[i] = null;
                  _salah = false;
                });
              },
              color: color,
              shadowColor: shadow,
              depth: 8,
              borderRadius: BorderRadius.circular(32),
              clickSound: false,
              child: SizedBox(
                width: lebar,
                height: 150,
                child: Center(
                  child: Text(
                    ronde.tiles[idx],
                    style: MociText.title.copyWith(
                      fontSize: fontSize,
                      color: _putih,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            );
    }
    return Semantics(
      label: label,
      child: SizedBox(
        key: SusunKataScreen.slotKey(i),
        width: lebar,
        height: 150,
        child: isi,
      ),
    );
  }

  Widget _status(AppLocalizations l10n) {
    if (_benar) {
      final kata = _game.ronde.entry.kata.toUpperCase();
      final fs = kata.length > 8 ? 54.0 : 76.0;
      return Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                kata,
                maxLines: 1,
                style: MociText.title.copyWith(
                  fontSize: fs,
                  color: _accent,
                  letterSpacing: 5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          MociPressable(
            key: SusunKataScreen.nextKey,
            onTap: _lanjut,
            color: _accent,
            shadowColor: _accentShadow,
            depth: 7,
            borderRadius: BorderRadius.circular(999),
            semanticLabel: l10n.susunKataNext,
            minTouch: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.susunKataNext,
                      style: MociText.button.copyWith(
                        fontSize: 26,
                        color: _putih,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const GameGlyph(
                      GameGlyphKind.next,
                      size: 28,
                      color: _putih,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    final hint = _salah
        ? l10n.susunKataTryAgain
        : _game.ronde.terisi > 0
        ? l10n.susunKataHintMore
        : l10n.susunKataHintStart;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        hint,
        style: MociText.label.copyWith(
          fontSize: 22,
          color: _tintaSoft,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _keping() {
    final ronde = _game.ronde;
    return KeyedSubtree(
      key: ValueKey(_rondeGen),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < ronde.tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 20),
            SusunTile(
              key: SusunKataScreen.tileKey(i),
              index: i,
              suku: ronde.tiles[i],
              used: ronde.slots.contains(i),
              onTap: () => _ketukTile(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF7C9A5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(32),
    );
    final path = Path()..addRRect(rrect);
    const dash = 18.0;
    const gap = 12.0;
    for (final metric in path.computeMetrics()) {
      var start = 0.0;
      while (start < metric.length) {
        final end = (start + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        start = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => false;
}
