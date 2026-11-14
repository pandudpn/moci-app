import '../storage/json_store.dart';
import 'progress.dart';

final class ProgressRepository {
  ProgressRepository(this._store);

  static const path = 'progress.json';

  final JsonStore _store;

  Future<Progress> load() async {
    final json = await _store.read(path);
    return json == null ? const Progress() : Progress.fromJson(json);
  }

  Future<void> save(Progress p) => _store.write(path, p.toJson());

  Future<void> delete() => _store.delete(path);
}
