import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/layout/moci_stage.dart';
import '../../../app/routes.dart';
import '../../../app/theme/menu_theme.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../core/audio/audio_providers.dart';
import '../../../core/audio/narrator.dart';
import '../../../core/audio/sfx.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/content/katalog.dart';
import '../../../core/lang.dart';
import '../../../core/prefs/prefs_controller.dart';
import '../../../core/progress/progress_controller.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/game/answer_card.dart';
import '../../../widgets/game/game_glyphs.dart';
import '../../../widgets/moci_illustration.dart';
import '../../../widgets/moci_mascot.dart';
import '../../../widgets/pressable.dart';
import '../membaca_providers.dart';
import '../widgets/membaca_pill.dart';
import '../widgets/membaca_top_bar.dart';
import 'kalimat_game.dart';
import 'kalimat_timing.dart';
import 'kalimat_word.dart';

const _accent = Color(0xFFE0661A);
const _accentShadow = Color(0xFFA9480D);
const _putih = MociColors.white;
const _tinta = MociColors.ink;
const _tintaSoft = MociColors.inkSoft;
const _panelShadow = Color(0xFFF7C9A5);

class KalimatScreen extends ConsumerStatefulWidget {
  const KalimatScreen({super.key, this.awal});

  /// Id kalimat dari `?kalimat=`; tidak dikenal berarti kalimat pertama.
  final String? awal;

  static ValueKey<int> kataKey(int i) => ValueKey(400 + i);
  static ValueKey<String> gambarKey(String item) => ValueKey('kalimat-$item');
  static const gambarBesarKey = ValueKey<String>('kalimat-gambar-besar');
  static const bacaKey = ValueKey<String>('kalimat-baca');
  static const prevKey = ValueKey<String>('kalimat-prev');
  static const nextKey = ValueKey<String>('kalimat-next');

  @override
  ConsumerState<KalimatScreen> createState() => _KalimatScreenState();
}

