import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/audio/sfx.dart';
import '../../core/content/content_repository.dart';
import '../../core/content/katalog.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/answer_card.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/game_mode_pill.dart';
import '../../widgets/game/progress_dots.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import 'buah_game.dart';

enum BuahMode { kenali, tebak }

/// Sumber acak soal; dites lewat override supaya urutan kartu tetap.
final buahRandomProvider = Provider<Random>((_) => Random());

/// Buah & Sayur: Kenali 35 kartu bergambar dan Tebak tiga pilihan yang
/// berputar tanpa akhir.
class BuahScreen extends ConsumerStatefulWidget {
  const BuahScreen({super.key, this.mode = BuahMode.tebak, this.awal});

  static ValueKey<int> questionKey(int nomor) => ValueKey<int>(nomor);
  static const nextKey = ValueKey<String>('buah-next');

  static ValueKey<String> optionKey(String id) => ValueKey('buah-option-$id');

  static ValueKey<String> cardKey(String id) => ValueKey('buah-card-$id');

  static ValueKey<String> categoryKey(String kategori) =>
      ValueKey('buah-category-$kategori');

  final BuahMode mode;

  /// Buah pertama saat layar dibuka; nilai di luar katalog diabaikan.
  final String? awal;

  @override
  ConsumerState<BuahScreen> createState() => _BuahScreenState();
}

class _BuahScreenState extends ConsumerState<BuahScreen> {
  static const _accent = Color(0xFFE64980);
  static const _accentShadow = Color(0xFFB3235E);
  static const _fruitTag = Color(0xFFE64980);
  static const _veggieTag = Color(0xFF2F9E44);

  late BuahMode _mode;
  String _kategori = 'semua';
  late BuahSoal _soal;
  int _qn = 1;
  String? _salahId;
  bool _benar = false;

  Katalog get _katalog => ref.read(katalogProvider);

  Random get _random => ref.read(buahRandomProvider);

  AppLang get _lang => ref.read(prefsProvider).lang;

