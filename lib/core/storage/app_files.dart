import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'backup_exclusion.dart';

final class AppFiles {
  const AppFiles._();

  /// Membuat `<application support>/moci` dan menandainya tidak ikut backup.
  static Future<Directory> open(BackupExclusion exclusion) async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/moci');
    await dir.create(recursive: true);
    await exclusion.exclude(dir);
    return dir;
  }
}
