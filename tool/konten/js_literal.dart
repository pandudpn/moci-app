/// Pembaca literal JavaScript dari snapshot prototipe.
///
/// Prototipe menyimpan datanya sebagai literal JS di dalam berkas `.dc.html`.
/// Berkas itu tidak bisa dijalankan dan tidak bisa dibaca `jsonDecode`, jadi
/// ekspor memakai parser kecil ini. Yang diterima hanya literal murni: array,
/// objek, string, angka, `true`, `false`, dan `null`. Identifier, pemanggilan
/// fungsi, dan operator ditolak supaya ekspor gagal keras, bukan diam-diam
/// menyimpan potongan teks.
library;

/// Membaca satu literal JS yang dimulai di [start].
///
/// Mengembalikan nilai hasil baca beserta posisi tepat sesudah literal.
/// Melempar [FormatException] berisi posisi dan potongan teks kalau isinya
/// bukan literal murni.
(Object?, int) parseJsLiteral(String source, int start) =>
    _Parser(source, start).parse();

class _Parser {
  _Parser(this.source, this.pos);

  final String source;
  int pos;

  (Object?, int) parse() {
    final value = _value();
    return (value, pos);
  }

  Object? _value() {
    _skipBlank();
    if (pos >= source.length) {
      _fail('literal terpotong');
    }
    final char = source[pos];
    return switch (char) {
      '[' => _array(),
      '{' => _object(),
      "'" || '"' => _string(),
      _ when _isDigit(char) || char == '-' || char == '+' || char == '.' =>
        _number(),
      _ when _isIdentifierStart(char) => _keyword(),
      _ => _fail('karakter tak terduga "$char"'),
    };
  }

  List<Object?> _array() {
    pos++; // [
    final items = <Object?>[];
    while (true) {
      _skipBlank();
      if (_match(']')) {
        return items;
      }
      if (items.isNotEmpty && !_match(',')) {
        _fail('butuh "," atau "]"');
      }
      _skipBlank();
      // Koma di akhir daftar: `[1, 2,]`.
      if (_match(']')) {
        return items;
      }
      items.add(_value());
    }
  }

  Map<String, Object?> _object() {
    pos++; // {
    final map = <String, Object?>{};
    while (true) {
      _skipBlank();
      if (_match('}')) {
        return map;
      }
      if (map.isNotEmpty && !_match(',')) {
        _fail('butuh "," atau "}"');
      }
      _skipBlank();
      // Koma di akhir daftar: `{a: 1,}`.
      if (_match('}')) {
        return map;
      }
      final key = _key();
      _skipBlank();
      if (!_match(':')) {
        _fail('butuh ":" sesudah kunci "$key"');
      }
      map[key] = _value();
    }
  }

  String _key() {
    if (pos >= source.length) {
      _fail('kunci objek terpotong');
    }
    final char = source[pos];
    if (char == "'" || char == '"') {
      return _string();
    }
    if (!_isIdentifierStart(char) && !_isDigit(char)) {
      _fail('kunci objek tak didukung');
    }
    final start = pos;
    while (pos < source.length &&
        (_isIdentifierPart(source[pos]) || _isDigit(source[pos]))) {
      pos++;
    }
    return source.substring(start, pos);
  }

  String _string() {
    final quote = source[pos++];
    final buffer = StringBuffer();
    while (true) {
      if (pos >= source.length) {
        _fail('string terpotong');
      }
      final char = source[pos++];
      if (char == quote) {
        return buffer.toString();
      }
      if (char != r'\') {
        buffer.write(char);
        continue;
      }
      if (pos >= source.length) {
        _fail('escape terpotong');
      }
      final escape = source[pos++];
      switch (escape) {
        case 'n':
          buffer.write('\n');
        case 'r':
          buffer.write('\r');
        case 't':
          buffer.write('\t');
        case 'b':
          buffer.write('\b');
        case 'f':
          buffer.write('\f');
        case 'v':
          buffer.write('\v');
        case '0':
          buffer.write('\x00');
        case 'u':
          buffer.write(_unicode());
        default:
          // JS membuang garis miring untuk escape yang tidak dikenal.
          buffer.write(escape);
      }
    }
  }

