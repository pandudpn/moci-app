import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/content/angka_kata.dart';
import '../../core/content/content_repository.dart';
import '../../core/content/katalog.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/game_mode_pill.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import 'bentuk_game.dart';
import 'bentuk_shape.dart';

enum BentukMode { kenali, cari }

/// Sumber acak mode Cari; dites lewat override supaya urutan tetap.
final bentukRandomProvider = Provider<Random>((_) => Random());

/// Layar Bentuk: Kenali (kartu besar, chip sifat, hitung sudut) dan Cari.
class BentukScreen extends ConsumerStatefulWidget {
  const BentukScreen({super.key, this.mode = BentukMode.kenali, this.awal});

  static const hearKey = ValueKey<String>('bentuk-hear');
  static const countKey = ValueKey<String>('bentuk-count');
  static const questionKey = ValueKey<String>('bentuk-question');

  static ValueKey<int> markKey(int i) => ValueKey<int>(i);

  static ValueKey<String> shapeKey(String id) => ValueKey('bentuk-shape-$id');

  static ValueKey<String> checkKey(String id) => ValueKey('bentuk-check-$id');

  final BentukMode mode;

  /// Bentuk pertama saat layar dibuka; nilai di luar pool diabaikan.
  final String? awal;

  @override
  ConsumerState<BentukScreen> createState() => _BentukScreenState();
}

