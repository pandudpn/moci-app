import 'package:flutter/services.dart';

/// Daftar aset yang benar-benar ada di bundel. Aset audio belum tentu ada.
final class AssetCatalog {
  const AssetCatalog(this._paths);

  final Set<String> _paths;

  static Future<AssetCatalog> load(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    return AssetCatalog(manifest.listAssets().toSet());
  }

  bool has(String path) => _paths.contains(path);
}
