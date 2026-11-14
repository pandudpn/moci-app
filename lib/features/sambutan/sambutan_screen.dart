import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import '../../app/layout/moci_stage.dart';
import '../../app/motion/ambient_motion.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/lang.dart';
import '../../core/prefs/app_prefs.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/pressable.dart';
import 'widgets/age_chip.dart';
import 'widgets/lang_card.dart';
import 'widgets/name_field.dart';
import 'widgets/sambutan_icons.dart';
import 'widgets/sambutan_scenery.dart';

/// Tinggi panggung dasar (tablet), dasar perhitungan geser keyboard.
const _stageHeight = 820.0;

/// Jarak aman antara kolom nama dan tepi atas keyboard (satuan panggung).
const _keyboardGap = 24.0;

/// Posisi bawah kolom nama di panggung bila belum sempat diukur.
const _fieldBottomFallback = 505.0;

/// Sambutan: tampil sekali saat pertama dibuka. Anak memilih bahasa, mengisi
/// nama, dan memilih rentang usia.
class SambutanScreen extends ConsumerStatefulWidget {
  const SambutanScreen({super.key});

  @override
  ConsumerState<SambutanScreen> createState() => _SambutanScreenState();
}

class _SambutanScreenState extends ConsumerState<SambutanScreen> {
  static const _ages = [
    ('2–3', AgeLevel.pemula),
    ('4–5', AgeLevel.penjelajah),
    ('6–7', AgeLevel.pembaca),
  ];

  final _name = TextEditingController();
  final _rootKey = GlobalKey();
  final _fieldKey = GlobalKey();
  AgeLevel _age = AgeLevel.pemula;

  /// Sedang menyimpan: ketukan lain diabaikan supaya tidak tersimpan dua kali.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String get _trimmed => _name.text.trim();

  void _say(String id, String text, AppLang lang) {
    ref
        .read(narratorProvider)
        .say(NarrationLine(jenis: 'ui', id: id, text: text), lang);
  }

  void _pickLang(AppLang lang) {
    if (_saving) return;
    ref.read(prefsProvider.notifier).setLang(lang);
    final l10n = context.l10n;
    switch (lang) {
      case AppLang.id:
        _say('langNameId', l10n.langNameId, AppLang.id);
      case AppLang.en:
        _say('langNameEn', l10n.langNameEn, AppLang.en);
    }
  }

  void _tapMoci() {
    final l10n = context.l10n;
    final lang = ref.read(prefsProvider).lang;
    if (_trimmed.isEmpty) {
      _say('sambutanSay', l10n.sambutanSay, lang);
    } else {
      // D5: rekaman tidak menyebut nama anak.
      _say('sambutanHalo', l10n.sambutanHalo, lang);
    }
  }

  Future<void> _start() async {
    if (_saving) return;
    _saving = true;
    final lang = ref.read(prefsProvider).lang;
    final text = context.l10n.sambutanStart;
    final prefs = ref.read(prefsProvider.notifier);
    _say('sambutanStart', text, lang);
    try {
      await prefs.completeOnboarding(
        lang: lang,
        childName: _trimmed,
        age: _age,
      );
    } catch (e) {
      // Gagal menyimpan: tetap di layar ini, jangan pindah dengan data kosong.
      debugPrint('sambutan: gagal menyimpan pengaturan: $e');
      _saving = false;
      return;
    }
    // Refresh router bisa sudah mengalihkan ke Beranda dan melepas layar ini.
    if (!mounted) return;
    context.go(Routes.beranda);
  }

  /// Bawah kolom nama pada koordinat panggung; geser tidak ikut terhitung
  /// karena [_rootKey] berada di dalam transformasi geser.
  double _fieldBottom() {
    final root = _rootKey.currentContext?.findRenderObject();
    final field = _fieldKey.currentContext?.findRenderObject();
    if (root is! RenderBox || field is! RenderBox || !field.attached) {
      return _fieldBottomFallback;
    }
    return field.localToGlobal(Offset(0, field.size.height), ancestor: root).dy;
  }