class _BentukScreenState extends ConsumerState<BentukScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF5C7CFA);
  static const _accentDark = Color(0xFF3B5BDB);
  static const _soft = Color(0xFFEEF1FF);
  static const _border = Color(0xFFC5CEF7);
  static const _fact = Color(0xFF5B5480);

  late BentukMode _mode;
  late String _id;
  int _cetak = 0;
  Timer? _timer;

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: 1,
  );
  late final Animation<double> _popScale = CurvedAnimation(
    parent: _pop,
    curve: const Cubic(0.3, 1.6, 0.5, 1),
  );

  Katalog get _katalog => ref.read(katalogProvider);

  AppLang get _lang => ref.read(prefsProvider).lang;

  List<BentukEntry> get _pool {
    final semua = _katalog.bentuk;
    return [
      for (final i in bentukPool(ref.read(prefsProvider).ageLevel))
        if (i < semua.length) semua[i],
    ];
  }

  BentukEntry get _bentuk =>
      _katalog.bentuk.firstWhere((b) => b.id == _id, orElse: () => _katalog.bentuk.first);

  bool get _bisaHitung => _bentuk.sudutTitik.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    final pool = _pool;
    final awal = widget.awal;
    _id = pool.any((b) => b.id == awal)
        ? awal!
        : (pool.isEmpty ? _katalog.bentuk.first.id : pool.first.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catat();
      _sayNama();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pop.dispose();
    super.dispose();
  }

  void _catat() => ref
      .read(progressProvider.notifier)
      .setLastActivity(Routes.bentuk, {'bentuk': _id, 'mode': _mode.name});

  void _say(List<NarrationLine> lines) =>
      ref.read(narratorProvider).sayAll(lines, _lang);

  void _sayNama() => _say([
    NarrationLine(
      jenis: 'bentuk',
      id: _id,
      text: _bentuk.nama.of(_lang),
    ),
  ]);

  void _sayFakta() => _say([
    NarrationLine(
      jenis: 'fakta',
      id: _id,
      text: _bentuk.fakta.of(_lang),
    ),
  ]);

  void _pilih(BentukEntry b) {
    _timer?.cancel();
    if (b.id == _id) {
      _sayNama();
      return;
    }
    setState(() {
      _id = b.id;
      _cetak = 0;
    });
    _pop.forward(from: 0);
    _catat();
    _sayNama();
  }

  void _pilihMode(BentukMode m) {
    if (m == _mode) return;
    setState(() => _mode = m);
    _catat();
  }

  void _hitung() {
    final bentuk = _bentuk;
    if (bentuk.sudutTitik.isEmpty) return;
    _timer?.cancel();
    setState(() => _cetak = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (!mounted) return;
      final n = _cetak + 1;
      setState(() => _cetak = n);
      final selesai = n >= bentuk.sudutTitik.length;
      // Angka terakhir dan fakta dibacakan dalam satu rangkaian supaya
      // pemanggilan fakta tidak membatalkan angka terakhir.
      _say([
        NarrationLine(jenis: 'angka', id: '$n', text: angkaKata(n, _lang)),
        if (selesai)
          NarrationLine(
            jenis: 'fakta',
            id: _id,
            text: bentuk.fakta.of(_lang),
          ),
      ]);
      if (selesai) t.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsProvider.select((p) => p.lang));
    ref.watch(prefsProvider.select((p) => p.ageLevel));
    ref.watch(katalogProvider);
    return MociStage(theme: MenuTheme.bentuk, tablet: _tablet);
  }

  Widget _tablet(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MociTopBar(
            leading: const MociBackButton(),
            title: l10n.menuBentukTitle,
            trailing: [
              GameModePill(
                tabs: [
                  GameModeTab(label: l10n.bentukLearn),
                  GameModeTab(label: l10n.bentukFind),
                ],
                selected: _mode.index,
                onSelected: (i) => _pilihMode(BentukMode.values[i]),
                semanticLabel: l10n.modeSemantic,
                accent: _accent,
              ),
            ],
          ),
        ),
        Positioned(left: 40, top: 122, child: _kartuKiri(l10n)),
        Positioned(left: 720, top: 122, child: _kisi(l10n)),
      ],
    );
  }

  Widget _kartuKiri(AppLocalizations l10n) {
    final bentuk = _bentuk;
    final nama = bentuk.nama.of(_lang);
    final gelap = _hex(bentuk.gelap);
    return Container(
      width: 640,
      height: 668,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: const [
          BoxShadow(color: _border, offset: Offset(0, 14)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 155,
            top: 26,
            child: ScaleTransition(
              scale: _popScale,
              child: MociPressable(
                onTap: _sayNama,
                color: const Color(0x00000000),
                shadowColor: const Color(0x00000000),
                depth: 0,
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                semanticLabel: l10n.bentukShapeLabel(nama),
                child: SizedBox(
                  width: 330,
                  height: 330,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      BentukShape(bentuk: bentuk, size: 330, shadow: true),
                      for (var i = 0; i < bentuk.sudutTitik.length; i++)
                        if (i < _cetak)
                          Positioned(
                            key: BentukScreen.markKey(i),
                            left: bentuk.sudutTitik[i].$1 * 330 / 200 - 24,
                            top: bentuk.sudutTitik[i].$2 * 330 / 200 - 24,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: MociColors.ink,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: MociColors.white,
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontFamily: MociFonts.fredoka,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    color: MociColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 36,
            right: 36,
            top: 372,
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    nama,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: MociFonts.fredoka,
                      fontWeight: FontWeight.w700,
                      fontSize: 58,
                      height: 1.05,
                      color: gelap,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bentuk.fakta.of(_lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: MociFonts.nunito,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.35,
                    color: _fact,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    for (final c in chipBentuk(bentuk)) _chip(c, l10n),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MociPressable(
                  key: BentukScreen.hearKey,
                  onTap: () => _say([
                    NarrationLine(
                      jenis: 'bentuk',
                      id: _id,
                      text: nama,
                    ),
                    NarrationLine(
                      jenis: 'fakta',
                      id: _id,
                      text: bentuk.fakta.of(_lang),
                    ),
                  ]),
                  color: _accent,
                  shadowColor: _accentDark,
                  depth: 7,
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  semanticLabel: l10n.commonListen,
                  child: SizedBox(
                    height: 64,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GameGlyph(
                            GameGlyphKind.listen,
                            size: 28,
                            color: MociColors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.commonListen,
                            style: const TextStyle(
                              fontFamily: MociFonts.fredoka,
                              fontWeight: FontWeight.w600,
                              fontSize: 23,
                              color: MociColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_bisaHitung) ...[
                  const SizedBox(width: 14),
                  MociPressable(
                    key: BentukScreen.countKey,
                    onTap: _hitung,
                    color: MociColors.white,
                    shadowColor: _border,
                    depth: 7,
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    semanticLabel: bentuk.jenis == 'star'
                        ? l10n.bentukCountTips
                        : l10n.bentukCountCorners,
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(32),
                        ),
                        border: Border.all(color: _border, width: 3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GameGlyph(GameGlyphKind.count, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            bentuk.jenis == 'star'
                                ? l10n.bentukCountTips
                                : l10n.bentukCountCorners,
                            style: const TextStyle(
                              fontFamily: MociFonts.fredoka,
                              fontWeight: FontWeight.w600,
                              fontSize: 23,
                              color: MociColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BentukChip c, AppLocalizations l10n) {
    final label = switch (c.key) {
      'bentukSisi' => l10n.bentukSisi(c.jumlah!),
      'bentukSudut' => l10n.bentukSudut(c.jumlah!),
      'bentukUjung' => l10n.bentukUjung(c.jumlah!),
      'bentukSayang' => l10n.bentukSayang,
      _ => l10n.bentukTanpaSudut,
    };
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: MociFonts.nunito,
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: MociColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _kisi(AppLocalizations l10n) {
    final pool = _pool;
    return SizedBox(
      width: 420,
      child: Column(
        children: [
          for (var i = 0; i < pool.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              children: [
                _kartu(pool[i], l10n),
                const SizedBox(width: 14),
                if (i + 1 < pool.length) _kartu(pool[i + 1], l10n),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _kartu(BentukEntry b, AppLocalizations l10n) {
    final aktif = b.id == _id;
    final nama = b.nama.of(_lang);
    return MociPressable(
      key: BentukScreen.shapeKey(b.id),
      onTap: () => _pilih(b),
      color: aktif ? _soft : MociColors.white,
      shadowColor: _border,
      depth: 6,
      borderRadius: const BorderRadius.all(Radius.circular(28)),
      semanticLabel: l10n.bentukShapeLabel(nama),
      child: Container(
        width: 203,
        height: 118,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          border: Border.all(
            color: aktif ? _accent : _border,
            width: 5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: FittedBox(
                fit: BoxFit.contain,
                child: BentukShape(bentuk: b, size: 200),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nama,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: MociFonts.fredoka,
                  fontWeight: FontWeight.w600,
                  fontSize: nama.length > 8 ? 19 : 22,
                  height: 1.1,
                  color: MociColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _hex(String value) =>
    Color(0xFF000000 | int.parse(value.replaceFirst('#', ''), radix: 16));
