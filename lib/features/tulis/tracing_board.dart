import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_motion.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/sfx.dart';
import '../../widgets/moci_mascot.dart';
import 'tracing_engine.dart';

/// Papan menulis 520 × 520: jalur bayangan, goresan aktif, panah kuning,
/// bintang tujuan, dan Moci sebagai panduan jari.
class TracingBoard extends ConsumerStatefulWidget {
  const TracingBoard({
    super.key,
    required this.paths,
    required this.ink,
    required this.semanticLabel,
    this.onStrokeDone,
    this.onDone,
    this.onWrongStart,
    this.onProgress,
  });

  static const surfaceKey = ValueKey('tracing-surface');
  static const staticLayerKey = ValueKey('tracing-static-layer');
  static const hintLayerKey = ValueKey('tracing-hint-layer');
  static const inkLayerKey = ValueKey('tracing-ink-layer');

  final List<String> paths;
  final Color ink;
  final String semanticLabel;

  /// Dipanggil dengan indeks goresan yang baru selesai.
  final ValueChanged<int>? onStrokeDone;
  final VoidCallback? onDone;

  /// Jari mulai jauh dari titik pandu.
  final VoidCallback? onWrongStart;

  /// Dipanggil saat goresan berganti dan sekali saat papan dipasang.
  final void Function(int goresan, int total)? onProgress;

  @override
  TracingBoardState createState() => TracingBoardState();
}

typedef _GuideView = ({Offset pos, bool idle, int num, bool show});