  String _unicode() {
    if (pos < source.length && source[pos] == '{') {
      final close = source.indexOf('}', pos);
      if (close < 0) {
        _fail('escape \\u{…} terpotong');
      }
      final digits = source.substring(pos + 1, close);
      final code = int.tryParse(digits, radix: 16);
      if (code == null || digits.isEmpty) {
        _fail('escape \\u{$digits} bukan heksadesimal');
      }
      pos = close + 1;
      return String.fromCharCode(code);
    }
    if (pos + 4 > source.length) {
      _fail('escape \\u terpotong');
    }
    final digits = source.substring(pos, pos + 4);
    final code = int.tryParse(digits, radix: 16);
    if (code == null) {
      _fail('escape \\u$digits bukan heksadesimal');
    }
    pos += 4;
    return String.fromCharCode(code);
  }

  num _number() {
    final start = pos;
    if (source[pos] == '-' || source[pos] == '+') {
      pos++;
    }
    var seenDigit = false;
    var seenDot = false;
    while (pos < source.length) {
      final char = source[pos];
      if (_isDigit(char)) {
        seenDigit = true;
        pos++;
      } else if (char == '.' && !seenDot) {
        seenDot = true;
        pos++;
      } else {
        break;
      }
    }
    if (!seenDigit) {
      _fail('angka tak lengkap');
    }
    if (pos < source.length && (source[pos] == 'e' || source[pos] == 'E')) {
      pos++;
      if (pos < source.length && (source[pos] == '+' || source[pos] == '-')) {
        pos++;
      }
      final expStart = pos;
      while (pos < source.length && _isDigit(source[pos])) {
        pos++;
      }
      if (pos == expStart) {
        _fail('eksponen tak lengkap');
      }
    }
    final text = source.substring(start, pos);
    if (!seenDot && !text.contains('e') && !text.contains('E')) {
      final value = int.tryParse(text);
      if (value != null) {
        return value;
      }
    }
    final value = double.tryParse(text);
    if (value == null) {
      pos = start;
      _fail('angka tak terbaca "$text"');
    }
    return value;
  }

  Object? _keyword() {
    final start = pos;
    while (pos < source.length && _isIdentifierPart(source[pos])) {
      pos++;
    }
    final word = source.substring(start, pos);
    return switch (word) {
      'true' => true,
      'false' => false,
      'null' => null,
      _ => _fail('identifier "$word" bukan literal'),
    };
  }

  void _skipBlank() {
    while (pos < source.length) {
      final char = source[pos];
      if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
        pos++;
        continue;
      }
      if (source.startsWith('//', pos)) {
        final lineEnd = source.indexOf('\n', pos);
        pos = lineEnd < 0 ? source.length : lineEnd + 1;
        continue;
      }
      if (source.startsWith('/*', pos)) {
        final close = source.indexOf('*/', pos + 2);
        if (close < 0) {
          _fail('komentar blok tidak ditutup');
        }
        pos = close + 2;
        continue;
      }
      return;
    }
  }

  bool _match(String char) {
    if (pos < source.length && source[pos] == char) {
      pos++;
      return true;
    }
    return false;
  }

  Never _fail(String message) {
    final from = pos - 12 < 0 ? 0 : pos - 12;
    final to = pos + 12 > source.length ? source.length : pos + 12;
    final cuplikan = source.substring(from, to).replaceAll(RegExp(r'\s+'), ' ');
    throw FormatException('$message di posisi $pos (…$cuplikan…)', source, pos);
  }

  static bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }

  static bool _isIdentifierStart(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5a) ||
        (code >= 0x61 && code <= 0x7a) ||
        char == '_' ||
        char == r'$';
  }

  static bool _isIdentifierPart(String char) =>
      _isIdentifierStart(char) || _isDigit(char);
}
