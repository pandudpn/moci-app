import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/tulis/tracing_engine.dart';

void main() {
  test('garis lurus disampel tiap 4 unit', () {
    final s = TraceStroke.fromSvgPath('M0 0L100 0');
    expect(s.points.length, 26);
    expect(s.points[1].jarak, 4);
    expect(s.length, 100);
  });
  test('perintah H dan V ikut dibaca', () {
    final s = TraceStroke.fromSvgPath('M0 0L40 0H80V40');
    expect(s.length, 120);
    expect(s.points.last.offset, const Offset(80, 40));
  });
  test('kurva C disampel halus', () {
    final s = TraceStroke.fromSvgPath('M0 0C0 60 100 60 100 0');
    expect(s.points.length, greaterThan(30));
    expect(s.length, inInclusiveRange(90, 160));
  });
  test('mulai hanya di dekat titik pandu', () {
    final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0']));
    expect(sesi.mulai(const Offset(80, 0)), isFalse);
    expect(sesi.mulai(const Offset(10, 0)), isTrue);
  });
  test('gerak mundur dan lompatan jauh ditolak', () {
    final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0']))
      ..mulai(const Offset(0, 0));
    expect(sesi.gerak(const Offset(-20, 0)), TraceStep.tetap);
    expect(sesi.gerak(const Offset(500, 200)), TraceStep.tetap);
    expect(sesi.titik, 0);
  });
  test('kemajuan mengikuti jari tapi tidak melewati 40 unit', () {
    final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0']))
      ..mulai(const Offset(0, 0));
    expect(sesi.gerak(const Offset(60, 0)), TraceStep.maju);
    expect(sesi.titik, 10);
    expect(sesi.kemajuan, closeTo(0.4, 0.001));
  });
  test('goresan selesai di 97% lalu pindah ke goresan berikutnya', () {
    final sesi = TracingSession(
      TraceGuide.fromPaths(const ['M0 0L100 0', 'M0 100L100 100']),
    )..mulai(const Offset(0, 0));
    var step = TraceStep.tetap;
    for (var x = 20; x <= 100 && sesi.goresan == 0; x += 20) {
      final s = sesi.gerak(Offset(x.toDouble(), 0));
      if (s != TraceStep.tetap) step = s;
    }
    expect(step, TraceStep.goresanSelesai);
    expect(sesi.goresan, 1);
    expect(sesi.titik, 0);
    expect(sesi.mulai(const Offset(0, 100)), isTrue);
    for (var x = 20; x <= 100 && !sesi.selesai; x += 20) {
      final s = sesi.gerak(Offset(x.toDouble(), 100));
      if (s != TraceStep.tetap) step = s;
    }
    expect(step, TraceStep.selesai);
    expect(sesi.selesai, isTrue);
  });
  test('ulang mengembalikan ke goresan pertama', () {
    final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0']))
      ..mulai(const Offset(0, 0))
      ..gerak(const Offset(60, 0));
    sesi.ulang();
    expect((sesi.goresan, sesi.titik, sesi.selesai), (0, 0, false));
    expect(sesi.mulai(const Offset(0, 0)), isTrue);
  });
}