/// Keadaan papan menulis. [session] dibuka supaya tes bisa memeriksa tinta dan
/// kemajuan tanpa golden.
final class TracingBoardState extends ConsumerState<TracingBoard>
    with TickerProviderStateMixin {
  static const box = 520.0;
  static const mociSize = 86.0;

  late TracingSession _session;

  /// Lapisan statis hanya berubah saat ada goresan yang selesai.
  final _statis = ValueNotifier<int>(0);

  /// Lapisan tinta berubah tiap gerakan jari.
  final _tinta = ValueNotifier<int>(0);
  final _guide = ValueNotifier<_GuideView>((
    pos: Offset.zero,
    idle: true,
    num: 1,
    show: false,
  ));

  late final _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _nudge = AnimationController(
    vsync: this,
    duration: MociMotion.shake,
  );
  late final Listenable _lukisStatis = _statis;
  late final Listenable _lukisIsyarat = Listenable.merge([
    _flow,
    _statis,
    _tinta,
  ]);
  late final Listenable _lukisTinta = Listenable.merge([_tinta, _burst]);

  TracingSession get session => _session;

  Offset? _burstAt;
  bool _drag = false;

  @override
  void initState() {
    super.initState();
    _session = TracingSession(TraceGuide.fromPaths(widget.paths));
    _syncGuide();
    _burst.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _burstAt = null);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _laporProgres();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _flow.stop();
    } else if (!_flow.isAnimating) {
      _flow.repeat();
    }
  }

  @override
  void didUpdateWidget(TracingBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.paths, widget.paths)) {
      _session = TracingSession(TraceGuide.fromPaths(widget.paths));
      _drag = false;
      _burstAt = null;
      _syncGuide();
      _statis.value++;
      _tinta.value++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _laporProgres();
      });
    }
  }

  @override
  void dispose() {
    _statis.dispose();
    _tinta.dispose();
    _guide.dispose();
    _flow.dispose();
    _burst.dispose();
    _nudge.dispose();
    super.dispose();
  }

  void _laporProgres() {
    widget.onProgress?.call(_session.goresan, _session.guide.strokes.length);
  }

  /// Moci mengikuti ujung tinta saat jari menempel, selain itu menunggu di
  /// titik pandu.
  void _syncGuide() {
    _guide.value = (
      pos: _drag ? _session.ujungTinta : _session.pandu,
      idle: !_drag && _session.titik == 0,
      num: _session.goresan + 1,
      show: !_session.selesai && !_session.guide.kosong,
    );
  }

  void _down(PointerDownEvent e) {
    if (_session.selesai) return;
    if (!_session.mulai(e.localPosition)) {
      widget.onWrongStart?.call();
      if (!MediaQuery.disableAnimationsOf(context)) {
        _nudge.forward(from: 0);
      }
      return;
    }
    _drag = true;
    _syncGuide();
  }

  void _move(PointerMoveEvent e) {
    if (!_drag) return;
    final sebelum = (_session.jarakTinta, _session.goresan, _session.selesai);
    final langkah = _session.gerak(e.localPosition);
    final sesudah = (_session.jarakTinta, _session.goresan, _session.selesai);
    // Tinta mengikuti jari walau belum ada sampel baru yang diterima.
    if (sesudah != sebelum) _tinta.value++;
    _syncGuide();
    switch (langkah) {
      case TraceStep.tetap:
      case TraceStep.maju:
        break;
      case TraceStep.goresanSelesai:
        _selesaiGoresan(_session.goresan - 1);
        _laporProgres();
      case TraceStep.selesai:
        _selesaiGoresan(_session.goresan);
    }
  }

  void _up() {
    _drag = false;
    _syncGuide();
  }

  void _selesaiGoresan(int index) {
    _statis.value++;
    _tinta.value++;
    ref.read(audioServiceProvider).playSfx(Sfx.benar);
    widget.onStrokeDone?.call(index);
    if (_session.selesai) {
      widget.onDone?.call();
      return;
    }
    final stroke = _session.guide.strokes[index];
    if (!MediaQuery.disableAnimationsOf(context) && stroke.points.isNotEmpty) {
      setState(() => _burstAt = stroke.points.last.offset);
      _burst.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: box,
      height: box,
      child: Semantics(
        container: true,
        label: widget.semanticLabel,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Listener(
                key: TracingBoard.surfaceKey,
                behavior: HitTestBehavior.opaque,
                onPointerDown: _down,
                onPointerMove: _move,
                onPointerUp: (_) => _up(),
                onPointerCancel: (_) => _up(),
                child: Stack(
                  children: [
                    // Kertas, bayangan, dan tinta goresan selesai: hanya
                    // dilukis ulang saat ada goresan yang selesai.
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          key: TracingBoard.staticLayerKey,
                          painter: TracingPainter(
                            session: _session,
                            ink: widget.ink,
                            repaint: _lukisStatis,
                          ),
                        ),
                      ),
                    ),
                    // Jalur pandu bergerak: hanya lapisan ini yang dilukis
                    // tiap frame.
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          key: TracingBoard.hintLayerKey,
                          painter: _HintPainter(
                            session: _session,
                            flow: _flow,
                            reduced: reduced,
                            repaint: _lukisIsyarat,
                          ),
                        ),
                      ),
                    ),
                    // Tinta goresan aktif dan ledakan bintang.
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          key: TracingBoard.inkLayerKey,
                          painter: _InkPainter(
                            session: _session,
                            ink: widget.ink,
                            burstAt: _burstAt,
                            burst: _burst,
                            reduced: reduced,
                            repaint: _lukisTinta,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<_GuideView>(
              valueListenable: _guide,
              builder: (context, g, _) {
                if (!g.show) return const SizedBox.shrink();
                return Positioned(
                  left: g.pos.dx - mociSize / 2,
                  top: g.pos.dy - mociSize / 2,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _nudge,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_goyang(reduced), 0),
                        child: child,
                      ),
                      child: SizedBox(
                        width: mociSize,
                        height: mociSize,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            if (g.idle)
                              const SizedBox(
                                key: ValueKey('tracing-idle-ring'),
                                width: 84,
                                height: 84,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: MociColors.correct,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            const MociMascot(size: mociSize),
                            Positioned(
                              left: 60,
                              top: -10,
                              child: _NumBadge(num: g.num),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _goyang(bool reduced) {
    if (reduced) return 0;
    final v = _nudge.value;
    if (v == 0 || v == 1) return 0;
    return math.sin(v * math.pi * 6) * (1 - v) * 14;
  }
}

final class _NumBadge extends StatelessWidget {
  const _NumBadge({required this.num});

  final int num;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF4C3F86),
          shape: BoxShape.circle,
          border: Border.all(color: MociColors.white, width: 3),
        ),
        child: Center(
          child: Text(
            '$num',
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MociColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Warna dan kuas papan yang dipakai ketiga lapisan.
abstract final class _BoardStyle {
  static const box = 520.0;
  static const paper = Color(0xFFFFFDFB);
  static const line = Color(0xFFCFE3FF);
  static const mid = Color(0xFFFFC9BD);
  static const shadow = Color(0xFFECE7F8);
  static const active = Color(0xFF4C3F86);
  static const badge = Color(0xFFB9AEE0);
  static const yellow = Color(0xFFFFD43B);

  static final kertas = Paint()..color = paper;
  static final garis = Paint()
    ..color = line
    ..strokeWidth = 3;
  static final tengah = Paint()
    ..color = mid
    ..strokeWidth = 3;
  static final bayangan = Paint()
    ..color = shadow
    ..style = PaintingStyle.stroke
    ..strokeWidth = 66
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final jalurAktif = Paint()
    ..color = active
    ..style = PaintingStyle.stroke
    ..strokeWidth = 66
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final kuning = Paint()
    ..color = yellow
    ..style = PaintingStyle.stroke
    ..strokeWidth = 7
    ..strokeCap = StrokeCap.round;
  static final bintangPutih = Paint()
    ..color = MociColors.white.withValues(alpha: 0.55);
  static final bintangPutihGaris = Paint()
    ..color = MociColors.white.withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeJoin = StrokeJoin.round;
  static final tujuanIsi = Paint()..color = yellow;
  static final bintangIsi = Paint()..color = MociColors.starFill;
  static final bintangGaris = Paint()
    ..color = MociColors.starStroke
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeJoin = StrokeJoin.round;
  static final nomorIsi = Paint()..color = MociColors.white;
  static final nomorGaris = Paint()
    ..color = badge
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  static final panahLuar = Paint()
    ..color = MociColors.ink.withValues(alpha: 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final panahDalam = Paint()
    ..color = yellow
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// Klip sudut bulat papan; selalu dipasangkan dengan `canvas.restore()`.
  static void potong(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, box, box),
      const Radius.circular(20),
    );
    canvas
      ..save()
      ..clipRRect(rrect);
  }

  static void kertasDasar(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, box, box),
      const Radius.circular(20),
    );
    canvas.drawRRect(rrect, kertas);
  }
}

/// Geometri papan: polilin jalur, bintang, potongan garis putus-putus, panah,
/// dan teks nomor. Dihitung sekali per panduan, bukan tiap lukis atau frame.
final class _BoardArtwork {
  _BoardArtwork._(this.guide);

  factory _BoardArtwork.of(TraceGuide guide) =>
      _cache[guide] ??= _BoardArtwork._(guide);

  static final _cache = Expando<_BoardArtwork>();
  static final panah = Path()
    ..moveTo(-7, -12)
    ..lineTo(6, 0)
    ..lineTo(-7, 12);

  final TraceGuide guide;

  List<TraceStroke> get strokes => guide.strokes;

  List<Path>? _jalur;
  List<List<({double jarak, Path bentuk})>>? _bintang;
  List<List<({double awal, double akhir})>>? _dash;
  List<TextPainter>? _nomor;
  List<Offset>? _mulai;
  List<Offset>? _tujuan;

  List<Path> get jalur =>
      _jalur ??= [for (final s in strokes) _polilin(s.points)];

  List<List<({double jarak, Path bentuk})>> get bintang =>
      _bintang ??= [for (final s in strokes) _bintangSepanjang(s.points)];

  List<List<({double awal, double akhir})>> get dash => _dash ??= [
    for (final s in strokes)
      [
        for (var d = 0.0; d < s.length; d += 30)
          (awal: d, akhir: math.min(s.length, d + 14)),
      ],
  ];

  List<TextPainter> get nomor =>
      _nomor ??= [for (var i = 0; i < strokes.length; i++) _teks('${i + 1}')];

  List<Offset> get mulai => _mulai ??= [
    for (final s in strokes)
      s.points.isEmpty ? Offset.zero : s.points.first.offset,
  ];

  List<Offset> get tujuan => _tujuan ??= [
    for (final s in strokes)
      s.points.isEmpty ? Offset.zero : s.points.last.offset,
  ];

  List<Path>? _tujuanBintang;

  List<Path> get tujuanBintang =>
      _tujuanBintang ??= [for (final p in tujuan) bintangBentuk(p, 33)];

  static Path _polilin(List<TracePoint> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.x, pts.first.y);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].x, pts[i].y);
    }
    return path;
  }

  static List<({double jarak, Path bentuk})> _bintangSepanjang(
    List<TracePoint> pts,
  ) => [
    for (var i = 0; i < pts.length; i += 8)
      (jarak: pts[i].jarak, bentuk: bintangBentuk(pts[i].offset, 7)),
  ];

  static TextPainter _teks(String teks) => TextPainter(
    text: TextSpan(
      text: teks,
      style: const TextStyle(
        fontFamily: 'Fredoka',
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: _BoardStyle.active,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Bentuk bintang lima sudut berpusat di [p].
  static Path bintangBentuk(Offset p, double r) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final luar = -math.pi / 2 + i * 2 * math.pi / 5;
      final dalam = luar + math.pi / 5;
      final a = p + Offset(math.cos(luar), math.sin(luar)) * r;
      final b = p + Offset(math.cos(dalam), math.sin(dalam)) * (r * 0.42);
      if (i == 0) {
        path.moveTo(a.dx, a.dy);
      } else {
        path.lineTo(a.dx, a.dy);
      }
      path.lineTo(b.dx, b.dy);
    }
    return path..close();
  }
}

