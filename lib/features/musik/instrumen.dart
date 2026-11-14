/// Daftar bunyi instrumen Main Musik.
///
/// Nama berkas dipakai generator (`tool/buat_instrumen.dart`), pemuat audio,
/// dan tes aset sekaligus. Tidak ada impor Flutter di sini.
const nadaXilo = <String>[
  'xilo-1',
  'xilo-2',
  'xilo-3',
  'xilo-4',
  'xilo-5',
  'xilo-6',
  'xilo-7',
  'xilo-8',
];

const bunyiDrum = <String>[
  'drum-drum',
  'drum-tepuk',
  'drum-simbal',
  'drum-kerincing',
];

const daftarInstrumen = <String>[...nadaXilo, ...bunyiDrum];

/// Nada do–do tinggi (C5–C6) mengikuti prototipe.
const frekuensiXilo = <double>[
  523.25,
  587.33,
  659.25,
  698.46,
  783.99,
  880.0,
  987.77,
  1046.5,
];

String pathInstrumen(String nama) => 'assets/audio/instrumen/$nama.wav';
