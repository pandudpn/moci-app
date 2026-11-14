import '../lang.dart';

const _idSatuan = [
  'nol',
  'satu',
  'dua',
  'tiga',
  'empat',
  'lima',
  'enam',
  'tujuh',
  'delapan',
  'sembilan',
];

const _enSatuan = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen',
];

/// Puluhan Inggris, indeks = angka depan. Prototipe hanya sampai lima puluh.
const _enPuluhan = ['', '', 'twenty', 'thirty', 'forty', 'fifty'];

/// Kata bilangan 0–59, hasil port `word(n, en)` di `Angka.dc.html`.
String angkaKata(int n, AppLang lang) {
  if (n < 0 || n > 59) {
    throw ArgumentError.value(n, 'n', 'kata bilangan hanya untuk 0–59');
  }
  if (lang == AppLang.en) {
    if (n < 20) return _enSatuan[n];
    final puluh = _enPuluhan[n ~/ 10];
    final sisa = n % 10;
    return sisa == 0 ? puluh : '$puluh-${_enSatuan[sisa]}';
  }
  if (n < 10) return _idSatuan[n];
  if (n == 10) return 'sepuluh';
  if (n == 11) return 'sebelas';
  if (n < 20) return '${_idSatuan[n - 10]} belas';
  final puluh = _idSatuan[n ~/ 10];
  final sisa = n % 10;
  return sisa == 0 ? '$puluh puluh' : '$puluh puluh ${_idSatuan[sisa]}';
}
