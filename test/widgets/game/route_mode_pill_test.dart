import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('pil rute: tab aktif dari lokasi, ketukan mengganti rute', (
    t,
  ) async {
    final router = await pumpApp(t, initialLocation: '/huruf/tulis');
    await t.tap(find.text('Kenali'));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/huruf',
    );
  });
}
