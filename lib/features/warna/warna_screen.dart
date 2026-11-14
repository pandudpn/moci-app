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
import '../../core/audio/sfx.dart';
import '../../core/content/content_repository.dart';
import '../../core/content/katalog.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/star_counter.dart';
import 'warna_game.dart';

/// Sumber acak set warna; dites lewat override supaya kartu tetap.
final warnaRandomProvider = Provider<Random>((_) => Random());

/// Layar Warna: satu set 12 kartu untuk satu warna dan 11 chip warna.
class WarnaScreen extends ConsumerStatefulWidget {
  const WarnaScreen({super.key, this.awal});

  static const newSetKey = ValueKey<String>('warna-new-set');
  static const nextColorKey = ValueKey<String>('warna-next-color');

  static ValueKey<String> chipKey(String warna) =>
      ValueKey('warna-chip-$warna');

  static ValueKey<String> kartuKey(String id) => ValueKey('warna-card-$id');

  /// Warna pertama saat layar dibuka; nilai di luar katalog diabaikan.
  final String? awal;

  @override
  ConsumerState<WarnaScreen> createState() => _WarnaScreenState();
}

class _WarnaScreenState extends ConsumerState<WarnaScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF5032B8);
  static const _soft = Color(0xFFF3EEFF);
  static const _softShadow = Color(0xFFD0BFFF);
  static const _cardIdle = Color(0xFFEDE7FF);

  late String _warna;
  late WarnaSet _set;
  final _ditemukan = <String>{};
  String? _salah;
  late final AnimationController _goyang = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _salah = null);
      }
    });

  static final _goyangX = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -12.0, end: 10.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
  ]);

  Katalog get _katalog => ref.read(katalogProvider);

  Random get _acak => ref.read(warnaRandomProvider);

  AppLang get _lang => ref.read(prefsProvider).lang;

  WarnaEntry get _entry =>
      _katalog.warna.firstWhere((w) => w.id == _warna, orElse: () => _katalog.warna.first);

  String get _nama => _entry.nama.of(_lang);

  @override
  void initState() {
    super.initState();
    final awal = widget.awal;
    final ada = _katalog.warna.any((w) => w.id == awal);
    _warna = ada ? awal! : 'merah';
    _set = buatWarnaSet(_katalog, _warna, _acak);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catat();
      _sayInstruksi();
    });
  }

  @override
  void dispose() {
    _goyang.dispose();
    super.dispose();
  }

  void _catat() =>
      ref.read(progressProvider.notifier).setLastActivity(Routes.warna, {
        'warna': _warna,
      });

  NarrationLine _lineWarna() => NarrationLine(
    jenis: 'warna',
    id: _warna,
    text: _nama.toLowerCase(),
  );

  void _say(List<NarrationLine> lines) =>
      ref.read(narratorProvider).sayAll(lines, _lang);

  void _sayInstruksi() => _say([
    NarrationLine(
      jenis: 'ui',
      id: 'warnaSentuh',
      text: context.l10n.warnaSentuh,
    ),
    _lineWarna(),
  ]);

  void _setBaru(String warna) {
    setState(() {
      _warna = warna;
      _set = buatWarnaSet(_katalog, warna, _acak);
      _ditemukan.clear();
      _salah = null;
    });
    _catat();
    _sayInstruksi();
  }

  void _acakUlang() {
    setState(() {
      _set = buatWarnaSet(_katalog, _warna, _acak);
      _ditemukan.clear();
      _salah = null;
    });
  }

  void _ketukKartu(WarnaKartu kartu) {
    if (_ditemukan.contains(kartu.id)) return;
    if (kartu.warna == _warna) {
      setState(() => _ditemukan.add(kartu.id));
      final nama = namaKartu(kartu, _katalog, _lang);
      if (_ditemukan.length == _set.total) {
        ref.read(audioServiceProvider).playSfx(Sfx.sorak);
        _say([
          NarrationLine(
            jenis: 'ui',
            id: 'warnaSemuaKetemu',
            text: context.l10n.warnaSemuaKetemu,
          ),
        ]);
      } else {
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        _say([
          NarrationLine(
            jenis: 'ui',
            id: 'warnaBetul',
            text: context.l10n.warnaBetul,
          ),
          if (nama.isNotEmpty)
            NarrationLine(jenis: 'nama', id: kartu.gambarId!, text: nama),
        ]);
      }
      return;
    }
    ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
    setState(() => _salah = kartu.id);
    _goyang.forward(from: 0);
    _say([
      NarrationLine(
        jenis: 'ui',
        id: 'warnaBukan',
        text: context.l10n.warnaBukan,
      ),
      _lineWarna(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsProvider.select((p) => p.lang));
    ref.watch(katalogProvider);
    return MociStage(theme: MenuTheme.warna, tablet: _tablet);
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
            title: l10n.menuWarnaTitle,
            trailing: [
              MociPressable(
                key: WarnaScreen.newSetKey,
                onTap: _acakUlang,
                color: MociColors.white,
                shadowColor: _softShadow,
                depth: 6,
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                semanticLabel: l10n.warnaNewSet,
                child: SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GameGlyph(GameGlyphKind.refresh, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          l10n.warnaNewSet,
                          style: const TextStyle(
                            fontFamily: MociFonts.fredoka,
                            fontWeight: FontWeight.w600,
                            fontSize: 21,
                            color: MociColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
            ],
          ),
        ),
        Positioned(left: 40, top: 120, child: _panelKiri(l10n)),
        Positioned(left: 400, top: 120, child: _panelKanan(l10n)),
      ],
    );
  }

  Widget _panelKiri(AppLocalizations l10n) {
    final nama = _nama;
    return Container(
      width: 330,
      height: 660,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: _softShadow, offset: Offset(0, 12)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 75,
            top: 18,
            child: MociPressable(
              onTap: _sayInstruksi,
              color: const Color(0x00000000),
              shadowColor: const Color(0x00000000),
              depth: 0,
              borderRadius: const BorderRadius.all(Radius.circular(90)),
              semanticLabel: nama,
              child: SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: _SwatchPainter(_entry.hex, _entry.garis),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 200,
            child: Text(
              nama.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontFamily: MociFonts.fredoka,
                fontWeight: FontWeight.w700,
                fontSize: nama.length > 6 ? 38 : 48,
                letterSpacing: 1,
                color: MociColors.ink,
              ),
            ),
          ),
          Positioned(
            left: 55,
            top: 268,
            child: MociPressable(
              onTap: _sayInstruksi,
              color: const Color(0xFFFFB020),
              shadowColor: const Color(0xFFE0870B),
              depth: 6,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              semanticLabel: l10n.commonListen,
              child: SizedBox(
                width: 220,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const GameGlyph(GameGlyphKind.listen, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      l10n.commonListen,
                      style: const TextStyle(
                        fontFamily: MociFonts.fredoka,
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: MociColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 352,
            child: Text(
              l10n.warnaPick,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: MociFonts.nunito,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF6B5F99),
              ),
            ),
          ),
          Positioned(
            left: 40,
            top: 386,
            width: 252,
            child: Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                for (final w in _katalog.warna) _chip(w, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(WarnaEntry w, AppLocalizations l10n) {
    final aktif = w.id == _warna;
    return MociPressable(
      key: WarnaScreen.chipKey(w.id),
      onTap: () => _setBaru(w.id),
      color: const Color(0x00000000),
      shadowColor: const Color(0x00000000),
      depth: 0,
      borderRadius: const BorderRadius.all(Radius.circular(27)),
      semanticLabel: l10n.warnaChipLabel(w.nama.of(_lang)),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: _hex(w.hex),
          shape: BoxShape.circle,
          border: Border.all(
            color: aktif ? MociColors.ink : MociColors.white,
            width: 5,
          ),
        ),
      ),
    );
  }

  Widget _panelKanan(AppLocalizations l10n) {
    final nama = _nama;
    return Container(
      width: 740,
      height: 660,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: _softShadow, offset: Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 32,
            right: 32,
            top: 24,
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l10n.warnaInstructionPre} ',
                          style: const TextStyle(
                            fontFamily: MociFonts.fredoka,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            color: MociColors.ink,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _hex(_entry.hex),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _hex(_entry.garis), width: 2),
                          ),
                          child: Text(
                            nama.toUpperCase(),
                            style: TextStyle(
                              fontFamily: MociFonts.fredoka,
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                              color: _hex(_entry.teks),
                            ),
                          ),
                        ),
                        const Text(
                          '!',
                          style: TextStyle(
                            fontFamily: MociFonts.fredoka,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            color: MociColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  container: true,
                  label: l10n.warnaCounterLabel(_ditemukan.length, _set.total),
                  excludeSemantics: true,
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: _soft,
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Center(
                      child: Text(
                        '${_ditemukan.length} / ${_set.total}',
                        style: const TextStyle(
                          fontFamily: MociFonts.fredoka,
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          color: _accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(left: 34, top: 104, child: _kisi(l10n)),
          if (_ditemukan.length == _set.total)
            Positioned(
              left: 70,
              bottom: 22,
              child: _bilah(l10n, nama),
            ),
        ],
      ),
    );
  }

  Widget _kisi(AppLocalizations l10n) {
    final kartu = _set.kartu;
    return Column(
      children: [
        for (var baris = 0; baris < 3; baris++) ...[
          if (baris > 0) const SizedBox(height: 20),
          Row(
            children: [
              for (var kolom = 0; kolom < 4; kolom++) ...[
                if (kolom > 0) const SizedBox(width: 20),
                if (baris * 4 + kolom < kartu.length)
                  _kartu(kartu[baris * 4 + kolom]),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _kartu(WarnaKartu kartu) {
    final ketemu = _ditemukan.contains(kartu.id);
    final salah = _salah == kartu.id;
    Widget isi = MociPressable(
      key: WarnaScreen.kartuKey(kartu.id),
      onTap: ketemu ? null : () => _ketukKartu(kartu),
      color: const Color(0xFFFBFAFF),
      shadowColor: const Color(0x00000000),
      depth: 0,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      semanticLabel: _labelKartu(kartu),
      child: Container(
        width: 152,
        height: 152,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          border: Border.all(
            color: ketemu
                ? MociColors.correct
                : salah
                ? const Color(0xFFFF8787)
                : _cardIdle,
            width: 6,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (kartu.gambarId != null)
              MociIllustration(kartu.gambarId!, size: 120)
            else
              _bentuk(kartu.bentuk!),
            if (ketemu)
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: MociColors.correct,
                    shape: BoxShape.circle,
                    border: Border.all(color: MociColors.white, width: 4),
                  ),
                  child: const Center(
                    child: GameGlyph(
                      GameGlyphKind.check,
                      size: 26,
                      color: MociColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (salah) {
      isi = AnimatedBuilder(
        animation: _goyang,
        child: isi,
        builder: (context, child) => Transform.translate(
          offset: Offset(_goyangX.transform(_goyang.value), 0),
          child: child,
        ),
      );
    }
    return isi;
  }

  Widget _bentuk(WarnaBentuk bentuk) {
    final fill = _hex(_entry.hex);
    final line = _hex(_entry.garis);
    return switch (bentuk) {
      WarnaBentuk.balon => SizedBox(
        width: 92,
        height: 120,
        child: CustomPaint(painter: _BalonPainter(fill, line)),
      ),
      WarnaBentuk.bintang => SizedBox(
        width: 112,
        height: 112,
        child: CustomPaint(painter: _BintangPainter(fill, line)),
      ),
      WarnaBentuk.hati => SizedBox(
        width: 110,
        height: 110,
        child: CustomPaint(painter: _HatiPainter(fill, line)),
      ),
    };
  }

  String _labelKartu(WarnaKartu kartu) {
    final nama = namaKartu(kartu, _katalog, _lang);
    if (nama.isNotEmpty) return nama;
    final bentuk = switch (kartu.bentuk!) {
      WarnaBentuk.balon => context.l10n.warnaBalon,
      WarnaBentuk.bintang => context.l10n.warnaBintang,
      WarnaBentuk.hati => context.l10n.warnaHati,
    };
    return '$bentuk ${_nama.toLowerCase()}';
  }

  Widget _bilah(AppLocalizations l10n, String nama) {
    return Container(
      width: 600,
      height: 72,
      padding: const EdgeInsets.fromLTRB(24, 0, 12, 0),
      decoration: BoxDecoration(
        color: MociColors.ink,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        children: [
          const GameGlyph(
            GameGlyphKind.star,
            size: 38,
            color: MociColors.starFill,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.warnaDone(nama.toLowerCase()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: MociFonts.fredoka,
                fontWeight: FontWeight.w600,
                fontSize: 26,
                color: MociColors.white,
              ),
            ),
          ),
          MociPressable(
            key: WarnaScreen.nextColorKey,
            onTap: () => _setBaru(warnaBerikut(_katalog, _warna)),
            color: MociColors.white,
            shadowColor: const Color(0x00000000),
            depth: 0,
            borderRadius: const BorderRadius.all(Radius.circular(27)),
            semanticLabel: l10n.warnaNextColor,
            child: SizedBox(
              height: 54,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.warnaNextColor,
                      style: const TextStyle(
                        fontFamily: MociFonts.fredoka,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: MociColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _hex(String value) =>
    Color(0xFF000000 | int.parse(value.replaceFirst('#', ''), radix: 16));

class _SwatchPainter extends CustomPainter {
  const _SwatchPainter(this.fill, this.line);

  final String fill;
  final String line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 200);
    final isi = Paint()..color = _hex(fill);
    final tepi = Paint()
      ..color = _hex(line)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final path = Path()
      ..moveTo(100, 22)
      ..cubicTo(126, 22, 136, 44, 156, 40)
      ..cubicTo(182, 36, 190, 66, 174, 86)
      ..cubicTo(194, 104, 182, 138, 156, 134)
      ..cubicTo(150, 162, 120, 178, 100, 160)
      ..cubicTo(80, 178, 46, 168, 46, 140)
      ..cubicTo(20, 138, 12, 106, 30, 90)
      ..cubicTo(14, 66, 36, 38, 62, 46)
      ..cubicTo(68, 28, 84, 22, 100, 22)
      ..close();
    canvas.drawPath(path, isi);
    canvas.drawPath(path, tepi);
    for (final (x, y, r) in [(182.0, 34.0, 8.0), (24.0, 164.0, 10.0), (172.0, 172.0, 6.0)]) {
      canvas.drawCircle(Offset(x, y), r, isi);
      canvas.drawCircle(Offset(x, y), r, tepi);
    }
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(74, 72), width: 32, height: 20),
      Paint()..color = const Color(0x8CFFFFFF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.fill != fill || old.line != line;
}

class _BalonPainter extends CustomPainter {
  const _BalonPainter(this.fill, this.line);

  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 130);
    final isi = Paint()..color = fill;
    final tepi = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final balon = Path()
      ..moveTo(50, 8)
      ..cubicTo(74, 8, 90, 28, 90, 52)
      ..cubicTo(90, 78, 70, 98, 50, 100)
      ..cubicTo(30, 98, 10, 78, 10, 52)
      ..cubicTo(10, 28, 26, 8, 50, 8)
      ..close();
    canvas.drawPath(balon, isi);
    canvas.drawPath(balon, tepi);
    canvas.drawPath(
      Path()
        ..moveTo(44, 100)
        ..lineTo(50, 108)
        ..lineTo(56, 100)
        ..close(),
      isi,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(34, 36), width: 16, height: 28),
      Paint()..color = const Color(0x80FFFFFF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BalonPainter old) => old.fill != fill || old.line != line;
}

class _BintangPainter extends CustomPainter {
  const _BintangPainter(this.fill, this.line);

  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    const titik = [
      (50.0, 6.0), (63.0, 33.0), (93.0, 37.0), (71.0, 58.0),
      (76.0, 88.0), (50.0, 74.0), (24.0, 88.0), (29.0, 58.0),
      (7.0, 37.0), (37.0, 33.0),
    ];
    final path = Path()..moveTo(titik.first.$1, titik.first.$2);
    for (final t in titik.skip(1)) {
      path.lineTo(t.$1, t.$2);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(40, 38), width: 12, height: 20),
      Paint()..color = const Color(0x73FFFFFF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BintangPainter old) => old.fill != fill || old.line != line;
}

class _HatiPainter extends CustomPainter {
  const _HatiPainter(this.fill, this.line);

  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final path = Path()
      ..moveTo(50, 88)
      ..cubicTo(20, 66, 8, 50, 8, 32)
      ..cubicTo(8, 18, 19, 8, 32, 8)
      ..cubicTo(40, 8, 47, 12, 50, 19)
      ..cubicTo(53, 12, 60, 8, 68, 8)
      ..cubicTo(81, 8, 92, 18, 92, 32)
      ..cubicTo(92, 50, 80, 66, 50, 88)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(30, 30), width: 16, height: 24),
      Paint()..color = const Color(0x73FFFFFF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatiPainter old) => old.fill != fill || old.line != line;
}
