import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;
import 'package:url_launcher/url_launcher.dart';

import '../../app/config.dart';
import '../../app/layout/moci_stage.dart';
import '../../app/play_timer/play_timer_controller.dart';
import '../../app/router.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress.dart';
import '../../core/progress/progress_controller.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_dialog.dart';
import '../../widgets/pressable.dart';
import '../sambutan/widgets/name_field.dart';
import 'ringkasan.dart';
import 'widgets/hari_ini_card.dart';
import 'widgets/minggu_ini_card.dart';
import 'widgets/ot_card.dart';
import 'widgets/pengaturan_card.dart';
import 'widgets/profil_card.dart';

const _deleteInk = Color(0xFFC92A2A);
const _deleteShadow = Color(0xFFF5C2C7);
const _deleteSureFill = Color(0xFFE8384F);
const _deleteSureShadow = Color(0xFFB82A3E);

/// Area Orang Tua: profil, hari ini, minggu ini, pengaturan, dan hapus semua
/// data. Terkunci lagi (akses dicabut) setiap kali layar ini ditinggalkan.
class OrangTuaScreen extends ConsumerStatefulWidget {
  const OrangTuaScreen({super.key});

  @override
  ConsumerState<OrangTuaScreen> createState() => _OrangTuaScreenState();
}

class _OrangTuaScreenState extends ConsumerState<OrangTuaScreen> {
  late final ParentAccess _access;
  final _nameController = TextEditingController();
  bool _wiping = false;

  @override
  void initState() {
    super.initState();
    _access = ref.read(parentAccessProvider.notifier);
  }

  @override
  void dispose() {
    _nameController.dispose();
    // Tidak boleh mengubah provider saat pohon widget sedang dibongkar.
    scheduleMicrotask(_revokeSafely);
    super.dispose();
  }

  void _revokeSafely() {
    try {
      _access.revoke();
    } on Object {
      // Provider sudah dibuang (UnmountedRefException): aplikasi atau tes
      // berakhir, jadi tidak ada lagi yang perlu dikunci.
    }
  }

  /// "Kunci dan kembali ke beranda": juga dipakai tombol back sistem. `go`,
  /// bukan `pop`, supaya tidak mendarat di `/habis` atau `/gerbang` basi.
  void _lockAndLeave() {
    _access.revoke();
    context.go(Routes.beranda);
  }

