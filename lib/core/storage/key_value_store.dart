import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan kunci-nilai untuk pengaturan. Kunci sudah memuat awalan `moci.`.
abstract interface class KeyValueStore {
  String? getString(String key);
  int? getInt(String key);
  bool? getBool(String key);
  Future<void> setString(String key, String value);
  Future<void> setInt(String key, int value);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
  Future<void> clear();
}

final class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _data[key] = value;

  @override
  Future<void> setBool(String key, bool value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();
}

final class SharedPrefsKeyValueStore implements KeyValueStore {
  SharedPrefsKeyValueStore._(this._prefs);

  static const _prefix = 'moci.';

  final SharedPreferencesWithCache _prefs;

  static Future<SharedPrefsKeyValueStore> open() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return SharedPrefsKeyValueStore._(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() async {
    for (final key in _prefs.keys.where((k) => k.startsWith(_prefix)).toList()) {
      await _prefs.remove(key);
    }
  }
}
