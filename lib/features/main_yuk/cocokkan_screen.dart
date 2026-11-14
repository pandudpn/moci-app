import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_motion.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/audio/sfx.dart';
import '../../core/content/content_repository.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/game_instruction.dart';
import '../../widgets/game/game_mode_pill.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/pressable.dart';
import 'cocokkan_game.dart';
import 'game_scaffold.dart';
import 'main_yuk_game.dart';

const _accent = Color(0xFFE64980);
const _ringIdle = Color(0xFFF3D9E5);
const _palette = [
  Color(0xFFE64980),
  Color(0xFF1C7ED6),
  Color(0xFF2F9E44),
  Color(0xFFF08C00),
  Color(0xFF7048E8),
];

const _boardLeft = 190.0;
const _boardTop = 118.0;
const _boardWidth = 800.0;
const _boardHeight = 660.0;

/// Petunjuk singkat di bawah judul tema.
enum _Tip { ins, next, pick }

/// Cocokkan Gambar: ketuk atau tarik garis antara dua gambar yang sama.
class CocokkanScreen extends ConsumerStatefulWidget {
  const CocokkanScreen({super.key});

  static const boardKey = ValueKey('cocokkan-board');
  static const garisJariKey = ValueKey('cocokkan-garis-jari');
  static const shuffleKey = ValueKey('cocokkan-shuffle');

  static ValueKey<String> kartuKey(CocokkanSisi sisi, int i) =>
      ValueKey('cocokkan-${sisi.name}-$i');

  static ValueKey<int> garisKey(int kiri) => ValueKey(kiri);

  static ValueKey<MainYukTema> temaKey(MainYukTema t) => ValueKey(t);

  @override
  ConsumerState<CocokkanScreen> createState() => _CocokkanScreenState();
}

