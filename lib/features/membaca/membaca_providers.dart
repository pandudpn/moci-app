import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sumber acak untuk ronde Membaca; tes menggantinya dengan yang tetap.
final membacaRandomProvider = Provider<Random>((_) => Random());