class _KalimatScreenState extends ConsumerState<KalimatScreen>
    with SingleTickerProviderStateMixin {
  late final Katalog _katalog;
  late final Narrator _narrator;
  late final Ticker _ticker;
  late int _indeks;
  bool _quiz = false;
  int? _sorot = 0;
  bool _benar = false;
  String? _salahItem;
  List<String>? _pilihan;
  List<Duration> _mulai = const [];
  Duration _total = Duration.zero;

  KalimatEntry get _entri => _katalog.kalimat[_indeks];

  @override
  void initState() {
    super.initState();
    _katalog = ref.read(katalogProvider);
    _narrator = ref.read(narratorProvider);
    _ticker = createTicker(_onTick);
    final cari = _katalog.kalimat.indexWhere((e) => e.id == widget.awal);
    _indeks = cari < 0 ? 0 : cari;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catat();
      _baca([_uiLine('kalimatIns', context.l10n.kalimatIns), _kalimatLine()]);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _narrator.stop();
    super.dispose();
  }

  List<String> _kata(AppLang lang) => kataKalimat(_entri.teks.of(lang));

  List<double>? _waktuRekaman(AppLang lang) =>
      lang == AppLang.en ? _entri.waktu.en : _entri.waktu.id;

  void _catat() {
    ref.read(progressProvider.notifier).setLastActivity(Routes.kalimat, {
      'kalimat': _entri.id,
    });
  }

  Future<void> _baca(List<NarrationLine> baris) =>
      _narrator.sayAll(baris, ref.read(prefsProvider).lang);

  NarrationLine _kalimatLine() => NarrationLine(
    jenis: 'kalimat',
    id: _entri.id,
    text: _entri.teks.of(ref.read(prefsProvider).lang),
  );

  NarrationLine _uiLine(String id, String text) =>
      NarrationLine(jenis: 'ui', id: id, text: text);

  void _stopKaraoke() {
    if (_ticker.isActive) _ticker.stop();
  }

  void _mulaiKaraoke() {
    _stopKaraoke();
    final lang = ref.read(prefsProvider).lang;
    final kata = _kata(lang);
    final mulai = waktuMulaiKata(kata: kata, waktu: _waktuRekaman(lang));
    final total = totalKata(kata, mulai);
    setState(() {
      _mulai = mulai;
      _total = total;
      _sorot = kata.isEmpty ? null : 0;
    });
    _baca([_kalimatLine()]);
    if (kata.isEmpty || total <= Duration.zero) return;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_sorot == null) {
      _stopKaraoke();
      return;
    }
    if (elapsed >= _total) {
      _stopKaraoke();
      setState(() => _sorot = null);
      return;
    }
    final i = indeksKata(_mulai, elapsed);
    if (i != _sorot) setState(() => _sorot = i);
  }

  void _ketukKata(int i, AppLang lang) {
    _stopKaraoke();
    final bersih = _kata(
      lang,
    )[i].toLowerCase().replaceAll(RegExp('[^a-z]'), '');
    setState(() => _sorot = i);
    if (bersih.isEmpty) return;
    _baca([NarrationLine(jenis: 'kata', id: bersih, text: bersih)]);
  }

  void _gantiKalimat(int delta, AppLang lang) {
    _stopKaraoke();
    final n = _katalog.kalimat.length;
    setState(() {
      _indeks = (_indeks + delta) % n;
      _sorot = 0;
      _benar = false;
      _salahItem = null;
      _pilihan = _quiz ? _hitungPilihan() : null;
    });
    _catat();
    _baca([_kalimatLine()]);
  }

  void _gantiMode(bool quiz) {
    if (quiz == _quiz) return;
    _stopKaraoke();
    ref.read(narratorProvider).stop();
    setState(() {
      _quiz = quiz;
      _benar = false;
      _salahItem = null;
      _sorot = 0;
      _pilihan = quiz ? _hitungPilihan() : null;
    });
  }

  List<String> _hitungPilihan() => pilihanGambar(
    katalog: _katalog,
    kalimat: _entri,
    random: ref.read(membacaRandomProvider),
  );

  void _pilihGambar(String item) {
    if (_benar) return;
    if (item == itemDariGambar(_entri.gambar)) {
      setState(() {
        _benar = true;
        _salahItem = null;
      });
      ref.read(audioServiceProvider).playSfx(Sfx.benar);
      _baca([_uiLine('kalimatYes', context.l10n.kalimatYes), _kalimatLine()]);
      return;
    }
    setState(() => _salahItem = item);
    ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
    _baca([_uiLine('kalimatNo', context.l10n.kalimatNo)]);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(prefsProvider.select((p) => p.lang), (prev, next) {
      if (prev == next) return;
      _stopKaraoke();
      setState(() {
        _benar = false;
        _salahItem = null;
        _sorot = 0;
        _pilihan = _quiz ? _hitungPilihan() : null;
      });
      _baca([_kalimatLine()]);
    });
    final l10n = context.l10n;
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    final kata = _kata(lang);
    return MociStage(
      theme: MenuTheme.membaca,
      tablet: (context) => _panggung(l10n, kata),
    );
  }

  Widget _panggung(AppLocalizations l10n, List<String> kata) {
    return Stack(
      children: [
        Positioned(left: 0, right: 0, top: 0, child: const MembacaTopBar()),
        Positioned(left: 70, top: 120, child: _pilihMode(l10n)),
        Positioned(right: 70, top: 120, child: _penghitung()),
        Positioned(
          left: 70,
          top: 190,
          width: 1040,
          height: 380,
          child: _kartu(l10n, kata),
        ),
        if (_quiz)
          Positioned(left: 70, top: 606, width: 1040, child: _tebak(l10n))
        else
          Positioned(left: 200, top: 640, width: 780, child: _petunjuk(l10n)),
      ],
    );
  }

  Widget _pilihMode(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MembacaPill(
          label: l10n.kalimatReadMode,
          selected: !_quiz,
          onTap: () => _gantiMode(false),
        ),
        const SizedBox(width: 10),
        MembacaPill(
          label: l10n.kalimatQuizMode,
          selected: _quiz,
          onTap: () => _gantiMode(true),
        ),
      ],
    );
  }

  Widget _penghitung() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _putih,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: _panelShadow, offset: Offset(0, 5))],
      ),
      child: Text(
        '${_indeks + 1} / ${_katalog.kalimat.length}',
        style: MociText.button.copyWith(fontSize: 22, color: _tinta),
      ),
    );
  }

  Widget _kartu(AppLocalizations l10n, List<String> kata) {
    final gambar = _quiz && !_benar
        ? Center(
            child: Text(
              '?',
              style: MociText.title.copyWith(
                fontSize: 150,
                color: _panelShadow,
              ),
            ),
          )
        : MociIllustration(
            itemDariGambar(_entri.gambar),
            key: _quiz ? KalimatScreen.gambarBesarKey : null,
            size: 260,
            semanticLabel: l10n.kalimatPicture,
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _putih,
        borderRadius: BorderRadius.circular(48),
        boxShadow: const [
          BoxShadow(color: _panelShadow, offset: Offset(0, 14)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 40,
            top: 40,
            width: 300,
            height: 300,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 60,
            top: 50,
            width: 260,
            height: 260,
            child: Center(child: gambar),
          ),
          Positioned(
            left: 380,
            top: 40,
            width: 620,
            child: Text(
              l10n.kalimatIns,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MociText.label.copyWith(fontSize: 20, color: _tintaSoft),
            ),
          ),
          Positioned(
            left: 380,
            top: 82,
            width: 620,
            child: Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                for (var i = 0; i < kata.length; i++)
                  KalimatWord(
                    key: KalimatScreen.kataKey(i),
                    text: kata[i],
                    sorot: i == _sorot,
                    onTap: () => _ketukKata(i, ref.read(prefsProvider).lang),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 380,
            bottom: 34,
            child: Row(
              children: [
                _tombolBaca(l10n),
                const SizedBox(width: 14),
                _tombolPutar(
                  key: KalimatScreen.prevKey,
                  label: l10n.kalimatPrev,
                  kiri: true,
                  onTap: () => _gantiKalimat(-1, ref.read(prefsProvider).lang),
                ),
                const SizedBox(width: 14),
                _tombolPutar(
                  key: KalimatScreen.nextKey,
                  label: l10n.kalimatNext,
                  kiri: false,
                  onTap: () => _gantiKalimat(1, ref.read(prefsProvider).lang),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tombolBaca(AppLocalizations l10n) {
    return MociPressable(
      key: KalimatScreen.bacaKey,
      onTap: _mulaiKaraoke,
      color: _accent,
      shadowColor: _accentShadow,
      depth: 7,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: l10n.kalimatRead,
      minTouch: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GameGlyph(GameGlyphKind.play, size: 28, color: _putih),
              const SizedBox(width: 10),
              Text(
                l10n.kalimatRead,
                style: MociText.button.copyWith(fontSize: 24, color: _putih),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tombolPutar({
    required Key key,
    required String label,
    required bool kiri,
    required VoidCallback onTap,
  }) {
    return MociPressable(
      key: key,
      onTap: onTap,
      color: const Color(0xFFFFF1E6),
      shadowColor: _panelShadow,
      depth: 6,
      borderRadius: BorderRadius.circular(35),
      semanticLabel: label,
      minTouch: 70,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Center(
          child: Transform.rotate(
            angle: kiri ? math.pi : 0,
            child: const GameGlyph(GameGlyphKind.next, size: 32, color: _tinta),
          ),
        ),
      ),
    );
  }

  Widget _tebak(AppLocalizations l10n) {
    final pilihan = _pilihan ?? const <String>[];
    final jawaban = itemDariGambar(_entri.gambar);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 230,
          child: Text(
            l10n.kalimatWhich,
            style: MociText.button.copyWith(
              fontSize: 26,
              color: _tinta,
              height: 1.15,
            ),
          ),
        ),
        for (final item in pilihan) ...[
          const SizedBox(width: 24),
          AnswerCard(
            key: KalimatScreen.gambarKey(item),
            illustration: item,
            width: 240,
            height: 180,
            illustrationSize: 140,
            semanticLabel: _namaItem(item, ref.read(prefsProvider).lang),
            state: _benar && item == jawaban
                ? AnswerCardState.correct
                : _salahItem == item
                ? AnswerCardState.wrong
                : AnswerCardState.idle,
            onTap: () => _pilihGambar(item),
          ),
        ],
      ],
    );
  }

  String _namaItem(String id, AppLang lang) {
    for (final item in _katalog.item) {
      if (item.id == id) return item.nama.of(lang);
    }
    return id;
  }

  Widget _petunjuk(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
      decoration: BoxDecoration(
        color: _putih,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: _panelShadow, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          const MociMascot(size: 70),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.kalimatReadTip,
              style: MociText.label.copyWith(
                fontSize: 20,
                color: _tintaSoft,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
