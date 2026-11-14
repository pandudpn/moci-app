import 'dart:math' as math;

import '../../core/lang.dart';

/// Jamak nama benda hitung dalam bahasa Inggris, hasil port `plural` di
/// prototipe `Angka.dc.html`. Bahasa Indonesia tidak berjamak.
String bendaJamak(String nama, AppLang lang) {
  if (lang == AppLang.id) return nama;
  const khusus = {
    'Fish': 'fish',
    'Strawberry': 'strawberries',
    'Butterfly': 'butterflies',
    'Balloons': 'balloons',
  };
  return khusus[nama] ?? '${nama.toLowerCase()}s';
}

/// Kisi benda untuk [n] benda: banyak kolom, sisi tiap sel, dan jaraknya.
({int columns, double size, double gap}) hitungGrid(int n) {
  if (n <= 10) {
    final size = n <= 3 ? 130.0 : (n <= 6 ? 110.0 : 96.0);
    return (columns: math.max(1, math.min(n, 5)), size: size, gap: 22.0);
  }
  if (n <= 20) return (columns: 10, size: 54, gap: 10);
  return (columns: 10, size: 46, gap: 10);
}
