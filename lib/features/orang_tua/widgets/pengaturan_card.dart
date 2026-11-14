import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_providers.dart';
import '../../../core/audio/narrator.dart';
import '../../../core/lang.dart';
import '../../../core/prefs/app_prefs.dart';
import '../../../core/prefs/prefs_controller.dart';
import '../../../l10n/l10n.dart';
import '../../../app/theme/moci_text.dart';
import 'moci_switch.dart';
import 'option_pills.dart';
import 'ot_card.dart';

/// Pengaturan: bahasa, cara baca huruf, batas harian, dan tiga saklar.
class PengaturanCard extends ConsumerWidget {
  const PengaturanCard({super.key});

  void _setLang(BuildContext context, WidgetRef ref, AppLang lang) {
    final l10n = context.l10n;
    ref.read(prefsProvider.notifier).setLang(lang);
    final (id, text) = switch (lang) {
      AppLang.id => ('langNameId', l10n.langNameId),
      AppLang.en => ('langNameEn', l10n.langNameEn),
    };
    ref
        .read(narratorProvider)
        .say(NarrationLine(jenis: 'ui', id: id, text: text), lang);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(prefsProvider);
    final ctrl = ref.read(prefsProvider.notifier);
    const gap = SizedBox(height: 10);
    return OtCard(
      label: l10n.orangTuaSettings,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.orangTuaSettings, style: otHeading()),
          gap,
          Text(l10n.orangTuaLangLabel, style: otLabel()),
          OptionPills<AppLang>(
            options: const [(AppLang.id, 'Indonesia'), (AppLang.en, 'English')],
            selected: prefs.lang,
            onSelected: (v) => _setLang(context, ref, v),
          ),
          gap,
          Text(l10n.orangTuaLetters, style: otLabel()),
          OptionPills<LetterMode>(
            fontSize: 18,
            options: [
              (LetterMode.fonik, l10n.orangTuaPhonics),
              (LetterMode.nama, l10n.orangTuaNames),
            ],
            selected: prefs.letterMode,
            onSelected: ctrl.setLetterMode,
          ),
          const SizedBox(height: 2),
          Text(
            prefs.letterMode == LetterMode.fonik
                ? l10n.orangTuaLettersHintPhonics
                : l10n.orangTuaLettersHintNames,
            style: MociText.label.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5B5480),
            ),
          ),
          gap,
          Text(l10n.orangTuaLimit, style: otLabel()),
          OptionPills<int?>(
            fontSize: 17,
            options: [
              for (final m in const [15, 30, 45]) (m, l10n.orangTuaLimitMin(m)),
              (null, l10n.orangTuaLimitOff),
            ],
            selected: prefs.dailyLimitMinutes,
            onSelected: ctrl.setDailyLimit,
          ),
          gap,
          MociSwitch(
            label: l10n.orangTuaMusic,
            value: prefs.music,
            onChanged: ctrl.setMusic,
          ),
          const SizedBox(height: 2),
          MociSwitch(
            label: l10n.orangTuaSfx,
            value: prefs.sfx,
            onChanged: ctrl.setSfx,
          ),
          const SizedBox(height: 2),
          MociSwitch(
            label: l10n.orangTuaBreaks,
            value: prefs.restReminder,
            onChanged: ctrl.setRestReminder,
          ),
        ],
      ),
    );
  }
}
