import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/audio/sfx.dart';
import '../../core/content/content_repository.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../core/speech/mic_level_meter.dart';
import '../../core/speech/method_channel_mic_level_meter.dart';
import '../../core/speech/speech_engine.dart';
import '../../core/speech/speech_to_text_engine.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/mic_button.dart';
import '../../widgets/game/progress_dots.dart';
import '../../widgets/game/route_mode_pill.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_button.dart';
import '../../widgets/moci_dialog.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/star_counter.dart';
import 'ucapkan_kata.dart';

/// Layar Ucapkan: dengar contoh lalu ucapkan. Mikrofon hanya hidup setelah
/// Gerbang Orang Tua; kalau pengenalan luring tidak ada, level suara dipakai.
class UcapkanScreen extends ConsumerStatefulWidget {
  const UcapkanScreen({super.key, this.awal});

  static const micKey = ValueKey<String>('ucapkan-mic');
  static const nextKey = ValueKey<String>('ucapkan-next');
  static const againKey = ValueKey<String>('ucapkan-again');
  static const practiceKey = ValueKey<String>('ucapkan-practice');

  static ValueKey<int> syllableKey(int i) => ValueKey<int>(i);

  /// Kata pertama saat layar dibuka; nilai di luar daftar diabaikan.
  final String? awal;

  @override
  ConsumerState<UcapkanScreen> createState() => _UcapkanScreenState();
}

enum _Fase { idle, listen, good }

class _UcapkanScreenState extends ConsumerState<UcapkanScreen> {
  static const _accent = Color(0xFFE8384F);
  static const _soft = Color(0xFFFFF1EC);
  static const _sukuColor = [
    (Color(0xFFE8384F), Color(0xFFB82A3E)),
    (Color(0xFF1C8CF0), Color(0xFF1265B5)),
    (Color(0xFF7048E8), Color(0xFF5032B8)),
  ];

  /// Satu giliran mendengar.
  static const giliran = Duration(seconds: 4);

  int _i = 0;
  _Fase _fase = _Fase.idle;
  int _percobaan = 0;
  bool _hadiah = false;
  bool _sibuk = false;

  /// Pengenalan tidak bisa dipakai: kata hanya didengar lalu ditiru.
  bool _dengarTiru = false;
  bool _izinDitolak = false;

  List<UcapkanKata> get _daftar =>
      ucapkanKata(ref.read(katalogProvider), ref.read(prefsProvider).lang);

  int get _idx => _i.clamp(0, _daftar.length - 1);

  UcapkanKata get _kata => _daftar[_idx];

  AppLang get _lang => ref.read(prefsProvider).lang;

  /// Diambil sekali di [initState]: `dispose` dan lanjutan `listen` yang
  /// masih berjalan tidak boleh menyentuh `ref` lagi.
  late final SpeechEngine _speech;
  late final MicLevelMeter _meter;
  late final Narrator _narrator;