class _CocokkanScreenState extends ConsumerState<CocokkanScreen>
    with SingleTickerProviderStateMixin {
  MainYukTema _tema = MainYukTema.buah;
  late int _pasangan;
  late CocokkanSesi _sesi;
  late String _roundId;
  bool _selesai = false;
  _Tip _tip = _Tip.ins;

  late final _goyang = AnimationController(
    vsync: this,
    duration: MociMotion.shake,
  );

  Offset? _tekan;
  bool _menyeret = false;
  CocokkanSisi? _dragSisi;
  int? _dragIndeks;
  Offset? _dragKe;

  @override
  void initState() {
    super.initState();
    _pasangan = cocokkanPasangan(ref.read(prefsProvider).ageLevel);
    _rondeBaru(tema: _tema);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Nomor ronde tidak boleh mengubah provider saat pohon sedang dibangun.
      _roundId = _nomorRonde();
      ref.read(progressProvider.notifier).setLastActivity(Routes.cocokkan);
      _say([_instLine()]);
    });
  }

  @override
  void dispose() {
    _goyang.dispose();
    super.dispose();
  }

  void _rondeBaru({required MainYukTema tema, MainYukTema? sebelumnya}) {
    final ronde = buatCocokkan(
      ref.read(katalogProvider),
      pasangan: _pasangan,
      tema: tema,
      random: ref.read(gameRandomProvider),
      sebelumnya: sebelumnya,
    );
    _sesi = CocokkanSesi(ronde);
    _selesai = false;
    _tip = _Tip.ins;
    _batalSeret();
  }

  String _nomorRonde() =>
      ref.read(mainYukRoundSeqProvider.notifier).next(MainYukGame.cocokkan.id);

  void _mulaiRonde({required MainYukTema tema, MainYukTema? sebelumnya}) {
    _rondeBaru(tema: tema, sebelumnya: sebelumnya);
    _roundId = _nomorRonde();
    _selesai = false;
    _tip = _Tip.ins;
    _batalSeret();
  }

  void _gantiPasangan(int n) {
    setState(() {
      _pasangan = n;
      _mulaiRonde(tema: _tema);
    });
  }

  void _gantiTema(MainYukTema tema) {
    setState(() {
      final sebelumnya = _sesi.ronde.tema;
      _tema = tema;
      _mulaiRonde(
        tema: tema,
        sebelumnya: tema == MainYukTema.acak ? sebelumnya : null,
      );
    });
  }

  void _gambarBaru() {
    setState(() {
      _mulaiRonde(tema: _tema, sebelumnya: _sesi.ronde.tema);
    });
  }

  NarrationLine _instLine() =>
      barisUi('cocokkanInst', context.l10n.cocokkanInst);

  String _namaItem(CocokkanSisi sisi, int i) {
    final ronde = _sesi.ronde;
    final id = sisi == CocokkanSisi.kiri ? ronde.kiri[i] : ronde.kanan[i];
    final item = ref.read(katalogProvider).byId(id);
    return item?.nama.of(ref.read(prefsProvider).lang) ?? id;
  }

  NarrationLine _namaLine(CocokkanSisi sisi, int i) {
    final ronde = _sesi.ronde;
    final id = sisi == CocokkanSisi.kiri ? ronde.kiri[i] : ronde.kanan[i];
    return barisNama(id, _namaItem(sisi, i));
  }

  void _say(List<NarrationLine> lines) {
    ref.read(narratorProvider).sayAll(lines, ref.read(prefsProvider).lang);
  }

  void _ketuk(CocokkanSisi sisi, int i) {
    final step = _sesi.ketuk(sisi, i);
    _tangani(step, sisi, i, bicarakanPilihan: true);
  }

  void _tangani(
    CocokkanStep step,
    CocokkanSisi sisi,
    int i, {
    required bool bicarakanPilihan,
  }) {
    switch (step) {
      case CocokkanStep.abaikan:
        return;
      case CocokkanStep.pilih:
        if (bicarakanPilihan) _say([_namaLine(sisi, i)]);
        setState(() => _tip = _Tip.next);
      case CocokkanStep.cocok:
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        setState(() => _tip = _Tip.ins);
        _say([
          _namaLine(sisi, i),
          barisUi('cocokkanMatch', context.l10n.cocokkanMatch),
        ]);
      case CocokkanStep.salah:
        ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
        setState(() => _tip = _Tip.pick);
        _goyang.forward(from: 0);
        _say([barisUi('cocokkanRetry', context.l10n.cocokkanRetry)]);
      case CocokkanStep.selesai:
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        setState(() => _tip = _Tip.ins);
        _say([
          _namaLine(sisi, i),
          barisUi('cocokkanMatch', context.l10n.cocokkanMatch),
        ]);
        _selesaikanRonde();
    }
  }

  void _selesaikanRonde() {
    if (_selesai) return;
    _selesai = true;
    unawaited(
      selesaikanRonde(
        context,
        ref,
        gameId: MainYukGame.cocokkan.id,
        roundId: _roundId,
        replayRoute: Routes.cocokkan,
      ),
    );
  }

  void _batalSeret() {
    _tekan = null;
    _menyeret = false;
    _dragSisi = null;
    _dragIndeks = null;
    _dragKe = null;
  }

  ({CocokkanSisi sisi, int indeks})? _kartuDi(Offset pos, {double extra = 0}) {
    final n = _sesi.ronde.jumlah;
    final size = _ukuran(n);
    ({CocokkanSisi sisi, int indeks})? hasil;
    var jarak = double.infinity;
    for (final sisi in CocokkanSisi.values) {
      for (var i = 0; i < n; i++) {
        final d = (_pusat(n, size, sisi, i) - pos).distance;
        if (d <= size / 2 + extra && d < jarak) {
          jarak = d;
          hasil = (sisi: sisi, indeks: i);
        }
      }
    }
    return hasil;
  }

  void _down(PointerDownEvent e) {
    _tekan = e.localPosition;
    _menyeret = false;
    _dragKe = null;
    final hit = _kartuDi(e.localPosition);
    _dragSisi = hit?.sisi;
    _dragIndeks = hit?.indeks;
  }

  void _move(PointerMoveEvent e) {
    final tekan = _tekan;
    if (tekan == null || _dragSisi == null || _dragIndeks == null) return;
    if (!_menyeret && (e.localPosition - tekan).distance <= 12) return;
    setState(() {
      _menyeret = true;
      _dragKe = e.localPosition;
    });
  }

  void _up(PointerUpEvent e) {
    final menyeret = _menyeret;
    final sisi = _dragSisi;
    final indeks = _dragIndeks;
    setState(_batalSeret);
    if (!menyeret || sisi == null || indeks == null) return;
    final target = _kartuDi(e.localPosition, extra: 18);
    if (target == null || target.sisi == sisi) return;
    if (_sesi.terpasang(sisi, indeks)) return;
    final awal = _sesi.ketuk(sisi, indeks);
    if (awal != CocokkanStep.pilih) return;
    final akhir = _sesi.ketuk(target.sisi, target.indeks);
    _tangani(akhir, target.sisi, target.indeks, bicarakanPilihan: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Kembali dari Hebat lewat `go` memakai state layar ini lagi; ronde
    // sebelumnya sudah selesai dan harus dimulai dari awal.
    ref.listen(currentPathProvider, (sebelum, sekarang) {
      if (sebelum == Routes.hebat && sekarang == Routes.cocokkan) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _mulaiRonde(tema: _tema));
        });
      }
    });
    return GameScaffold(
      theme: MenuTheme.cocokkan,
      title: l10n.cocokkanTitle,
      trailing: [
        GameModePill(
          tabs: [
            for (final n in const [3, 4, 5])
              GameModeTab(label: l10n.mainYukPairs(n)),
          ],
          selected: _pasangan - 3,
          onSelected: (i) => _gantiPasangan(i + 3),
          semanticLabel: l10n.gameLevel,
          accent: _accent,
        ),
        MociPressable(
          key: CocokkanScreen.shuffleKey,
          onTap: _gambarBaru,
          semanticLabel: l10n.cocokkanShuffle,
          depth: 6,
          borderRadius: const BorderRadius.all(Radius.circular(22)),
          minTouch: 64,
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Center(child: GameGlyph(GameGlyphKind.refresh, size: 30)),
          ),
        ),
      ],
      children: [
        _papan(context, l10n),
        _kolomTema(l10n),
        const Positioned(
          left: 24,
          top: 652,
          child: MociMascot(size: 150, idle: true),
        ),
      ],
    );
  }

  Widget _papan(BuildContext context, AppLocalizations l10n) {
    final n = _sesi.ronde.jumlah;
    final size = _ukuran(n);
    final judul = _judulTema(l10n, _sesi.ronde.tema);
    final teks = switch (_tip) {
      _Tip.ins => l10n.cocokkanIns,
      _Tip.next => l10n.cocokkanTipNext,
      _Tip.pick => l10n.cocokkanTipPick,
    };
    return Positioned(
      key: CocokkanScreen.boardKey,
      left: _boardLeft,
      top: _boardTop,
      width: _boardWidth,
      height: _boardHeight,
      child: AnimatedBuilder(
        animation: _goyang,
        builder: (context, child) {
          final t = _goyang.value;
          final offset = math.sin(t * math.pi * 6) * 10 * (1 - t);
          return Transform.translate(offset: Offset(offset, 0), child: child);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: MociColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(44)),
            boxShadow: [
              BoxShadow(
                color: MenuTheme.cocokkan.shadow,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _down,
            onPointerMove: _move,
            onPointerUp: _up,
            onPointerCancel: (_) => setState(_batalSeret),
            child: Stack(
              children: [
                for (final e in _sesi.cocok.entries) _garis(e.key, e.value, n),
                Positioned(
                  left: 40,
                  right: 40,
                  top: 22,
                  child: Center(
                    child: GameInstruction(
                      title: judul,
                      text: teks,
                      semanticLabel: '$judul. $teks',
                      narration: [_instLine()],
                      listenLabel: l10n.cocokkanHear,
                    ),
                  ),
                ),
                for (final sisi in CocokkanSisi.values)
                  for (var i = 0; i < n; i++) _kartu(sisi, i, n, size),
                if (_menyeret && _dragKe != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        key: CocokkanScreen.garisJariKey,
                        painter: _JariPainter(
                          dari: _tepiKartu(
                            _pusat(n, size, _dragSisi!, _dragIndeks!),
                            _dragKe!,
                            size,
                          ),
                          ke: _dragKe!,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _garis(int kiri, int kanan, int n) {
    final size = _ukuran(n);
    final dari =
        _pusat(n, size, CocokkanSisi.kiri, kiri) + Offset(size / 2 + 21, 0);
    final ke =
        _pusat(n, size, CocokkanSisi.kanan, kanan) - Offset(size / 2 + 21, 0);
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          key: CocokkanScreen.garisKey(kiri),
          painter: _GarisPainter(
            dari: dari,
            ke: ke,
            warna: _palette[kiri % _palette.length],
          ),
        ),
      ),
    );
  }

  Widget _kartu(CocokkanSisi sisi, int i, int n, double size) {
    final pusat = _pusat(n, size, sisi, i);
    final ronde = _sesi.ronde;
    final id = sisi == CocokkanSisi.kiri ? ronde.kiri[i] : ronde.kanan[i];
    final terpilih = _sesi.sisiDipilih == sisi && _sesi.indeksDipilih == i;
    final terpasang = _sesi.terpasang(sisi, i);
    final warnaCincin = terpilih
        ? _accent
        : terpasang
        ? _palette[_kiriDari(sisi, i) % _palette.length]
        : _ringIdle;
    return Positioned(
      left: pusat.dx - size / 2,
      top: pusat.dy - size / 2,
      width: size,
      height: size,
      child: MociPressable(
        key: CocokkanScreen.kartuKey(sisi, i),
        onTap: () => _ketuk(sisi, i),
        semanticLabel: _namaItem(sisi, i),
        depth: 8,
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: warnaCincin, width: 7),
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
          ),
          child: Center(child: MociIllustration(id, size: size * 0.72)),
        ),
      ),
    );
  }

  int _kiriDari(CocokkanSisi sisi, int i) {
    if (sisi == CocokkanSisi.kiri) return i;
    for (final e in _sesi.cocok.entries) {
      if (e.value == i) return e.key;
    }
    return i;
  }

  Widget _kolomTema(AppLocalizations l10n) {
    return Positioned(
      left: 1010,
      top: 130,
      width: 146,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.cocokkanTema,
            textAlign: TextAlign.center,
            style: MociText.label.copyWith(color: MociColors.inkSoft),
          ),
          const SizedBox(height: 8),
          for (final tema in MainYukTema.pilihan) ...[
            MociPressable(
              key: CocokkanScreen.temaKey(tema),
              onTap: () => _gantiTema(tema),
              semanticLabel: tema.label(l10n),
              color: _tema == tema ? _accent : MociColors.white,
              depth: 5,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              minTouch: 64,
              child: SizedBox(
                height: 46,
                child: Center(
                  child: Text(
                    tema.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MociText.label.copyWith(
                      color: _tema == tema ? MociColors.white : MociColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  String _judulTema(AppLocalizations l10n, MainYukTema tema) => switch (tema) {
    MainYukTema.hewan => l10n.cocokkanHeadHewan,
    MainYukTema.sayur => l10n.cocokkanHeadSayur,
    MainYukTema.kendaraan => l10n.cocokkanHeadKendaraan,
    MainYukTema.benda => l10n.cocokkanHeadBenda,
    _ => l10n.cocokkanHeadBuah,
  };

  static double _ukuran(int jumlah) => switch (jumlah) {
    3 => 130,
    4 => 108,
    _ => 88,
  };

  static double _gap(int jumlah, double size) =>
      (640 - 132 - jumlah * size) / (jumlah + 1);

  static Offset _pusat(int jumlah, double size, CocokkanSisi sisi, int i) {
    final gap = _gap(jumlah, size);
    final y = 132 + gap + i * (size + gap) + size / 2;
    final x = sisi == CocokkanSisi.kiri ? 110 + size / 2 : 690 - size / 2;
    return Offset(x, y);
  }

  static Offset _tepiKartu(Offset pusat, Offset ke, double size) {
    final arah = ke - pusat;
    if (arah.distance == 0) return pusat;
    return pusat + arah / arah.distance * (size / 2 + 2);
  }
}

class _GarisPainter extends CustomPainter {
  const _GarisPainter({
    required this.dari,
    required this.ke,
    required this.warna,
  });

  final Offset dari;
  final Offset ke;
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    final dx = ke.dx - dari.dx;
    final path = Path()
      ..moveTo(dari.dx, dari.dy)
      ..cubicTo(
        dari.dx + dx * 0.4,
        dari.dy,
        dari.dx + dx * 0.6,
        ke.dy,
        ke.dx,
        ke.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = warna
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GarisPainter old) =>
      old.dari != dari || old.ke != ke || old.warna != warna;
}

class _JariPainter extends CustomPainter {
  const _JariPainter({required this.dari, required this.ke});

  final Offset dari;
  final Offset ke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(dari.dx, dari.dy)
      ..lineTo(ke.dx, ke.dy);
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 14) {
        canvas.drawPath(m.extractPath(d, math.min(d + 8, m.length)), paint);
      }
    }
    canvas.drawCircle(ke, 6, Paint()..color = _accent);
  }

  @override
  bool shouldRepaint(_JariPainter old) => old.dari != dari || old.ke != ke;
}