/// Jalur dari awal goresan sampai jarak [sampai].
Path _jalurSampai(List<TracePoint> pts, double sampai) {
  final path = Path();
  if (pts.isEmpty) return path;
  path.moveTo(pts.first.x, pts.first.y);
  for (var i = 1; i < pts.length; i++) {
    if (pts[i].jarak <= sampai) {
      path.lineTo(pts[i].x, pts[i].y);
      continue;
    }
    final akhir = titikPadaJalur(pts, sampai);
    path.lineTo(akhir.dx, akhir.dy);
    break;
  }
  return path;
}

/// Lapisan diam: kertas, garis bantu, bayangan jalur, dan tinta goresan yang
/// sudah selesai.
final class TracingPainter extends CustomPainter {
  TracingPainter({required this.session, required this.ink, super.repaint})
    : _artwork = _BoardArtwork.of(session.guide),
      _tinta = Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 60
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

  final TracingSession session;
  final Color ink;
  final _BoardArtwork _artwork;
  final Paint _tinta;

  /// Goresan yang dilukis sebagai tinta selesai, termasuk goresan terakhir
  /// setelah huruf selesai.
  int get goresanBertinta => session.goresanSelesai;

  @override
  void paint(Canvas canvas, Size size) {
    _BoardStyle.potong(canvas);
    _BoardStyle.kertasDasar(canvas);
    canvas
      ..drawLine(const Offset(20, 70), const Offset(500, 70), _BoardStyle.garis)
      ..drawLine(
        const Offset(20, 450),
        const Offset(500, 450),
        _BoardStyle.garis,
      );
    for (var x = 20.0; x < 500; x += 24) {
      canvas.drawLine(
        Offset(x, 260),
        Offset(math.min(x + 12, 500), 260),
        _BoardStyle.tengah,
      );
    }

    final strokes = _artwork.strokes;
    if (strokes.isEmpty) {
      canvas.restore();
      return;
    }
    for (final jalur in _artwork.jalur) {
      canvas.drawPath(jalur, _BoardStyle.bayangan);
    }
    final bertinta = math.min(goresanBertinta, strokes.length);
    for (var i = 0; i < bertinta; i++) {
      canvas.drawPath(_artwork.jalur[i], _tinta);
      for (final b in _artwork.bintang[i]) {
        canvas
          ..drawPath(b.bentuk, _BoardStyle.bintangPutih)
          ..drawPath(b.bentuk, _BoardStyle.bintangPutihGaris);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(TracingPainter old) =>
      old.session != session || old.ink != ink;
}

/// Lapisan isyarat: jalur pandu, garis putus-putus bergerak, nomor goresan
/// berikutnya, panah, dan bintang tujuan.
final class _HintPainter extends CustomPainter {
  _HintPainter({
    required this.session,
    required this.flow,
    required this.reduced,
    required Listenable repaint,
  }) : _artwork = _BoardArtwork.of(session.guide),
       super(repaint: repaint);

  final TracingSession session;
  final Animation<double> flow;
  final bool reduced;
  final _BoardArtwork _artwork;

  @override
  void paint(Canvas canvas, Size size) {
    final strokes = _artwork.strokes;
    final i = session.goresan;
    if (strokes.isEmpty || session.selesai || i >= strokes.length) return;
    _BoardStyle.potong(canvas);
    final stroke = strokes[i];
    canvas.drawPath(_artwork.jalur[i], _BoardStyle.jalurAktif);
    _dash(canvas, i, stroke);
    _nomor(canvas, i);
    _panah(canvas, stroke);
    _tujuan(canvas, i);
    canvas.restore();
  }

  /// Tiap potongan garis putus-putus dilukis sebagai satu garis lurus pendek
  /// di sepanjang jalur, jadi tidak ada Path yang dibangun per frame.
  void _dash(Canvas canvas, int i, TraceStroke stroke) {
    if (stroke.length <= 0) return;
    final fase = reduced ? 0.0 : flow.value * 30;
    for (final potong in _artwork.dash[i]) {
      final a = math.max(0.0, potong.awal - fase);
      final b = math.min(stroke.length, potong.akhir - fase);
      if (b <= a) continue;
      canvas.drawLine(
        titikPadaJalur(stroke.points, a),
        titikPadaJalur(stroke.points, b),
        _BoardStyle.kuning,
      );
    }
  }

  void _nomor(Canvas canvas, int aktif) {
    final awal = _artwork.mulai[aktif];
    for (var i = aktif + 1; i < _artwork.strokes.length; i++) {
      final p = _artwork.mulai[i];
      if ((p - awal).distance < 2) continue;
      canvas
        ..drawCircle(p, 19, _BoardStyle.nomorIsi)
        ..drawCircle(p, 19, _BoardStyle.nomorGaris);
      final teks = _artwork.nomor[i];
      teks.paint(canvas, p - Offset(teks.width / 2, teks.height / 2));
    }
  }

  void _panah(Canvas canvas, TraceStroke stroke) {
    final pts = stroke.points;
    if (pts.length < 5) return;
    var k = 1;
    for (var d = 52.0; d < stroke.length - 30; d += 58) {
      while (k < pts.length - 1 && pts[k].jarak < d) {
        k++;
      }
      if (k <= session.titik + 10) continue;
      final a = pts[math.max(0, k - 2)];
      final b = pts[math.min(pts.length - 1, k + 2)];
      final sudut = math.atan2(b.y - a.y, b.x - a.x);
      canvas
        ..save()
        ..translate(pts[k].x, pts[k].y)
        ..rotate(sudut)
        ..drawPath(_BoardArtwork.panah, _BoardStyle.panahLuar)
        ..drawPath(_BoardArtwork.panah, _BoardStyle.panahDalam)
        ..restore();
    }
  }

  void _tujuan(Canvas canvas, int i) {
    if (_artwork.strokes[i].points.isEmpty) return;
    final bintang = _artwork.tujuanBintang[i];
    canvas
      ..drawCircle(_artwork.tujuan[i], 34, _BoardStyle.tujuanIsi)
      ..drawPath(bintang, _BoardStyle.bintangIsi)
      ..drawPath(bintang, _BoardStyle.bintangGaris);
  }

  @override
  bool shouldRepaint(_HintPainter old) =>
      old.session != session || old.reduced != reduced;
}

/// Lapisan tinta goresan aktif: ujungnya mengikuti jari, plus ledakan bintang
/// saat goresan selesai.
final class _InkPainter extends CustomPainter {
  _InkPainter({
    required this.session,
    required this.ink,
    required this.burstAt,
    required this.burst,
    required this.reduced,
    required Listenable repaint,
  }) : _artwork = _BoardArtwork.of(session.guide),
       _tinta = Paint()
         ..color = ink
         ..style = PaintingStyle.stroke
         ..strokeWidth = 60
         ..strokeCap = StrokeCap.round
         ..strokeJoin = StrokeJoin.round,
       super(repaint: repaint);

  final TracingSession session;
  final Color ink;
  final Offset? burstAt;
  final Animation<double> burst;
  final bool reduced;
  final _BoardArtwork _artwork;
  final Paint _tinta;

  Path? _jalur;
  int _jalurGoresan = -1;
  double _jalurJarak = -1;

  @override
  void paint(Canvas canvas, Size size) {
    _BoardStyle.potong(canvas);
    final i = session.goresan;
    final sampai = session.jarakTinta;
    final adaGoresan = i < _artwork.strokes.length && !session.selesai;
    if (adaGoresan && _artwork.strokes.isNotEmpty) {
      canvas.drawPath(_tintaJalur(i, sampai), _tinta);
      for (final b in _artwork.bintang[i]) {
        if (b.jarak > sampai) break;
        canvas
          ..drawPath(b.bentuk, _BoardStyle.bintangPutih)
          ..drawPath(b.bentuk, _BoardStyle.bintangPutihGaris);
      }
    }
    if (burstAt != null && !reduced) _ledakan(canvas, burstAt!);
    canvas.restore();
  }

  /// Potongan tinta hanya dibangun ulang saat ujungnya berubah, jadi ledakan
  /// bintang tetap ringan tiap frame.
  Path _tintaJalur(int goresan, double sampai) {
    if (_jalur != null && _jalurGoresan == goresan && _jalurJarak == sampai) {
      return _jalur!;
    }
    _jalur = _jalurSampai(_artwork.strokes[goresan].points, sampai);
    _jalurGoresan = goresan;
    _jalurJarak = sampai;
    return _jalur!;
  }

  void _ledakan(Canvas canvas, Offset p) {
    final t = burst.value;
    if (t <= 0) return;
    final pudar = (1 - t).clamp(0.0, 1.0);
    canvas.drawCircle(
      p,
      50 + 40 * t,
      Paint()
        ..color = _BoardStyle.yellow.withValues(alpha: pudar)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    final bintang = _BoardArtwork.bintangBentuk(p, 30 + 20 * t);
    canvas
      ..drawPath(
        bintang,
        Paint()..color = MociColors.starFill.withValues(alpha: pudar),
      )
      ..drawPath(
        bintang,
        Paint()
          ..color = MociColors.starStroke.withValues(alpha: pudar)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_InkPainter old) =>
      old.session != session ||
      old.ink != ink ||
      old.burstAt != burstAt ||
      old.reduced != reduced;
}
