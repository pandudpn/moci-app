import 'dart:convert';
import 'dart:io';

/// Penyimpanan berkas JSON. Path relatif memakai pemisah `/`.
abstract interface class JsonStore {
  Future<Map<String, Object?>?> read(String path);
  Future<void> write(String path, Map<String, Object?> json);
  Future<void> delete(String path);
  Future<List<String>> list(String dir);
  Future<void> deleteAll();
}

final class FileJsonStore implements JsonStore {
  /// [now] bisa diganti di tes supaya stempel waktu bisa dipaku.
  FileJsonStore(this.root, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Directory root;
  final DateTime Function() _now;

  /// Nomor urut nama berkas sementara dan karantina. Satu proses jadi satu
  /// penulis, jadi nomor yang terus naik tidak pernah bentrok.
  static int _seq = 0;

  /// Sisa `.tmp` yang lebih tua dari ini dianggap dari proses yang mati.
  static const _tmpBasi = Duration(minutes: 5);

  File _file(String path) => File('${root.path}/$path');

  @override
  Future<Map<String, Object?>?> read(String path) async {
    final file = _file(path);
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return Map<String, Object?>.from(decoded);
      }
    } on FormatException {
      // jatuh ke karantina di bawah
    } on FileSystemException {
      // Byte tidak valid UTF-8 (tulisan terpotong) atau galat I/O.
      // jatuh ke karantina di bawah
    }
    await _quarantine(file);
    return null;
  }

  Future<void> _quarantine(File file) async {
    final stamp = _now().millisecondsSinceEpoch;
    while (true) {
      final target = '${file.path}.rusak-$stamp-${_seq++}';
      if (await File(target).exists()) continue;
      try {
        await file.rename(target);
      } on FileSystemException {
        // abaikan; pembacaan tetap mengembalikan null
      }
      return;
    }
  }

  @override
  Future<void> write(String path, Map<String, Object?> json) async {
    final file = _file(path);
    await file.parent.create(recursive: true);
    await _buangTmpBasi(file);
    // Nama sementara milik sendiri: dua tulisan bersamaan tidak berbagi `.tmp`.
    final tmp = File('${file.path}.tmp-${_seq++}');
    try {
      await tmp.writeAsString(jsonEncode(json), flush: true);
      await tmp.rename(file.path);
    } on FileSystemException {
      if (await tmp.exists()) await tmp.delete();
      rethrow;
    }
  }

  /// Membuang sisa `.tmp` dari tulisan yang tidak selesai. Berkas yang masih
  /// baru mungkin milik penulisan lain yang sedang jalan, jadi dibiarkan.
  Future<void> _buangTmpBasi(File file) async {
    final base = file.uri.pathSegments.last;
    final sekarang = _now();
    try {
      await for (final e in file.parent.list()) {
        if (e is! File) continue;
        final nama = e.uri.pathSegments.last;
        if (!nama.startsWith('$base.tmp')) continue;
        if (nama != '$base.tmp') {
          final DateTime ubah;
          try {
            ubah = await e.lastModified();
          } on FileSystemException {
            continue;
          }
          if (sekarang.difference(ubah) <= _tmpBasi) continue;
        }
        try {
          await e.delete();
        } on FileSystemException {
          // sudah hilang; abaikan
        }
      }
    } on FileSystemException {
      // folder tidak terbaca; biarkan sisa berkas
    }
  }

  @override
  Future<void> delete(String path) async {
    final file = _file(path);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<List<String>> list(String dir) async {
    final d = Directory('${root.path}/$dir');
    if (!await d.exists()) return [];
    final names = <String>[];
    await for (final e in d.list()) {
      if (e is! File) continue;
      final name = e.uri.pathSegments.last;
      if (name.contains('.tmp') || name.contains('.rusak-')) continue;
      names.add(name);
    }
    names.sort();
    return names;
  }

  @override
  Future<void> deleteAll() async {
    if (!await root.exists()) return;
    await for (final e in root.list()) {
      await e.delete(recursive: true);
    }
  }
}

final class MemoryJsonStore implements JsonStore {
  final Map<String, Map<String, Object?>> _files = {};

  @override
  Future<Map<String, Object?>?> read(String path) async {
    final json = _files[path];
    return json == null ? null : Map<String, Object?>.from(json);
  }

  @override
  Future<void> write(String path, Map<String, Object?> json) async =>
      _files[path] = Map<String, Object?>.from(json);

  @override
  Future<void> delete(String path) async => _files.remove(path);

  @override
  Future<List<String>> list(String dir) async {
    final prefix = '$dir/';
    final names =
        _files.keys
            .where(
              (k) =>
                  k.startsWith(prefix) &&
                  !k.substring(prefix.length).contains('/'),
            )
            .map((k) => k.substring(prefix.length))
            .toList()
          ..sort();
    return names;
  }

  @override
  Future<void> deleteAll() async => _files.clear();
}
