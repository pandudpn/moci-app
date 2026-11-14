import 'dart:ui' show VoidCallback;

import 'package:flutter/foundation.dart' show ValueChanged;

import '../../../core/lang.dart';
import '../beranda_menu.dart';

/// Kegiatan terakhir yang siap dilanjutkan.
class BerandaResume {
  const BerandaResume({
    required this.menu,
    required this.label,
    required this.onTap,
  });

  final BerandaMenu menu;
  final String label;
  final VoidCallback onTap;
}

/// Isi layar Beranda yang sama untuk tata letak tablet dan HP.
class BerandaContent {
  const BerandaContent({
    required this.lang,
    required this.name,
    required this.resume,
    required this.onMoci,
    required this.onMenu,
    required this.onLang,
    required this.onParents,
  });

  final AppLang lang;

  /// Nama yang disapa (nama anak atau sebutan bawaan).
  final String name;
  final BerandaResume? resume;
  final VoidCallback onMoci;
  final ValueChanged<BerandaMenu> onMenu;
  final ValueChanged<AppLang> onLang;
  final VoidCallback onParents;
}
