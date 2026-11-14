import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/theme/menu_theme.dart';
import 'package:moci/app/theme/moci_colors.dart';

import '../../helpers/contrast.dart';

void main() {
  test('tinta di atas semua latar terang ≥ 4,5:1', () {
    for (final t in MenuTheme.values.where((t) => !t.dark)) {
      for (final c in t.colors) {
        expect(contrastRatio(MociColors.ink, c), greaterThanOrEqualTo(4.5), reason: '$t $c');
      }
    }
  });
  test('tinta lembut di atas putih ≥ 4,5:1', () {
    expect(contrastRatio(MociColors.inkSoft, MociColors.white), greaterThanOrEqualTo(4.5));
  });
  test('teks putih di layar gelap', () {
    expect(contrastRatio(MociColors.white, const Color(0xFF3B3170)), greaterThanOrEqualTo(4.5));
    expect(contrastRatio(MociColors.white, const Color(0xFF241D4A)), greaterThanOrEqualTo(4.5));
    expect(contrastRatio(MociColors.white, const Color(0xFF3E3180)), greaterThanOrEqualTo(4.5));
    // Ujung bawah gradien Istirahat hanya boleh memuat teks besar (≥ 24 pt tebal).
    expect(contrastRatio(MociColors.white, const Color(0xFF7C6BD6)), greaterThanOrEqualTo(3.0));
  });
}
