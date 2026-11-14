import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/theme/menu_theme.dart';

void main() {
  test('sambutan: gradasi langit vertikal dari prototipe', () {
    final g = MenuTheme.sambutan.decoration.gradient as LinearGradient;
    expect(g.begin, Alignment.topCenter);
    expect(g.end, Alignment.bottomCenter);
    expect(g.colors, const [
      Color(0xFF74C4FF),
      Color(0xFFB5E2FF),
      Color(0xFFDDF3FF),
    ]);
    expect(g.stops, const [0, 0.6, 1]);
    expect(MenuTheme.sambutan.shadow, const Color(0xFF8EC5EE));
  });
}