  Future<void> _editName() async {
    final prefs = ref.read(prefsProvider.notifier);
    _nameController.text = ref.read(prefsProvider).childName;
    final l10n = context.l10n;
    await MociDialog.show<void>(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.orangTuaEditName,
            style: MociText.title.copyWith(fontSize: 32, height: 1.1),
          ),
          const SizedBox(height: 18),
          NameField(
            controller: _nameController,
            hint: l10n.orangTuaNameHint,
            label: l10n.orangTuaNameHint,
          ),
        ],
      ),
      actions: [
        _cancelButton(l10n),
        MociDialogButton(
          label: l10n.orangTuaSave,
          color: MociColors.correct,
          shadowColor: MociColors.correctShadow,
          textColor: MociColors.white,
          onTap: () => _saveName(prefs),
        ),
      ],
    );
  }

  /// Nama ditulis dulu, baru dialog ditutup: penulisan yang lambat tidak
  /// membuat orang tua melihat nama lama sesudah menekan Simpan.
  Future<void> _saveName(PrefsController prefs) async {
    await prefs.setChildName(_nameController.text);
    if (!mounted) return;
    _closeDialog();
  }

  MociDialogButton _cancelButton(AppLocalizations l10n) => MociDialogButton(
    label: l10n.orangTuaCancel,
    color: const Color(0xFFFFF7E0),
    shadowColor: const Color(0xFFF2D27A),
    textColor: MociColors.ink,
    onTap: _closeDialog,
  );

  void _closeDialog() => Navigator.of(context, rootNavigator: true).pop();

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final sure = ValueNotifier<bool>(false);
    await MociDialog.show<void>(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.orangTuaDeleteTitle,
            style: MociText.title.copyWith(fontSize: 32, height: 1.1),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.orangTuaDeleteBody,
            style: MociText.label.copyWith(
              fontSize: 20,
              height: 1.4,
              color: const Color(0xFF5B5480),
            ),
          ),
        ],
      ),
      actions: [
        _cancelButton(l10n),
        ValueListenableBuilder<bool>(
          valueListenable: sure,
          builder: (context, confirm, _) => MociDialogButton(
            label: confirm ? l10n.orangTuaDeleteSure : l10n.orangTuaDelete,
            color: confirm ? _deleteSureFill : MociColors.white,
            shadowColor: confirm ? _deleteSureShadow : _deleteShadow,
            textColor: confirm ? MociColors.white : _deleteInk,
            onTap: () {
              if (!sure.value) {
                sure.value = true;
                return;
              }
              if (_wiping) return;
              _closeDialog();
              unawaited(_wipe());
            },
          ),
        ),
      ],
    );
    sure.dispose();
  }

  /// Hapus semua data. Semua yang dibutuhkan diambil sebelum `await` pertama:
  /// sesudah `resetAll` layar ini ikut dibongkar oleh redirect ke Sambutan.
  Future<void> _wipe() async {
    if (_wiping) return;
    _wiping = true;
    final json = ref.read(jsonStoreProvider);
    final progress = ref.read(progressProvider.notifier);
    final prefs = ref.read(prefsProvider.notifier);
    final container = ProviderScope.containerOf(context);
    final router = GoRouter.of(context);
    try {
      await json.deleteAll();
      await progress.reset();
      await prefs.resetAll();
    } on Object {
      _wiping = false; // gagal di tengah jalan: izinkan mencoba lagi
      rethrow;
    }
    // Pengatur waktu menyimpan detik di memori; tanpa ini ia menulis ulang
    // waktu bermain lama ke berkas yang baru dihapus.
    container.invalidate(playTimerProvider);
    _revokeSafely();
    final config = router.routerDelegate.currentConfiguration;
    if (config.isEmpty || config.last.matchedLocation != Routes.sambutan) {
      router.go(Routes.sambutan);
    }
  }

  Future<void> _open(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      // Tidak ada aplikasi yang bisa membukanya: biarkan saja.
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _lockAndLeave();
      },
      child: MociStage(
        theme: MenuTheme.orangTua,
        textScaleCap: 1.3,
        tablet: _stage,
      ),
    );
  }

  Widget _stage(BuildContext context) {
    final l10n = context.l10n;
    final harian = ref.watch(progressProvider.select((p) => p.harian));
    final secondsToday = ref.watch(
      playTimerProvider.select((s) => s.secondsToday),
    );
    final limit = ref.watch(prefsProvider.select((p) => p.dailyLimitMinutes));
    final now = ref.watch(clockProvider).now();
    final day = harian[dateKey(now)] ?? const DayStats();
    final today = TodaySummary(
      minutesPlayed: secondsToday ~/ 60,
      limit: limit,
      stars: day.stars,
      stickers: day.stickers,
      karya: day.karya,
    );
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 1180,
        height: 820,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: 32, right: 32, top: 26, child: _topBar(l10n)),
            Positioned(
              left: 32,
              top: 124,
              width: 360,
              height: 240,
              child: ProfilCard(onEditName: _editName),
            ),
            Positioned(
              left: 32,
              top: 378,
              width: 360,
              height: 340,
              child: HariIniCard(today: today),
            ),
            Positioned(
              left: 412,
              top: 124,
              width: 360,
              height: 594,
              child: MingguIniCard(rows: computeWeekly(harian, now)),
            ),
            const Positioned(
              left: 792,
              top: 124,
              width: 356,
              height: 594,
              child: PengaturanCard(),
            ),
            Positioned(
              left: 32,
              right: 32,
              top: 736,
              child: _bottomRow(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(AppLocalizations l10n) {
    return Row(
      children: [
        MociBackButton(semanticLabel: l10n.orangTuaBack, onTap: _lockAndLeave),
        const SizedBox(width: 18),
        Expanded(
          child: Semantics(
            header: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.orangTuaTitle,
                maxLines: 1,
                style: MociText.title.copyWith(fontSize: 46),
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        ExcludeSemantics(child: _locksBadge(l10n)),
      ],
    );
  }

  Widget _locksBadge(AppLocalizations l10n) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomPaint(size: Size.square(22), painter: _LockPainter()),
              const SizedBox(width: 8),
              Text(
                l10n.orangTuaLocks,
                style: MociText.label.copyWith(
                  fontSize: 16,
                  color: MociColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomRow(BuildContext context, AppLocalizations l10n) {
    final touch = otTouch(context);
    final privacy = AppConfig.privacyPolicyUrl;
    final support = AppConfig.supportEmail;
    final badges = [
      l10n.orangTuaBadgeAds,
      l10n.orangTuaBadgePurchases,
      l10n.orangTuaBadgeOffline,
      l10n.orangTuaBadgeData,
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: touch),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < badges.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _Badge(text: badges[i]),
                  ],
                  if (privacy != null) ...[
                    const SizedBox(width: 12),
                    _linkPill(
                      l10n.orangTuaPrivacy,
                      () => _open(Uri.parse(privacy)),
                      touch,
                    ),
                  ],
                  if (support != null) ...[
                    const SizedBox(width: 12),
                    _linkPill(
                      l10n.orangTuaSupport,
                      () => _open(Uri(scheme: 'mailto', path: support)),
                      touch,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          MociPressable(
            color: MociColors.white,
            shadowColor: _deleteShadow,
            depth: 4,
            minTouch: touch,
            borderRadius: BorderRadius.circular(999),
            semanticLabel: l10n.orangTuaDelete,
            onTap: _confirmDelete,
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: ExcludeSemantics(
                    child: Text(
                      l10n.orangTuaDelete,
                      maxLines: 1,
                      style: MociText.button.copyWith(
                        fontSize: 17,
                        color: _deleteInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkPill(String label, VoidCallback onTap, double touch) {
    return MociPressable(
      color: MociColors.white,
      shadowColor: otShadow,
      depth: 4,
      minTouch: touch,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: label,
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ExcludeSemantics(
              child: Text(
                label,
                style: MociText.label.copyWith(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: otShadow, offset: Offset(0, 4))],
      ),
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ExcludeSemantics(
                child: CustomPaint(
                  size: Size.square(24),
                  painter: _CheckPainter(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                maxLines: 1,
                style: MociText.label.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.drawCircle(
      Offset(12 * k, 12 * k),
      10 * k,
      Paint()..color = MociColors.correct,
    );
    final tick = Path()
      ..moveTo(7.5 * k, 12.5 * k)
      ..lineTo(10.5 * k, 15.5 * k)
      ..lineTo(16.5 * k, 9 * k);
    canvas.drawPath(
      tick,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = MociColors.white
        ..strokeWidth = 2.6 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => false;
}

class _LockPainter extends CustomPainter {
  const _LockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = MociColors.white
      ..strokeWidth = 2.4 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(
      RRect.fromLTRBR(
        4.5 * k,
        10.5 * k,
        19.5 * k,
        20.5 * k,
        Radius.circular(2.5 * k),
      ),
      paint,
    );
    final shackle = Path()
      ..moveTo(8 * k, 10.5 * k)
      ..lineTo(8 * k, 7.5 * k)
      ..arcToPoint(Offset(16 * k, 7.5 * k), radius: Radius.circular(4 * k))
      ..lineTo(16 * k, 10.5 * k);
    canvas.drawPath(shackle, paint);
  }

  @override
  bool shouldRepaint(_LockPainter old) => false;
}
