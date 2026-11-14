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
  FileJsonStore(this.root);

  final Directory root;

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
    }
    await _quarantine(file);
    return null;
  }

  Future<void> _quarantine(File file) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    try {
      await file.rename('${file.path}.rusak-$stamp');
    } on FileSystemException {
      // abaikan; pembacaan tetap mengembalikan null
    }
  }

  @override
  Future<void> write(String path, Map<String, Object?> json) async {
    final file = _file(path);
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(json), flush: true);
    await tmp.rename(file.path);
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
      if (name.endsWith('.tmp') || name.contains('.rusak-')) continue;
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
    final names = _files.keys
        .where((k) => k.startsWith(prefix) && !k.substring(prefix.length).contains('/'))
        .map((k) => k.substring(prefix.length))
        .toList()
      ..sort();
    return names;
  }

  @override
  Future<void> deleteAll() async => _files.clear();
}
