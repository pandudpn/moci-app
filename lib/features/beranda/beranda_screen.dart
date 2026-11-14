import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import 'beranda_menu.dart';
import 'continue_labels.dart';
import 'widgets/beranda_actions.dart';
import 'widgets/beranda_phone.dart';
import 'widgets/beranda_tablet.dart';

/// Beranda: sapaan Moci, kartu Lanjutkan, sepuluh menu, sakelar ID/EN, bintang,
/// dan pintu ke Area Orang Tua. Tablet dan HP punya tata letak sendiri.
class BerandaScreen extends ConsumerStatefulWidget {
  const BerandaScreen({super.key});

  @override
  ConsumerState<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends ConsumerState<BerandaScreen> {
  @override
  void initState() {
    super.initState();
    // Musik latar mulai setelah frame pertama; `startMusic` idempoten dan
    // diam bila mesin belum siap atau berkasnya belum ada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(prefsProvider).music) _startMusic();
    });
  }

  /// Musik latar tidak wajib tampil: gagal sekali cukup dicatat, layar tetap
  /// jalan.
  Future<void> _startMusic() async {
    try {
      await ref.read(audioServiceProvider).startMusic();
    } catch (e) {
      debugPrint('beranda: musik latar gagal dimulai: $e');
    }
  }

  void _say(String id, String text, AppLang lang) {
    ref
        .read(narratorProvider)
        .say(NarrationLine(jenis: 'ui', id: id, text: text), lang);
  }

  void _tapMoci() {
    // D5: rekaman tidak menyebut nama anak.
    _say('berandaSay', context.l10n.berandaSay, ref.read(prefsProvider).lang);
  }

  void _openMenu(BerandaMenu menu) {
    // Narasi tidak dihentikan: terus berbunyi di layar berikutnya.
    _say(menu.titleKey, menu.title(context.l10n), ref.read(prefsProvider).lang);
    context.push(menu.route);
  }

  void _pickLang(AppLang lang) {
    ref.read(prefsProvider.notifier).setLang(lang);
    final l10n = context.l10n;
    switch (lang) {
      case AppLang.id:
        _say('langNameId', l10n.langNameId, AppLang.id);
      case AppLang.en:
        _say('langNameEn', l10n.langNameEn, AppLang.en);
    }
  }

  BerandaResume? _resume(LastActivity? activity) {
    if (activity == null) return null;
    final menu = BerandaMenu.parentOf(activity.route);
    final label = continueLabel(context.l10n, activity);
    if (menu == null || label == null) return null;
    final target = Uri(
      path: activity.route,
      queryParameters: activity.params.isEmpty ? null : activity.params,
    ).toString();
    return BerandaResume(
      menu: menu,
      label: label,
      onTap: () => context.push(target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    final childName = ref
        .watch(prefsProvider.select((p) => p.childName))
        .trim();
    final lastActivity = ref.watch(
      progressProvider.select((p) => p.lastActivity),
    );
    final content = BerandaContent(
      lang: lang,
      name: childName.isEmpty ? context.l10n.childFallbackName : childName,
      resume: _resume(lastActivity),
      onMoci: _tapMoci,
      onMenu: _openMenu,
      onLang: _pickLang,
      onParents: () => context.push(Routes.gerbangLanjut(Routes.orangTua)),
    );
    return Material(
      type: MaterialType.transparency,
      child: MociStage(
        theme: MenuTheme.beranda,
        tablet: (_) => BerandaTablet(content: content),
        phone: (_) => BerandaPhone(content: content),
      ),
    );
  }
}
