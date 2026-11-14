import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock.dart';
import 'storage/json_store.dart';
import 'storage/key_value_store.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('keyValueStoreProvider belum dioverride'),
);

final jsonStoreProvider = Provider<JsonStore>(
  (ref) => throw UnimplementedError('jsonStoreProvider belum dioverride'),
);
