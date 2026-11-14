import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'app/moci_app.dart';
import 'core/audio/asset_catalog.dart';
import 'core/audio/audio_providers.dart';
import 'core/progress/progress_controller.dart';
import 'core/progress/progress_repository.dart';
import 'core/providers.dart';
import 'core/storage/app_files.dart';
import 'core/storage/backup_exclusion.dart';
import 'core/storage/json_store.dart';
import 'core/storage/key_value_store.dart';

void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final entry in const {
      'Fredoka': 'assets/fonts/OFL-Fredoka.txt',
      'Nunito': 'assets/fonts/OFL-Nunito.txt',
    }.entries) {
      final text = await rootBundle.loadString(entry.value);
      yield LicenseEntryWithLineBreaks([entry.key], text);
    }
  });
}

Future<void> main() => runMoci();

Future<void> runMoci({List<Override> overrides = const []}) async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final keyValueStore = await SharedPrefsKeyValueStore.open();
  final dir = await AppFiles.open(const MethodChannelBackupExclusion());
  final jsonStore = FileJsonStore(dir);
  final progress = await ProgressRepository(jsonStore).load();
  final assetCatalog = await AssetCatalog.load(rootBundle);
  runApp(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(keyValueStore),
        jsonStoreProvider.overrideWithValue(jsonStore),
        initialProgressProvider.overrideWithValue(progress),
        assetCatalogProvider.overrideWithValue(assetCatalog),
        ...overrides,
      ],
      child: const MociApp(),
    ),
  );
}
