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
  ConsumerState<TracingBoard> createState() => _TracingBoardState();
}

typedef _GuideView = ({Offset pos, bool idle, int num, bool show});

final class _TracingBoardState extends ConsumerState<TracingBoard>
    with TickerProviderStateMixin {
  static const box = 520.0;
  static const mociSize = 86.0;

  late TracingSession _session;
  final _revisi = ValueNotifier<int>(0);
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
  late final Listenable _repaint = Listenable.merge([_revisi, _flow, _burst]);

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
  void didUpdateWidget(TracingBoard old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.paths, widget.paths)) {
      _session = TracingSession(TraceGuide.fromPaths(widget.paths));
      _drag = false;
      _burstAt = null;
      _syncGuide();
      _revisi.value++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _laporProgres();
      });
    }
  }

  @override
  void dispose() {
    _revisi.dispose();
    _guide.dispose();
    _flow.dispose();
    _burst.dispose();
    _nudge.dispose();
    super.dispose();
  }

  void _laporProgres() {
    widget.onProgress?.call(_session.goresan, _session.guide.strokes.length);
  }

  void _syncGuide() {
    _guide.value = (
      pos: _session.pandu,
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
    final langkah = _session.gerak(e.localPosition);
    _syncGuide();
    switch (langkah) {
      case TraceStep.tetap:
        break;
      case TraceStep.maju:
        _revisi.value++;
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
    _revisi.value++;
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
              child: RepaintBoundary(
                child: Listener(
                  key: TracingBoard.surfaceKey,
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _down,
                  onPointerMove: _move,
                  onPointerUp: (_) => _up(),
                  onPointerCancel: (_) => _up(),
                  child: CustomPaint(
                    painter: _BoardPainter(
                      session: _session,
                      ink: widget.ink,
                      burstAt: _burstAt,
                      burst: _burst,
                      flow: _flow,
                      reduced: reduced,
                      repaint: _repaint,
                    ),
                  ),
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

final class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.session,
    required this.ink,
    required this.burstAt,
    required this.burst,
    required this.flow,
    required this.reduced,
    required Listenable repaint,
  }) : super(repaint: repaint);

  static const _box = 520.0;
  static const _paper = Color(0xFFFFFDFB);
  static const _line = Color(0xFFCFE3FF);
  static const _mid = Color(0xFFFFC9BD);
  static const _shadow = Color(0xFFECE7F8);
  static const _active = Color(0xFF4C3F86);
  static const _yellow = Color(0xFFFFD43B);

  final TracingSession session;
  final Color ink;
  final Offset? burstAt;
  final Animation<double> burst;
  final Animation<double> flow;
  final bool reduced;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, _box, _box),
      const Radius.circular(20),
    );
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRRect(rrect, Paint()..color = _paper);

    final garis = Paint()
      ..color = _line
      ..strokeWidth = 3;
    canvas
      ..drawLine(const Offset(20, 70), const Offset(500, 70), garis)
      ..drawLine(const Offset(20, 450), const Offset(500, 450), garis);
    final tengah = Paint()
      ..color = _mid
      ..strokeWidth = 3;
    for (var x = 20.0; x < 500; x += 24) {
      canvas.drawLine(
        Offset(x, 260),
        Offset(math.min(x + 12, 500), 260),
        tengah,
      );
    }

    final strokes = session.guide.strokes;
    if (strokes.isEmpty) {
      canvas.restore();
      return;
    }

    // Jalur bayangan semua goresan.
    final bayangan = Paint()
      ..color = _shadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 66
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final s in strokes) {
      canvas.drawPath(_polyline(s.points), bayangan);
    }

    final selesai = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < session.goresan && i < strokes.length; i++) {
      final s = strokes[i];
      canvas.drawPath(_polyline(s.points), selesai);
      _bintangSepanjang(canvas, s.points);
    }

    if (!session.selesai && session.goresan < strokes.length) {
      final aktif = strokes[session.goresan];
      final penuh = _polyline(aktif.points);
      canvas.drawPath(
        penuh,
        Paint()
          ..color = _active
          ..style = PaintingStyle.stroke
          ..strokeWidth = 66
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final sampai = aktif.points[session.titik].jarak;
      final jalan = _slice(aktif.points, 0, sampai);
      canvas.drawPath(jalan, selesai);
      _bintangSepanjang(canvas, _potong(aktif.points, sampai));
      _dashKuning(canvas, aktif);
      _nomorBerikut(canvas, strokes);
      _panahKuning(canvas, aktif);
      _bintangTujuan(canvas, aktif.points.last.offset);
    }

    if (burstAt != null && !reduced) {
      _ledakan(canvas, burstAt!);
    }
    canvas.restore();
  }

  void _dashKuning(Canvas canvas, TraceStroke stroke) {
    final total = stroke.length;
    if (total <= 0) return;
    final fase = reduced ? 0.0 : flow.value * 30;
    final paint = Paint()
      ..color = _yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (var d = -fase; d < total; d += 30) {
      final a = math.max(0.0, d);
      final b = math.min(total, d + 14);
      if (b <= a) continue;
      canvas.drawPath(_slice(stroke.points, a, b), paint);
    }
  }

  void _nomorBerikut(Canvas canvas, List<TraceStroke> strokes) {
    final aktif = strokes[session.goresan];
    final awal = aktif.points.isEmpty ? Offset.zero : aktif.points.first.offset;
    for (var i = session.goresan + 1; i < strokes.length; i++) {
      final s = strokes[i];
      if (s.points.isEmpty) continue;
      final p = s.points.first.offset;
      if ((p - awal).distance < 2) continue;
      final pusat = p;
      canvas.drawCircle(pusat, 19, Paint()..color = MociColors.white);
      canvas.drawCircle(
        pusat,
        19,
        Paint()
          ..color = const Color(0xFFB9AEE0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      _teks(canvas, '${i + 1}', pusat, const Color(0xFF4C3F86));
    }
  }

  void _panahKuning(Canvas canvas, TraceStroke stroke) {
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
        ..rotate(sudut);
      final panah = Path()
        ..moveTo(-7, -12)
        ..lineTo(6, 0)
        ..lineTo(-7, 12);
      canvas
        ..drawPath(
          panah,
          Paint()
            ..color = MociColors.ink.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        )
        ..drawPath(
          panah,
          Paint()
            ..color = _yellow
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        )
        ..restore();
    }
  }

  void _bintangTujuan(Canvas canvas, Offset p) {
    canvas.drawCircle(p, 34, Paint()..color = _yellow);
    _bintang(canvas, p, 33, MociColors.starFill, MociColors.starStroke);
  }

  void _ledakan(Canvas canvas, Offset p) {
    final t = burst.value;
    if (t <= 0) return;
    final pudar = (1 - t).clamp(0.0, 1.0);
    canvas.drawCircle(
      p,
      50 + 40 * t,
      Paint()
        ..color = _yellow.withValues(alpha: pudar)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    _bintang(
      canvas,
      p,
      30 + 20 * t,
      MociColors.starFill,
      MociColors.starStroke,
      alpha: pudar,
    );
  }

  void _bintangSepanjang(Canvas canvas, List<TracePoint> pts) {
    for (var i = 0; i < pts.length; i += 8) {
      _bintang(
        canvas,
        pts[i].offset,
        7,
        MociColors.white,
        MociColors.white,
        alpha: 0.55,
      );
    }
  }

  void _bintang(
    Canvas canvas,
    Offset p,
    double r,
    Color isi,
    Color garis, {
    double alpha = 1,
  }) {
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
    path.close();
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = isi.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        path,
        Paint()
          ..color = garis.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
  }

  void _teks(Canvas canvas, String teks, Offset pusat, Color warna) {
    final painter = TextPainter(
      text: TextSpan(
        text: teks,
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: warna,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      pusat - Offset(painter.width / 2, painter.height / 2),
    );
  }

  Path _polyline(List<TracePoint> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.x, pts.first.y);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].x, pts[i].y);
    }
    return path;
  }

  /// Potongan jalur antara jarak [a] dan [b].
  Path _slice(List<TracePoint> pts, double a, double b) {
    final path = Path();
    if (pts.length < 2 || b <= a) return path;
    final mulai = _titikPada(pts, a);
    path.moveTo(mulai.dx, mulai.dy);
    for (var i = 1; i < pts.length; i++) {
      if (pts[i].jarak <= a) continue;
      if (pts[i].jarak >= b) {
        final akhir = _titikPada(pts, b);
        path.lineTo(akhir.dx, akhir.dy);
        break;
      }
      path.lineTo(pts[i].x, pts[i].y);
    }
    return path;
  }

  List<TracePoint> _potong(List<TracePoint> pts, double sampai) => [
    for (final p in pts)
      if (p.jarak <= sampai) p,
  ];

  Offset _titikPada(List<TracePoint> pts, double jarak) {
    if (jarak <= 0) return pts.first.offset;
    for (var i = 1; i < pts.length; i++) {
      final b = pts[i];
      if (b.jarak < jarak) continue;
      final a = pts[i - 1];
      final span = b.jarak - a.jarak;
      if (span <= 0) return b.offset;
      final t = (jarak - a.jarak) / span;
      return Offset(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
    }
    return pts.last.offset;
  }

  @override
  bool shouldRepaint(_BoardPainter old) =>
      old.session != session ||
      old.ink != ink ||
      old.burstAt != burstAt ||
      old.reduced != reduced;
}