  String? get _kategoriSoal => _kategori == 'semua' ? null : _kategori;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    _soal = buatBuahSoal(_katalog, target: widget.awal, random: _random);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_mode == BuahMode.tebak) {
        _tanya();
      } else {
        _catat(_soal.target.id);
      }
    });
  }

  void _catat(String id) => ref.read(progressProvider.notifier).setLastActivity(
    Routes.buahSayur,
    {'buah': id, 'mode': _mode.name},
  );

  void _say(List<NarrationLine> lines) =>
      ref.read(narratorProvider).sayAll(lines, _lang);

  /// Pertanyaan dibacakan sebagai pengantar lalu nama target.
  void _tanya() {
    _catat(_soal.target.id);
    _say([
      NarrationLine(
        jenis: 'ui',
        id: 'buahQuestionSay',
        text: context.l10n.buahQuestionSay,
      ),
      NarrationLine(
        jenis: 'nama',
        id: _soal.target.id,
        text: namaBuah(_soal.target, _lang),
      ),
    ]);
  }

  void _lanjut() {
    setState(() {
      _qn = _qn % buahRonde + 1;
      _soal = buatBuahSoal(
        _katalog,
        kategori: _kategoriSoal,
        hindari: _soal.target.id,
        random: _random,
      );
      _benar = false;
      _salahId = null;
    });
    _tanya();
  }

  void _pilihMode(BuahMode m) {
    if (m == _mode) return;
    setState(() {
      _mode = m;
      _qn = 1;
      _benar = false;
      _salahId = null;
      if (m == BuahMode.tebak) {
        _soal = buatBuahSoal(
          _katalog,
          kategori: _kategoriSoal,
          target: _soal.target.id,
          random: _random,
        );
      }
    });
    if (m == BuahMode.tebak) {
      _tanya();
    } else {
      _catat(_soal.target.id);
    }
  }

  void _pilihKategori(String kategori) {
    if (kategori == _kategori) return;
    setState(() {
      _kategori = kategori;
      _qn = 1;
      _benar = false;
      _salahId = null;
      _soal = buatBuahSoal(_katalog, kategori: _kategoriSoal, random: _random);
    });
    if (_mode == BuahMode.tebak) {
      _tanya();
    } else {
      _catat(_soal.target.id);
    }
  }

  void _jawab(Item pilih) {
    if (_benar) return;
    if (jawabanBuah(_soal.target, pilih)) {
      setState(() {
        _benar = true;
        _salahId = null;
      });
      ref.read(audioServiceProvider).playSfx(Sfx.benar);
      _say([
        NarrationLine(
          jenis: 'ui',
          id: 'buahYesSay',
          text: context.l10n.buahYesSay,
        ),
        NarrationLine(
          jenis: 'nama',
          id: _soal.target.id,
          text: namaBuah(_soal.target, _lang),
        ),
      ]);
      ref
          .read(progressProvider.notifier)
          .markItem('buahSayur', 'ditebak', _soal.target.id);
      _catat(_soal.target.id);
      return;
    }
    setState(() => _salahId = pilih.id);
    ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
    _say([
      NarrationLine(jenis: 'nama', id: pilih.id, text: namaBuah(pilih, _lang)),
      NarrationLine(
        jenis: 'ui',
        id: 'buahWrongSay',
        text: context.l10n.buahWrongSay,
      ),
    ]);
  }

  void _pilihKartu(Item item) {
    ref
        .read(progressProvider.notifier)
        .markItem('buahSayur', 'dilihat', item.id);
    _catat(item.id);
    _say([
      NarrationLine(jenis: 'nama', id: item.id, text: namaBuah(item, _lang)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsProvider.select((p) => p.lang));
    ref.watch(katalogProvider);
    return MociStage(theme: MenuTheme.buahSayur, tablet: _tablet);
  }

  Widget _tablet(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MociTopBar(
            leading: const MociBackButton(),
            title: l10n.menuBuahTitle,
            trailing: [
              GameModePill(
                tabs: [
                  GameModeTab(label: l10n.buahLearn),
                  GameModeTab(label: l10n.buahGuess),
                ],
                selected: _mode.index,
                onSelected: (i) => _pilihMode(BuahMode.values[i]),
                semanticLabel: l10n.modeSemantic,
                accent: _accent,
              ),
              _categoryPill(l10n),
            ],
          ),
        ),
        if (_mode == BuahMode.tebak) ..._tebak(l10n) else _kenali(l10n),
      ],
    );
  }

  List<Widget> _tebak(AppLocalizations l10n) {
    final nama = namaBuah(_soal.target, _lang);
    return [
      Positioned(
        left: 110,
        top: 118,
        child: const MociMascot(size: 168, idle: false),
      ),
      Positioned(left: 294, top: 134, child: _question(l10n, nama)),
      Positioned(
        left: 270,
        top: 178,
        child: SizedBox(
          width: 30,
          height: 30,
          child: CustomPaint(painter: const _Tail()),
        ),
      ),
      Positioned(
        left: 976,
        top: 166,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: MociColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0xFFF5BCD3), offset: Offset(0, 5)),
            ],
          ),
          child: Center(
            child: ProgressDots(
              count: buahRonde,
              current: _qn - 1,
              semanticLabel: l10n.buahProgress(_qn, buahRonde),
              activeColor: _accent,
            ),
          ),
        ),
      ),
      Positioned(left: 90, top: 296, child: _options()),
      if (_benar) Positioned(left: 290, top: 690, child: _finished(l10n, nama)),
    ];
  }

  Widget _question(AppLocalizations l10n, String nama) {
    final kalimat = l10n.buahQuestion(nama);
    final i = kalimat.indexOf(nama);
    final pre = i < 0 ? kalimat : kalimat.substring(0, i);
    final post = i < 0 ? '' : kalimat.substring(i + nama.length);
    final size = ukuranSoalBuah(nama);
    return Container(
      key: BuahScreen.questionKey(_qn),
      width: 660,
      height: 112,
      padding: const EdgeInsets.fromLTRB(32, 0, 20, 0),
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Color(0x1A2B2350), offset: Offset(0, 9)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pre,
                    style: TextStyle(
                      fontFamily: MociFonts.fredoka,
                      fontWeight: FontWeight.w700,
                      fontSize: size,
                      color: MociColors.ink,
                    ),
                  ),
                  Text(
                    nama.toUpperCase(),
                    style: TextStyle(
                      fontFamily: MociFonts.fredoka,
                      fontWeight: FontWeight.w700,
                      fontSize: size,
                      color: MociColors.wrong,
                    ),
                  ),
                  Text(
                    post,
                    style: TextStyle(
                      fontFamily: MociFonts.fredoka,
                      fontWeight: FontWeight.w700,
                      fontSize: size,
                      color: MociColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          MociPressable(
            onTap: _tanya,
            color: const Color(0xFFFFB020),
            shadowColor: const Color(0xFFE0870B),
            depth: 6,
            borderRadius: const BorderRadius.all(Radius.circular(38)),
            semanticLabel: l10n.buahListen,
            child: const SizedBox(
              width: 72,
              height: 72,
              child: Center(child: GameGlyph(GameGlyphKind.listen, size: 38)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _options() {
    return Row(
      children: [
        for (var i = 0; i < _soal.pilihan.length; i++) ...[
          if (i > 0) const SizedBox(width: 40),
          Builder(
            builder: (context) {
              final item = _soal.pilihan[i];
              final state = _benar && item.id == _soal.target.id
                  ? AnswerCardState.correct
                  : item.id == _salahId
                  ? AnswerCardState.wrong
                  : AnswerCardState.idle;
              return AnswerCard(
                key: BuahScreen.optionKey(item.id),
                semanticLabel: namaBuah(item, _lang),
                illustration: item.id,
                state: state,
                accent: const Color(0xFFF5BCD3),
                onTap: () => _jawab(item),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _finished(AppLocalizations l10n, String nama) {
    return Container(
      width: 600,
      height: 96,
      padding: const EdgeInsets.fromLTRB(26, 0, 16, 0),
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: const [
          BoxShadow(color: Color(0xFFF5BCD3), offset: Offset(0, 9)),
        ],
      ),
      child: Row(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GameGlyph(GameGlyphKind.star, size: 38),
              SizedBox(width: 2),
              GameGlyph(GameGlyphKind.star, size: 50),
              SizedBox(width: 2),
              GameGlyph(GameGlyphKind.star, size: 38),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              l10n.buahRight(nama),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: MociFonts.fredoka,
                fontWeight: FontWeight.w700,
                fontSize: 32,
                color: Color(0xFF1E8A31),
              ),
            ),
          ),
          MociPressable(
            key: BuahScreen.nextKey,
            onTap: _lanjut,
            color: _accent,
            shadowColor: _accentShadow,
            depth: 6,
            borderRadius: const BorderRadius.all(Radius.circular(33)),
            semanticLabel: l10n.buahNext,
            minTouch: 64,
            child: SizedBox(
              height: 66,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.buahNext,
                      style: const TextStyle(
                        fontFamily: MociFonts.fredoka,
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                        color: MociColors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const GameGlyph(
                      GameGlyphKind.next,
                      size: 28,
                      color: MociColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryPill(AppLocalizations l10n) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Color(0xFFF5BCD3), offset: Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Semantics(
          container: true,
          label: l10n.buahCats,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, k) in _kategoriUrut.indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                _categoryTab(k, l10n),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static const _kategoriUrut = ['semua', 'buah', 'sayur'];

  Widget _categoryTab(String kategori, AppLocalizations l10n) {
    final label = switch (kategori) {
      'buah' => l10n.buahCatFruit,
      'sayur' => l10n.buahCatVeggie,
      _ => l10n.buahCatAll,
    };
    final aktif = _kategori == kategori;
    return MociPressable(
      key: BuahScreen.categoryKey(kategori),
      onTap: () => _pilihKategori(kategori),
      color: aktif ? _accent : const Color(0x00000000),
      shadowColor: const Color(0x00000000),
      depth: 0,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: label,
      minTouch: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SizedBox(
          height: 56,
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: MociFonts.fredoka,
                fontWeight: FontWeight.w600,
                fontSize: 21,
                color: aktif ? MociColors.white : MociColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kenali(AppLocalizations l10n) {
    final item = [
      for (final e in _katalog.item)
        if ((e.kategori == 'buah' || e.kategori == 'sayur') &&
            (_kategoriSoal == null || e.kategori == _kategoriSoal))
          e,
    ];
    return Positioned(
      left: 32,
      right: 32,
      top: 124,
      bottom: 20,
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final lebar = (constraints.maxWidth - 28 - 5 * 18) / 6;
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
              child: Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [for (final e in item) _kartu(e, lebar, l10n)],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _kartu(Item item, double lebar, AppLocalizations l10n) {
    final buah = item.kategori == 'buah';
    final tag = buah ? l10n.buahTagFruit : l10n.buahTagVeggie;
    final nama = namaBuah(item, _lang);
    return MociPressable(
      key: BuahScreen.cardKey(item.id),
      onTap: () => _pilihKartu(item),
      color: MociColors.white,
      shadowColor: const Color(0xFFF5BCD3),
      depth: 8,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      semanticLabel: nama,
      child: Container(
        width: lebar,
        height: 196,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          border: Border.all(color: buah ? _fruitTag : _veggieTag, width: 6),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(child: MociIllustration(item.id, size: 134)),
            ),
            Positioned(
              left: 12,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: buah ? _fruitTag : _veggieTag,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: MociFonts.nunito,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: MociColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tail extends CustomPainter {
  const _Tail();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height * 0.47)
      ..close();
    canvas.drawPath(path, Paint()..color = MociColors.white);
  }

  @override
  bool shouldRepaint(_Tail old) => false;
}