  Widget _content(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    final hello =
        '${l10n.sambutanHello}, '
        '${_trimmed.isEmpty ? l10n.sambutanFriend : _trimmed}!';

    final kb = MediaQuery.viewInsetsOf(context).bottom / context.stageScale;
    final shift = kb <= 0
        ? 0.0
        : (_fieldBottom() + _keyboardGap - (_stageHeight - kb)).clamp(0.0, kb);

    // Satu jam gerak untuk awan, matahari, gelembung, dan Moci di layar ini.
    return AmbientMotion(
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          // Ketukan di luar kolom nama melepas fokus; keyboard ikut turun.
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Transform.translate(
            offset: Offset(0, -shift),
            child: SizedBox(
              key: _rootKey,
              width: 1180,
              height: _stageHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const SambutanScenery(),
                  Positioned(
                    left: 70,
                    top: 56,
                    child: SambutanLogo(tag: l10n.sambutanTag),
                  ),
                  Positioned(
                    left: 290,
                    top: 232,
                    child: AmbientLayer(
                      key: const ValueKey('sambutan-bubble'),
                      // sbWob: goyang -2° ke 2°, poros 10% 100%.
                      builder: (context, seconds, child) => Transform.rotate(
                        angle: wobbleAngle(t: seconds, period: 3),
                        alignment: const Alignment(-.8, 1),
                        child: child,
                      ),
                      child: _Bubble(text: hello),
                    ),
                  ),
                  Positioned(
                    left: 96,
                    top: 280,
                    width: 290,
                    height: 290,
                    child: AmbientLayer(
                      key: const ValueKey('sambutan-moci'),
                      // sbBob: naik 14 px tiap 3 detik.
                      builder: (context, seconds, child) => Transform.translate(
                        offset: Offset(
                          0,
                          bobOffset(t: seconds, amplitude: 14, period: 3),
                        ),
                        child: child,
                      ),
                      child: Semantics(
                        button: true,
                        label: 'Moci',
                        excludeSemantics: true,
                        child: MociMascot(
                          pose: MociPose.senang,
                          size: 290,
                          onTap: _tapMoci,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 50,
                    top: 716,
                    width: 430,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SambutanBadge(text: l10n.sambutanBadge1),
                        SambutanBadge(text: l10n.sambutanBadge2),
                        SambutanBadge(text: l10n.sambutanBadge3),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 520,
                    top: 50,
                    width: 620,
                    height: 736,
                    child: _card(l10n, lang),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(AppLocalizations l10n, AppLang lang) {
    final label = MociText.label.copyWith(
      fontSize: 17,
      letterSpacing: .3,
      color: MociColors.inkSoft,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: const [
          BoxShadow(color: MociColors.cardShadow, offset: Offset(0, 14)),
          BoxShadow(
            color: Color(0x2E2B2350),
            offset: Offset(0, 30),
            blurRadius: 50,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sambutanHi,
                  style: MociText.title.copyWith(fontSize: 44, height: 1.1),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.sambutanSub,
                  style: MociText.label.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5B5480),
                  ),
                ),
                const SizedBox(height: 20),
                // Dwibahasa tetap, tidak diterjemahkan.
                Text('Pilih bahasa · Choose a language', style: label),
                const SizedBox(height: 8),
                LangCard(
                  code: 'ID',
                  badgeColor: MociColors.wrong,
                  title: 'Bahasa Indonesia',
                  subtitle: 'Suara & teks Bahasa Indonesia',
                  selected: lang == AppLang.id,
                  onTap: () => _pickLang(AppLang.id),
                ),
                const SizedBox(height: 12),
                LangCard(
                  code: 'EN',
                  badgeColor: const Color(0xFF1C7ED6),
                  title: 'English',
                  subtitle: 'English voice & text',
                  selected: lang == AppLang.en,
                  onTap: () => _pickLang(AppLang.en),
                ),
                const SizedBox(height: 20),
                Text(l10n.sambutanNameLabel, style: label),
                const SizedBox(height: 8),
                KeyedSubtree(
                  key: _fieldKey,
                  child: NameField(
                    controller: _name,
                    hint: l10n.sambutanNamePh,
                    label: l10n.sambutanNameLabel,
                  ),
                ),
                const SizedBox(height: 20),
                Text(l10n.sambutanAge, style: label),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < _ages.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: AgeChip(
                          range: _ages[i].$1,
                          years: l10n.sambutanYears,
                          selected: _age == _ages[i].$2,
                          onTap: () => setState(() => _age = _ages[i].$2),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.sambutanNote,
                  style: label.copyWith(fontSize: 15, letterSpacing: 0),
                ),
              ],
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            bottom: 28,
            height: 80,
            child: MociPressable(
              color: MociColors.correct,
              shadowColor: MociColors.correctShadow,
              depth: 9,
              borderRadius: BorderRadius.circular(999),
              onTap: _start,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.sambutanStart,
                    style: MociText.title.copyWith(
                      fontSize: 32,
                      color: MociColors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const ExcludeSemantics(
                    child: CustomPaint(
                      size: Size(34, 34),
                      painter: ArrowPainter(color: MociColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MociStage(theme: MenuTheme.sambutan, tablet: _content);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 214),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MociColors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(color: MociColors.neutralShadow, offset: Offset(0, 7)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Text(
            text,
            style: MociText.title.copyWith(fontSize: 28, height: 1.15),
          ),
        ),
      ),
    );
  }
}
