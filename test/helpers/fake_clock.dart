import 'package:moci/core/clock.dart';

class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  void advance(Duration d) => current = current.add(d);

  @override
  DateTime now() => current;
}
