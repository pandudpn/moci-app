import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/audio/sfx.dart';
import '../../core/content/angka_kata.dart';
import '../../core/content/content_repository.dart';
import '../../core/content/katalog.dart';
import '../../core/lang.dart';
import '../../core/prefs/app_prefs.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/game_mode_pill.dart';
import '../../widgets/game/progress_dots.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import '../hadiah/hadiah_controller.dart';
import '../hadiah/main_lagi.dart';
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
  static const listenKey = ValueKey<String>('bentuk-listen');
  static const againKey = ValueKey<String>('bentuk-again');
  static const prizeKey = ValueKey<String>('bentuk-prize');

  static ValueKey<int> markKey(int i) => ValueKey<int>(i);

  static ValueKey<String> shapeKey(String id) => ValueKey('bentuk-shape-$id');

  static ValueKey<String> checkKey(String id) => ValueKey('bentuk-check-$id');

  static ValueKey<String> optionKey(String id) => ValueKey('bentuk-option-$id');
  final BentukMode mode;

  /// Bentuk pertama saat layar dibuka; nilai di luar pool diabaikan.
  final String? awal;

  @override
  ConsumerState<BentukScreen> createState() => _BentukScreenState();
}

class _BentukScreenState extends ConsumerState<BentukScreen>
    with TickerProviderStateMixin, MainLagi<BentukScreen> {
  static const _accent = Color(0xFF5C7CFA);
  static const _accentDark = Color(0xFF3B5BDB);
  static const _soft = Color(0xFFEEF1FF);
  static const _border = Color(0xFFC5CEF7);
  static const _fact = Color(0xFF5B5480);
  static const _selesaiTunda = Duration(milliseconds: 1200);

  /// Hanya mode Cari yang membuka Hebat; mode Kenali tidak memutar ronde.
  @override
  void mulaiUlang() {
    if (_mode == BentukMode.cari) _mainLagi();
  }

  @override
  String get ruteMainLagi => Routes.bentuk;

  late BentukMode _mode;
  late String _id;
  int _cetak = 0;
  Timer? _timer;

  // Mode Cari.
  late BentukRonde _ronde;
  late int _seed;
  int _skor = 0;
  int? _salah;
  bool _terkunci = false;
  bool _selesai = false;
  bool _menunggu = false;
  Future<AwardResult>? _hadiah;
  Timer? _lanjut;

  late final AnimationController _goyang = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
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

  AgeLevel get _level => ref.read(prefsProvider).ageLevel;

  Random get _random => ref.read(bentukRandomProvider);

  List<BentukEntry> get _pool {
    final semua = _katalog.bentuk;
    return [
      for (final i in bentukPool(_level))
        if (i < semua.length) semua[i],
    ];
  }

  BentukEntry get _bentuk => _katalog.bentuk.firstWhere(
    (b) => b.id == _id,
    orElse: () => _katalog.bentuk.first,
  );

  /// Indeks `?bentuk=` kalau ada di pool level usia; selain itu null.
  int? get _awalRonde {
    final awal = widget.awal;
    if (awal == null) return null;
    final i = _katalog.bentuk.indexWhere((b) => b.id == awal);
    return i >= 0 && bentukPool(_level).contains(i) ? i : null;
  }

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
    _seed = _random.nextInt(1 << 31);
    _ronde = buatBentukRonde(
      _katalog,
      level: _level,
      random: _random,
      target: _awalRonde,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_mode == BentukMode.cari) {
        _tanya();
      } else {
        _catat();
        _sayNama();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lanjut?.cancel();
    _pop.dispose();
    _goyang.dispose();
    super.dispose();
  }

  void _catat() {
    final id = _mode == BentukMode.cari
        ? _katalog.bentuk[_ronde.target].id
        : _id;
    ref.read(progressProvider.notifier).setLastActivity(Routes.bentuk, {
      'bentuk': id,
      'mode': _mode.name,
    });
  }

  void _say(List<NarrationLine> lines) =>
      ref.read(narratorProvider).sayAll(lines, _lang);

  void _sayNama() => _say([
    NarrationLine(jenis: 'bentuk', id: _id, text: _bentuk.nama.of(_lang)),
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
    _timer?.cancel();
    _lanjut?.cancel();
    setState(() {
      _mode = m;
      if (m == BentukMode.cari) {
        _seed = _random.nextInt(1 << 31);
        _skor = 0;
        _salah = null;
        _terkunci = false;
        _selesai = false;
        _menunggu = false;
        _hadiah = null;
        _ronde = buatBentukRonde(
          _katalog,
          level: _level,
          random: _random,
          target: _awalRonde,
        );
      }
    });
    if (m == BentukMode.cari) {
      _tanya();
    } else {
      _catat();
    }
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
          NarrationLine(jenis: 'fakta', id: _id, text: bentuk.fakta.of(_lang)),
      ]);
      if (selesai) t.cancel();
    });
  }

  /// Soal Cari: pengantar lalu nama target (dua klip narasi).
  void _tanya() {
    final target = _katalog.bentuk[_ronde.target];
    _catat();
    _say([
      NarrationLine(
        jenis: 'ui',
        id: 'bentukQuestionSay',
        text: context.l10n.bentukQuestionSay,
      ),
      NarrationLine(
        jenis: 'bentuk',
        id: target.id,
        text: target.nama.of(_lang),
      ),
    ]);
  }

  void _jawab(int i) {
    if (_selesai || _terkunci) return;
    final indeks = _ronde.opsi[i];
    final bentuk = _katalog.bentuk[indeks];
    if (indeks == _ronde.target) {
      _lanjut?.cancel();
      setState(() {
        _terkunci = true;
        _salah = null;
        _skor += 1;
        _selesai = _skor >= bentukRonde;
      });
      ref.read(audioServiceProvider).playSfx(Sfx.benar);
      if (_selesai) {
        _selesaiRonde();
        return;
      }
      _say([
        NarrationLine(
          jenis: 'ui',
          id: 'bentukYesSay',
          text: context.l10n.bentukYesSay,
        ),
        NarrationLine(
          jenis: 'bentuk',
          id: bentuk.id,
          text: bentuk.nama.of(_lang),
        ),
      ]);
      _lanjut = Timer(_selesaiTunda, () {
        if (!mounted) return;
        _rondeBerikut();
      });
      return;
    }
    setState(() => _salah = i);
    _goyang.forward(from: 0);
    ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
    _say([
      NarrationLine(
        jenis: 'ui',
        id: 'bentukNoSay',
        text: context.l10n.bentukNoSay,
      ),
      NarrationLine(
        jenis: 'bentuk',
        id: bentuk.id,
        text: bentuk.nama.of(_lang),
      ),
      NarrationLine(
        jenis: 'ui',
        id: 'bentukTryAgain',
        text: context.l10n.bentukTryAgain,
      ),
    ]);
  }

  void _rondeBerikut() {
    final sebelumnya = _ronde.target;
    setState(() {
      _ronde = buatBentukRonde(
        _katalog,
        level: _level,
        random: _random,
        hindari: sebelumnya,
      );
      _terkunci = false;
      _salah = null;
    });
    _tanya();
  }

  void _selesaiRonde() {
    _hadiah = ref
        .read(hadiahProvider)
        .finishGame(gameId: 'bentuk', roundId: '$_seed/$bentukRonde');
    ref.read(audioServiceProvider).playSfx(Sfx.sorak);
    _say([
      NarrationLine(
        jenis: 'ui',
        id: 'bentukDone',
        text: context.l10n.bentukDone,
      ),
    ]);
  }

  Future<void> _ambilHadiah() async {
    final hadiah = _hadiah;
    if (hadiah == null || _menunggu) return;
    setState(() => _menunggu = true);
    final award = await hadiah;
    if (!mounted) return;
    context.push(
      Routes.hebat,
      extra: HebatArgs(award: award, replayRoute: '${Routes.bentuk}?mode=cari'),
    );
  }

  void _mainLagi() {
    _lanjut?.cancel();
    setState(() {
      _seed = _random.nextInt(1 << 31);
      _skor = 0;
      _salah = null;
      _terkunci = false;
      _selesai = false;
      _menunggu = false;
      _hadiah = null;
      _ronde = buatBentukRonde(_katalog, level: _level, random: _random);
    });
    _tanya();
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
        if (_mode == BentukMode.cari) ...[
          Positioned(left: 40, top: 120, child: _soalBar(l10n)),
          Positioned(left: 40, top: 236, child: _papan(l10n)),
        ] else ...[
          Positioned(left: 40, top: 122, child: _kartuKiri(l10n)),
          Positioned(left: 720, top: 122, child: _kisi(l10n)),
        ],
      ],
    );
  }

  Widget _soalBar(AppLocalizations l10n) {
    final target = _katalog.bentuk[_ronde.target];
    final nama = target.nama.of(_lang).toLowerCase();
    return Container(
      width: 1100,
      height: 92,
      padding: const EdgeInsets.fromLTRB(14, 0, 22, 0),
      decoration: const BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [BoxShadow(color: _border, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          MociPressable(
            key: BentukScreen.listenKey,
            onTap: _tanya,
            color: _accent,
            shadowColor: _accentDark,
            depth: 5,
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            semanticLabel: l10n.bentukListen,
            child: const SizedBox(
              width: 64,
              height: 64,
              child: Center(
                child: GameGlyph(
                  GameGlyphKind.listen,
                  size: 32,
                  color: MociColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.bentukQuestion(nama),
                  key: BentukScreen.questionKey,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: MociFonts.fredoka,
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    color: MociColors.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ProgressDots(
            count: bentukRonde,
            current: _skor,
            dotSize: 16,
            activeWidth: 34,
            semanticLabel: l10n.bentukProgress(_skor, bentukRonde),
            activeColor: _accent,
          ),
        ],
      ),
    );
  }

  Widget _papan(AppLocalizations l10n) {
    final jumlah = _ronde.opsi.length;
    final ukuran = switch (jumlah) {
      6 => 168.0,
      4 => 196.0,
      _ => 220.0,
    };
    final slot = switch (jumlah) {
      6 => const [
        (183.0, 137.0),
        (550.0, 137.0),
        (917.0, 137.0),
        (183.0, 411.0),
        (550.0, 411.0),
        (917.0, 411.0),
      ],
      4 => const [
        (150.0, 274.0),
        (417.0, 274.0),
        (683.0, 274.0),
        (950.0, 274.0),
      ],
      _ => const [(200.0, 274.0), (550.0, 274.0), (900.0, 274.0)],
    };
    return SizedBox(
      width: 1100,
      height: 548,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: MociColors.white,
                borderRadius: BorderRadius.all(Radius.circular(44)),
                boxShadow: [
                  BoxShadow(color: _border, offset: Offset(0, 12)),
                  BoxShadow(
                    color: Color(0x142B2350),
                    offset: Offset(0, 24),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          for (var i = 0; i < jumlah; i++) _opsi(i, ukuran, slot[i], l10n),
          if (_selesai) Positioned.fill(child: _selesaiPanel(l10n)),
        ],
      ),
    );
  }

  Widget _opsi(
    int i,
    double ukuran,
    (double, double) slot,
    AppLocalizations l10n,
  ) {
    final indeks = _ronde.opsi[i];
    final bentuk = _katalog.bentuk[indeks];
    final warna = _ronde.warna[i];
    final benar = _terkunci && indeks == _ronde.target;
    final salah = _salah == i;
    // Geser kecil tetap, seperti slot prototipe yang tidak pernah rapi.
    final jx = ((_ronde.target * 7 + i * 13) % 31) - 15;
    final jy = ((_ronde.target * 5 + i * 11) % 31) - 15;
    Widget isi = SizedBox(
      width: ukuran,
      height: ukuran,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BentukShape(
            bentuk: bentuk,
            size: ukuran,
            shadow: true,
            warna: salah ? MociColors.wrong : _hex(warna.warna),
            gelap: salah ? const Color(0xFFB32338) : _hex(warna.gelap),
          ),
          if (benar) Positioned(right: -6, top: -6, child: _lencana(bentuk.id)),
        ],
      ),
    );
    if (salah) {
      isi = AnimatedBuilder(
        animation: _goyang,
        child: isi,
        builder: (context, child) {
          final t = _goyang.value;
          return Transform.translate(
            offset: Offset(sin(t * pi * 6) * 10 * (1 - t), 0),
            child: child,
          );
        },
      );
    }
    return Positioned(
      left: slot.$1 - ukuran / 2 + jx,
      top: slot.$2 - ukuran / 2 + jy,
      child: MociPressable(
        key: BentukScreen.optionKey(bentuk.id),
        onTap: () => _jawab(i),
        color: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
        depth: 0,
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        semanticLabel: l10n.bentukShapeLabel(bentuk.nama.of(_lang)),
        child: isi,
      ),
    );
  }

  Widget _lencana(String id) => Container(
    key: BentukScreen.checkKey(id),
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: MociColors.correct,
      shape: BoxShape.circle,
      border: Border.all(color: MociColors.white, width: 4),
    ),
    child: const Center(
      child: GameGlyph(GameGlyphKind.check, size: 30, color: MociColors.white),
    ),
  );

  Widget _selesaiPanel(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF0FFFFFF),
        borderRadius: BorderRadius.circular(44),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MociMascot(size: 200, idle: false),
          const SizedBox(height: 12),
          Text(
            l10n.bentukDone,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: MociFonts.fredoka,
              fontWeight: FontWeight.w700,
              fontSize: 44,
              color: MociColors.ink,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MociPressable(
                key: BentukScreen.againKey,
                onTap: _mainLagi,
                color: MociColors.white,
                shadowColor: _border,
                depth: 7,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                semanticLabel: l10n.bentukAgain,
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _border, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      l10n.bentukAgain,
                      style: const TextStyle(
                        fontFamily: MociFonts.fredoka,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: MociColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              MociPressable(
                key: BentukScreen.prizeKey,
                onTap: _menunggu ? null : _ambilHadiah,
                color: MociColors.correct,
                shadowColor: MociColors.correctShadow,
                depth: 7,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                semanticLabel: l10n.bentukPrize,
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Center(
                    child: Text(
                      l10n.bentukPrize,
                      style: const TextStyle(
                        fontFamily: MociFonts.fredoka,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: MociColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        boxShadow: const [BoxShadow(color: _border, offset: Offset(0, 14))],
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
                    NarrationLine(jenis: 'bentuk', id: _id, text: nama),
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
          border: Border.all(color: aktif ? _accent : _border, width: 5),
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
