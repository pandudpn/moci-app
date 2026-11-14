/// Aturan lagu dan irama Main Musik. Tidak ada impor Flutter di sini.
library;

/// Nada pertama berbunyi setelah 250 ms; satu ketuk 420 ms.
const mulaiLagu = Duration(milliseconds: 250);
const ketukLagu = Duration(milliseconds: 420);

/// Satu langkah irama drum 150 ms.
const langkahIrama = Duration(milliseconds: 150);

final class Lagu {
  const Lagu({
    required this.id,
    required this.nama,
    required this.nada,
    required this.ketuk,
  });

  final String id;

  /// Judul tidak diterjemahkan; layar memakai kunci ARB untuk menampilkannya.
  final String nama;

  /// Indeks batang xilofon (0 = do rendah) per nada.
  final List<int> nada;

  /// Panjang tiap nada dalam ketukan.
  final List<int> ketuk;
}

const laguTwinkle = Lagu(
  id: 'twinkle',
  nama: 'Twinkle Twinkle',
  nada: [
    0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0, //
    4, 4, 3, 3, 2, 2, 1, //
    4, 4, 3, 3, 2, 2, 1, //
    0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0,
  ],
  ketuk: [
    1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, //
    1, 1, 1, 1, 1, 1, 2, //
    1, 1, 1, 1, 1, 1, 2, //
    1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,
  ],
);

const laguMary = Lagu(
  id: 'mary',
  nama: 'Mary Had a Little Lamb',
  nada: [
    2,
    1,
    0,
    1,
    2,
    2,
    2,
    1,
    1,
    1,
    2,
    4,
    4,
    2,
    1,
    0,
    1,
    2,
    2,
    2,
    2,
    1,
    1,
    2,
    1,
    0,
  ],
  ketuk: [
    1,
    1,
    1,
    1,
    1,
    1,
    2,
    1,
    1,
    2,
    1,
    1,
    2,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    4,
  ],
);

const daftarLagu = <Lagu>[laguTwinkle, laguMary];

/// Waktu main tiap nada: mulai 250 ms, lalu bergeser sepanjang ketuk nada.
List<({int ms, int nada})> jadwalLagu(Lagu lagu) {
  final hasil = <({int ms, int nada})>[];
  var acc = mulaiLagu.inMilliseconds;
  for (var i = 0; i < lagu.nada.length; i++) {
    hasil.add((ms: acc, nada: lagu.nada[i]));
    acc += ketukLagu.inMilliseconds * lagu.ketuk[i];
  }
  return hasil;
}

/// Keadaan "Ikuti": hanya nada berikutnya yang dihitung.
final class IkutiLagu {
  IkutiLagu(this.lagu);

  final Lagu lagu;
  int _posisi = 0;

  int get posisi => _posisi;

  /// Nada yang ditunggu; -1 saat lagu selesai.
  int get berikut => selesai ? -1 : lagu.nada[_posisi];

  bool get selesai => _posisi >= lagu.nada.length;

  bool cocok(int nada) {
    if (selesai || nada != lagu.nada[_posisi]) return false;
    _posisi += 1;
    return true;
  }

  void ulang() => _posisi = 0;
}

final class KetukanIrama {
  const KetukanIrama(this.ms, this.nama);

  final int ms;
  final String nama;
}

/// Dua putaran 16 langkah; urutan dalam satu langkah drum → tepuk → simbal →
/// kerincing, supaya dentum dan tepuk tidak saling menutup.
List<KetukanIrama> iramaDrum() {
  const urutan = ['drum-drum', 'drum-tepuk', 'drum-simbal', 'drum-kerincing'];
  final hasil = <KetukanIrama>[];
  for (var putaran = 0; putaran < 2; putaran++) {
    for (var k = 0; k < 16; k++) {
      final bunyi = <String>{
        if (k == 0 || k == 6 || k == 8) 'drum-drum',
        if (k == 4 || k == 12) 'drum-tepuk',
        if (putaran == 1 && k == 14) 'drum-simbal',
        if (k.isEven) 'drum-kerincing',
      };
      final ms = (putaran * 16 + k) * langkahIrama.inMilliseconds + 100;
      for (final nama in urutan) {
        if (bunyi.contains(nama)) hasil.add(KetukanIrama(ms, nama));
      }
    }
  }
  return hasil;
}
