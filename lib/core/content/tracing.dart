/// Panduan menulis satu huruf atau angka di kotak persegi.
final class TracingSet {
  const TracingSet({this.versi = 1, this.kotak = 520, this.glyph = const {}});

  factory TracingSet.fromJson(Object? value) {
    if (value is! Map) {
      return const TracingSet();
    }
    final glyph = value['glyph'];
    return TracingSet(
      versi: value['versi'] is num ? (value['versi'] as num).toInt() : 1,
      kotak: value['kotak'] is num ? (value['kotak'] as num).toInt() : 520,
      glyph: glyph is Map
          ? {
              for (final e in glyph.entries)
                if (e.key is String) e.key as String: _strings(e.value),
            }
          : const {},
    );
  }

  final int versi;
  final int kotak;

  /// Path per goresan, urut sesuai arah menulis.
  final Map<String, List<String>> glyph;

  List<String> of(String huruf) => glyph[huruf] ?? const [];

  Map<String, Object?> toJson() => {
    'versi': versi,
    'kotak': kotak,
    'glyph': glyph,
  };
}

List<String> _strings(Object? value) => value is List
    ? [
        for (final e in value)
          if (e is String) e,
      ]
    : const <String>[];