  @override
  void initState() {
    super.initState();
    _speech = ref.read(speechEngineProvider);
    _meter = ref.read(micLevelMeterProvider);
    _narrator = ref.read(narratorProvider);
    final awal = widget.awal?.toLowerCase();
    if (awal != null) {
      final at = _daftar.indexWhere((k) => k.kata.toLowerCase() == awal);
      if (at >= 0) _i = at;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catat();
    });
  }

  @override
  void dispose() {
    // Mikrofon tidak boleh terus mendengar setelah anak pindah layar.
    _speech.stop();
    _meter.stop();
    _narrator.stop();
    super.dispose();
  }

  void _catat() {
    ref.read(progressProvider.notifier).setLastActivity(Routes.hurufUcapkan, {
      'kata': _kata.kata,
    });
  }

  void _say(List<NarrationLine> lines) => _narrator.sayAll(lines, _lang);

  NarrationLine _ui(String kunci, String teks) =>
      NarrationLine(jenis: 'ui', id: kunci, text: teks);

  NarrationLine _itemLine() =>
      NarrationLine(jenis: 'nama', id: _kata.itemId, text: _kata.kata);

  List<NarrationLine> _sukuLines() => [
    for (final s in _kata.suku)
      NarrationLine(jenis: 'suku', id: s.toLowerCase(), text: s),
  ];

  void _sayExample() => _say([..._sukuLines(), _itemLine()]);

  Future<void> _ketukMic() async {
    if (_sibuk || _dengarTiru || _fase != _Fase.idle) return;
    final speech = _speech;
    if (!await speech.hasPermission()) {
      final lolos = await _mintaGerbang();
      if (!mounted || !lolos) return;
    }
    if (!mounted) return;
    final status = await speech.prepare(_lang);
    if (!mounted) return;
    if (status == SpeechStatus.izinDitolak) {
      setState(() {
        _dengarTiru = true;
        _izinDitolak = true;
      });
      return;
    }
    await _dengar(speech);
  }

  /// Gerbang Orang Tua selalu mendahului permintaan izin mikrofon.
  Future<bool> _mintaGerbang() async {
    final l10n = context.l10n;
    final buka = await MociDialog.show<bool>(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.ucapkanMicAskTitle,
            style: MociText.title.copyWith(fontSize: 32, height: 1.1),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.ucapkanMicAskBody,
            style: MociText.label.copyWith(
              fontSize: 20,
              height: 1.4,
              color: const Color(0xFF5B5480),
            ),
          ),
        ],
      ),
      actions: [
        MociDialogButton(
          label: l10n.ucapkanMicAskAction,
          color: MociColors.correct,
          shadowColor: MociColors.correctShadow,
          textColor: MociColors.white,
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (buka != true || !mounted) return false;
    return await context.push<bool>(Routes.gerbang) ?? false;
  }

  Future<void> _dengar(SpeechEngine speech) async {
    final audio = ref.read(audioServiceProvider);
    final sesi = ref.read(audioSessionProvider);
    final meter = _meter;
    final target = _kata.kata;
    setState(() {
      _sibuk = true;
      _fase = _Fase.listen;
    });
    SpeechTurn? hasil;
    var meterKosong = false;
    await audio.pauseForListening();
    try {
      hasil = await speech.listen(target: target, lang: _lang, batas: giliran);
      // Anak sudah pindah layar: jangan menyentuh state atau provider lagi.
      if (!mounted) return;
      if (hasil == null) {
        // Tidak ada pengenalan luring: level suara menentukan ada tidaknya
        // suara. Pengenalan daring tidak pernah dipakai.
        if (await meter.available) {
          hasil = SpeechTurn(didengar: await meter.listen(batas: giliran));
        } else {
          meterKosong = true;
        }
      }
      await sesi.usePlayback();
    } finally {
      await audio.resumeAfterListening();
      if (mounted) setState(() => _sibuk = false);
    }
    if (!mounted) return;
    if (meterKosong) {
      setState(() {
        _dengarTiru = true;
        _izinDitolak = false;
      });
      return;
    }
    final turn = hasil;
    final cocok =
        turn != null &&
        turn.didengar &&
        (turn.teks == null || kataCocok(target, turn.teks!));
    if (cocok) {
      _berhasil(true);
      return;
    }
    _percobaan++;
    if (_percobaan < 2) {
      setState(() => _fase = _Fase.idle);
      // Satu kalimat utuh: "Ayo coba lagi!" lalu contohnya.
      _say([
        _ui('ucapkanTryAgain', context.l10n.ucapkanTryAgain),
        ..._sukuLines(),
        _itemLine(),
      ]);
      return;
    }
    // Dua percobaan: tetap dipuji, tanpa bintang hadiah.
    _berhasil(false);
  }

  void _berhasil(bool bintang) {
    setState(() {
      _fase = _Fase.good;
      _percobaan = 0;
      // Percobaan kedua tetap dipuji, tetapi tanpa bintang hadiah.
      _hadiah = bintang;
    });
    if (bintang) ref.read(audioServiceProvider).playSfx(Sfx.benar);
    _say([_ui('ucapkanDoneSay', context.l10n.ucapkanDoneSay), _itemLine()]);
  }

  void _ulang() {
    setState(() {
      _fase = _Fase.idle;
      _percobaan = 0;
      _hadiah = false;
    });
    _sayExample();
  }

  void _lanjut() {
    final list = _daftar;
    setState(() {
      _i = (_idx + 1) % list.length;
      _fase = _Fase.idle;
      _percobaan = 0;
      _hadiah = false;
    });
    _catat();
    _say([_ui('ucapkanLetsSay', context.l10n.ucapkanLetsSay), _itemLine()]);
  }

  @override
  Widget build(BuildContext context) {
    // Kata, suku, locale pengenalan, dan narasi ikut bahasa baru.
    ref.listen(prefsProvider.select((p) => p.lang), (_, _) {
      setState(() {
        _fase = _Fase.idle;
        _percobaan = 0;
        _hadiah = false;
      });
    });
    ref.watch(prefsProvider.select((p) => p.lang));
    ref.watch(katalogProvider);
    return MociStage(theme: MenuTheme.ucapkan, tablet: _tablet);
  }

  Widget _tablet(BuildContext context) {
    final l10n = context.l10n;
    final kata = _kata;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MociTopBar(
            leading: const MociBackButton(),
            title: l10n.hurufTitle,
            trailing: [
              RouteModePill(
                tabs: [
                  (
                    label: l10n.hurufLearn,
                    route: Routes.huruf,
                    icon: const GameGlyph(GameGlyphKind.eye),
                  ),
                  (
                    label: l10n.hurufWrite,
                    route: Routes.hurufTulis,
                    icon: const GameGlyph(GameGlyphKind.pencil),
                  ),
                  (
                    label: l10n.hurufSay,
                    route: Routes.hurufUcapkan,
                    icon: const GameGlyph(GameGlyphKind.mic),
                  ),
                ],
                semanticLabel: l10n.modeSemantic,
                accent: _accent,
              ),
              StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
            ],
          ),
        ),
        Positioned(left: 60, top: 128, child: _card(l10n, kata)),
        Positioned(left: 612, top: 132, child: const MociMascot(size: 190)),
        Positioned(left: 806, top: 126, child: _bubble(l10n, kata)),
        Positioned(left: 784, top: 196, child: const _BubbleTail()),
        Positioned(left: 780, top: 372, child: _mic(l10n, kata)),
        Positioned(left: 640, top: 584, width: 460, child: _status(l10n)),
        if (_fase == _Fase.good && _hadiah) _stars(),
        if (_fase == _Fase.good || _dengarTiru)
          Positioned(left: 640, top: 712, width: 460, child: _actions(l10n)),
      ],
    );
  }

  Widget _card(AppLocalizations l10n, UcapkanKata kata) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return Container(
      width: 500,
      height: 600,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(44),
        boxShadow: [
          BoxShadow(color: shadow, offset: const Offset(0, 14)),
          const BoxShadow(
            color: Color(0x1F2B2350),
            offset: Offset(0, 26),
            blurRadius: 40,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 110,
            top: 34,
            width: 280,
            height: 280,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _soft,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 125,
            top: 42,
            width: 250,
            height: 250,
            child: MociIllustration(kata.gambar, size: 250),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 334,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < kata.suku.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    _syllable(l10n, i, kata.suku[i]),
                  ],
                ],
              ),
            ),
          ),
          Positioned(left: 110, top: 470, child: _hear(l10n)),
          Positioned(
            left: 0,
            right: 0,
            top: 566,
            child: Center(
              child: ProgressDots(
                count: _daftar.length,
                current: _idx,
                semanticLabel: l10n.ucapkanYourTurn,
                activeWidth: 34,
                activeColor: _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _syllable(AppLocalizations l10n, int i, String suku) {
    final (color, shadow) = _sukuColor[i % _sukuColor.length];
    return MociPressable(
      key: UcapkanScreen.syllableKey(i),
      onTap: () => _say([
        NarrationLine(jenis: 'suku', id: suku.toLowerCase(), text: suku),
      ]),
      color: color,
      shadowColor: shadow,
      depth: 8,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      semanticLabel: '${l10n.ucapkanSyl} $suku',
      minTouch: 100,
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Center(
            child: Text(
              suku,
              style: const TextStyle(
                fontFamily: MociFonts.fredoka,
                fontSize: 60,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 2,
                color: MociColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hear(AppLocalizations l10n) {
    return MociPressable(
      onTap: _sayExample,
      color: const Color(0xFFFFB020),
      shadowColor: const Color(0xFFE0870B),
      depth: 7,
      borderRadius: const BorderRadius.all(Radius.circular(36)),
      semanticLabel: l10n.ucapkanHear,
      minTouch: 72,
      child: SizedBox(
        width: 280,
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GameGlyph(GameGlyphKind.listen, size: 30),
            const SizedBox(width: 10),
            Text(
              l10n.ucapkanHear,
              style: MociText.button.copyWith(fontSize: 26),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(AppLocalizations l10n, UcapkanKata kata) {
    return Container(
      width: 330,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Color(0x1A2B2350), offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.ucapkanYourTurn,
            style: MociText.label.copyWith(fontSize: 26, height: 1.2),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              kata.kata.toUpperCase(),
              style: const TextStyle(
                fontFamily: MociFonts.fredoka,
                fontSize: 52,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: 2,
                color: _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mic(AppLocalizations l10n, UcapkanKata kata) {
    if (_dengarTiru) {
      return SizedBox(
        width: 300,
        height: 180,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: MociButton(
              key: UcapkanScreen.practiceKey,
              label: l10n.ucapkanPractice,
              icon: const GameGlyph(GameGlyphKind.listen, size: 28),
              kind: MociButtonKind.light,
              height: 96,
              onTap: _sayExample,
            ),
          ),
        ),
      );
    }
    final listen = _fase == _Fase.listen;
    return MicButton(
      key: UcapkanScreen.micKey,
      phase: listen
          ? MicPhase.listening
          : _fase == _Fase.good
          ? MicPhase.good
          : MicPhase.idle,
      semanticLabel: listen
          ? l10n.ucapkanMicListen
          : l10n.ucapkanMicLabel(kata.kata),
      onTap: _ketukMic,
    );
  }

  Widget _status(AppLocalizations l10n) {
    final String teks;
    if (_fase == _Fase.listen) {
      teks = l10n.ucapkanListen;
    } else if (_fase == _Fase.good) {
      teks = l10n.ucapkanGood;
    } else if (_dengarTiru) {
      teks = _izinDitolak ? l10n.ucapkanMicDenied : l10n.ucapkanMicUnavailable;
    } else if (_percobaan > 0) {
      teks = l10n.ucapkanTryAgain;
    } else {
      teks = l10n.ucapkanIdle;
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        teks,
        textAlign: TextAlign.center,
        style: MociText.label.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _stars() {
    return const Positioned(
      left: 640,
      top: 628,
      width: 460,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GameGlyph(GameGlyphKind.star, size: 44, color: Color(0xFFFFC21A)),
          SizedBox(width: 4),
          GameGlyph(GameGlyphKind.star, size: 58, color: Color(0xFFFFC21A)),
          SizedBox(width: 4),
          GameGlyph(GameGlyphKind.star, size: 44, color: Color(0xFFFFC21A)),
        ],
      ),
    );
  }

  Widget _actions(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_dengarTiru) ...[
          MociButton(
            key: UcapkanScreen.againKey,
            label: l10n.ucapkanAgain,
            kind: MociButtonKind.light,
            height: 64,
            onTap: _ulang,
          ),
          const SizedBox(width: 14),
        ],
        MociButton(
          key: UcapkanScreen.nextKey,
          label: l10n.ucapkanNextWord,
          height: 64,
          onTap: _lanjut,
        ),
      ],
    );
  }
}

/// Segitiga putih kecil di kiri gelembung giliran.
class _BubbleTail extends StatelessWidget {
  const _BubbleTail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(painter: _TailPainter()),
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height * 0.4)
      ..close();
    canvas.drawPath(path, Paint()..color = MociColors.white);
  }

  @override
  bool shouldRepaint(covariant _TailPainter oldDelegate) => false;
}
