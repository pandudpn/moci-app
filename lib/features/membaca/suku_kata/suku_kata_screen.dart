import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/layout/moci_stage.dart';
import '../../../app/routes.dart';
import '../../../app/theme/menu_theme.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_metrics.dart';
import '../../../app/theme/moci_text.dart';
import '../../../core/audio/audio_providers.dart';
import '../../../core/audio/narrator.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/content/katalog.dart';
import '../../../core/lang.dart';
import '../../../core/prefs/prefs_controller.dart';
import '../../../core/progress/progress_controller.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/game/game_glyphs.dart';
import '../../../widgets/moci_illustration.dart';
import '../../../widgets/moci_mascot.dart';
import '../../../widgets/pressable.dart';
import '../suku_kata/suku_kata_game.dart';
import '../widgets/membaca_top_bar.dart';

/// Warna vokal prototipe: [isi, bayangan].
const _vokalWarna = {
  'a': (Color(0xFFE8384F), Color(0xFFB82A3E)),
  'i': (Color(0xFF1C7ED6), Color(0xFF1565B0)),
  'u': (Color(0xFF2F9E44), Color(0xFF237A34)),
  'e': (Color(0xFFF08C00), Color(0xFFC46F00)),
  'o': (Color(0xFF7048E8), Color(0xFF5032B8)),
};

const _putih = MociColors.white;
const _tinta = MociColors.ink;
const _tintaSoft = MociColors.inkSoft;

class SukuKataScreen extends ConsumerStatefulWidget {
  const SukuKataScreen({super.key, this.awal});

  /// Konsonan dari `?huruf=`; nilai di luar kisi diabaikan.
  final String? awal;

  static ValueKey<String> konsonanKey(String k) =>
      ValueKey('suku-kata-konsonan-$k');
  static ValueKey<String> sukuKey(String suku) => ValueKey('suku-kata-$suku');
  static const listenKey = ValueKey<String>('suku-kata-listen');
  static const readAllKey = ValueKey<String>('suku-kata-read-all');

  @override
  ConsumerState<SukuKataScreen> createState() => _SukuKataScreenState();
}

class _SukuKataScreenState extends ConsumerState<SukuKataScreen> {
  late final SukuKataInfo _info;
  late final Narrator _narrator;
  late String _konsonan;
  String _vokal = 'a';
  int _sorot = -1;

  /// Penghitung generasi: ketukan baru menghentikan urutan lama.
  int _urutan = 0;

  @override
  void initState() {
    super.initState();
    _info = ref.read(katalogProvider).sukuKata;
    _narrator = ref.read(narratorProvider);
    final k = (widget.awal ?? 'b').toLowerCase();
    _konsonan = konsonanKisi(_info).contains(k) ? k : 'b';
    // Progres tidak boleh diubah saat pohon sedang dibangun.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = context.l10n;
      _catat();
      _baca([
        NarrationLine(jenis: 'ui', id: 'sukuKataTip', text: l10n.sukuKataTip),
      ]);
    });
  }

  @override
  void dispose() {
    _urutan++;
    _narrator.stop();
    super.dispose();
  }

  void _catat() {
    ref.read(progressProvider.notifier).setLastActivity(Routes.sukuKata, {
      'huruf': _konsonan,
    });
  }

  Future<void> _baca(List<NarrationLine> baris) {
    _urutan++;
    return _narrator.sayAll(baris, ref.read(prefsProvider).lang);
  }

  /// Membacakan kelima suku baris ini sambil menyorot kartunya.
  Future<void> _bacaBaris() async {
    final gen = ++_urutan;
    final lang = ref.read(prefsProvider).lang;
    final baris = barisKonsonan(_info, _konsonan, lang);
    for (var i = 0; i < baris.length; i++) {
      if (!mounted || gen != _urutan) return;
      setState(() => _sorot = i);
      await _narrator.say(_sukuLine(baris[i].suku), lang);
    }
  }

  NarrationLine _sukuLine(String suku) =>
      NarrationLine(jenis: 'suku', id: suku, text: suku);

  void _pilihKonsonan(String k) {
    setState(() {
      _konsonan = k;
      _vokal = 'a';
      _sorot = -1;
    });
    _catat();
    _bacaBaris();
  }

  void _pilihSuku(SukuKartu kartu, int i) {
    _urutan++;
    setState(() {
      _vokal = kartu.vokal;
      _sorot = i;
    });
    ref
        .read(progressProvider.notifier)
        .markItem('membaca', 'dibaca', kartu.suku);
    _baca([_sukuLine(kartu.suku)]);
  }

  void _dengarContoh(SukuKartu kartu) {
    final contoh = kartu.contoh;
    _baca([
      _sukuLine(kartu.suku),
      if (contoh != null)
        NarrationLine(jenis: 'nama', id: contoh.item, text: contoh.kata),
    ]);
  }

  void _bacaSemua() {
    _bacaBaris();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    ref.listen(prefsProvider.select((p) => p.lang), (prev, next) {
      if (prev == next) return;
      _urutan++;
      _narrator.stop();
      if (mounted) setState(() => _sorot = -1);
    });

    final baris = barisKonsonan(_info, _konsonan, lang);
    final vokalIndex = vokalKisi(_info).indexOf(_vokal);
    final kartu = vokalIndex < 0 ? baris.first : baris[vokalIndex];
    return MociStage(
      theme: MenuTheme.membaca,
      tablet: (context) => _panggung(context, baris, kartu, lang),
    );
  }

  Widget _panggung(
    BuildContext context,
    List<SukuKartu> baris,
    SukuKartu kartu,
    AppLang lang,
  ) {
    final l10n = context.l10n;
    return Stack(
      children: [
        Positioned(left: 0, right: 0, top: 0, child: const MembacaTopBar()),
        Positioned(
          left: 32,
          top: 122,
          width: 300,
          height: 660,
          child: _kartuKiri(l10n),
        ),
        Positioned(
          left: 356,
          top: 122,
          width: 792,
          height: 660,
          child: _kartuKanan(l10n, baris, kartu),
        ),
      ],
    );
  }

  Widget _kartuKiri(AppLocalizations l10n) {
    final konsonan = konsonanKisi(_info);
    return _Panel(
      radius: 40,
      depth: 12,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            child: Text(
              l10n.sukuKataPilih,
              textAlign: TextAlign.center,
              style: MociText.label.copyWith(color: _tintaSoft, fontSize: 18),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            top: 56,
            child: Wrap(
              // Empat sel sentuh 64 pt memenuhi lebar kartu; jarak visual
              // datang dari sel 56 pt di tengah area sentuh.
              spacing: 0,
              runSpacing: 2,
              children: [for (final k in konsonan) _selKonsonan(k, l10n)],
            ),
          ),
          const Positioned(left: 100, bottom: 74, child: MociMascot(size: 100)),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Text(
              l10n.sukuKataTip,
              textAlign: TextAlign.center,
              style: MociText.label.copyWith(
                color: _tintaSoft,
                fontSize: 15,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selKonsonan(String k, AppLocalizations l10n) {
    final aktif = k == _konsonan;
    return MociPressable(
      key: SukuKataScreen.konsonanKey(k),
      onTap: () => _pilihKonsonan(k),
      color: aktif ? membacaAccent : const Color(0xFFFFF1E6),
      shadowColor: aktif ? const Color(0xFFA9480D) : const Color(0xFFF7C9A5),
      depth: 5,
      borderRadius: BorderRadius.circular(18),
      semanticLabel: l10n.sukuKataLetter(k.toUpperCase()),
      minTouch: MociSize.minTouchTablet,
      child: SizedBox(
        width: 56.5,
        height: 56,
        child: Center(
          child: Text(
            k.toUpperCase(),
            style: MociText.title.copyWith(
              fontSize: 30,
              color: aktif ? _putih : _tinta,
            ),
          ),
        ),
      ),
    );
  }

  Widget _kartuKanan(
    AppLocalizations l10n,
    List<SukuKartu> baris,
    SukuKartu kartu,
  ) {
    final warna = _vokalWarna[kartu.vokal] ?? (_tinta, _tintaSoft);
    return _Panel(
      radius: 44,
      depth: 14,
      child: Stack(
        children: [
          Positioned(left: 0, right: 0, top: 26, child: _kepala(l10n, baris)),
          Positioned(
            left: 36,
            right: 36,
            top: 132,
            child: Row(
              children: [
                for (var i = 0; i < baris.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(child: _kartuSuku(baris[i], i, l10n)),
                ],
              ],
            ),
          ),
          Positioned(
            left: 36,
            right: 36,
            top: 330,
            height: 290,
            child: _kartuContoh(l10n, kartu, warna.$1),
          ),
        ],
      ),
    );
  }

  Widget _kepala(AppLocalizations l10n, List<SukuKartu> baris) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 78,
          height: 78,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _tinta,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            _konsonan.toUpperCase(),
            style: MociText.title.copyWith(fontSize: 50, color: _putih),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          '+',
          style: MociText.title.copyWith(
            fontSize: 44,
            color: const Color(0xFFADB5BD),
          ),
        ),
        const SizedBox(width: 14),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 0; i < baris.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _vokalWarna[baris[i].vokal]?.$1 ?? _tinta,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    baris[i].vokal,
                    style: MociText.title.copyWith(fontSize: 34, color: _putih),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _kartuSuku(SukuKartu kartu, int i, AppLocalizations l10n) {
    final warna = _vokalWarna[kartu.vokal] ?? (_tinta, _tintaSoft);
    final aktif = i == _sorot;
    final kartuWidget = MociPressable(
      key: SukuKataScreen.sukuKey(kartu.suku),
      onTap: () => _pilihSuku(kartu, i),
      color: warna.$1,
      shadowColor: warna.$2,
      depth: 9,
      borderRadius: BorderRadius.circular(34),
      semanticLabel: l10n.sukuKataSyllable(kartu.suku),
      minTouch: MociSize.minTouchTablet,
      child: SizedBox(
        height: 150,
        child: Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: kartu.konsonan,
                  style: TextStyle(color: _putih.withValues(alpha: 0.85)),
                ),
                TextSpan(text: kartu.vokal),
              ],
            ),
            style: MociText.title.copyWith(
              fontSize: 64,
              color: _putih,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: Offset(0, aktif ? -10 : 0),
          child: Transform.scale(scale: aktif ? 1.06 : 1, child: kartuWidget),
        ),
        const SizedBox(height: 12),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: aktif ? warna.$1 : const Color(0x00000000),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _kartuContoh(AppLocalizations l10n, SukuKartu kartu, Color warna) {
    final contoh = kartu.contoh;
    final kata = contoh?.kata ?? kartu.suku;
    final potong = pecahContoh(kata, kartu.suku);
    final fs = kata.length > 9 ? 56.0 : 76.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EE),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            SizedBox(
              width: 210,
              height: 210,
              child: contoh == null
                  ? DecoratedBox(
                      decoration: const BoxDecoration(
                        color: _putih,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          kartu.suku,
                          style: MociText.title.copyWith(
                            fontSize: 90,
                            color: warna,
                          ),
                        ),
                      ),
                    )
                  : MociIllustration(contoh.item, size: 210),
            ),
            const SizedBox(width: 26),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contoh == null ? l10n.sukuKataSayIt : l10n.sukuKataExample,
                    style: MociText.label.copyWith(
                      fontSize: 18,
                      color: _tintaSoft,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: potong.awalan,
                            style: TextStyle(
                              color: warna,
                              decoration: TextDecoration.underline,
                              decorationThickness: 6,
                              decorationColor: warna,
                            ),
                          ),
                          TextSpan(text: potong.sisa),
                        ],
                      ),
                      maxLines: 1,
                      style: MociText.title.copyWith(
                        fontSize: fs,
                        color: _tinta,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _tombol(
                        key: SukuKataScreen.listenKey,
                        label: l10n.sukuKataHear,
                        color: const Color(0xFFFFB020),
                        shadow: const Color(0xFFE0870B),
                        textColor: _tinta,
                        glyph: const GameGlyph(GameGlyphKind.listen, size: 26),
                        onTap: () => _dengarContoh(kartu),
                      ),
                      const SizedBox(width: 12),
                      _tombol(
                        key: SukuKataScreen.readAllKey,
                        label: l10n.sukuKataReadAll,
                        color: membacaAccent,
                        shadow: const Color(0xFFA9480D),
                        textColor: _putih,
                        glyph: const GameGlyph(
                          GameGlyphKind.play,
                          size: 24,
                          color: _putih,
                        ),
                        onTap: _bacaSemua,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombol({
    required Key key,
    required String label,
    required Color color,
    required Color shadow,
    required Color textColor,
    required Widget glyph,
    required VoidCallback onTap,
  }) {
    return MociPressable(
      key: key,
      onTap: onTap,
      color: color,
      shadowColor: shadow,
      depth: 6,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: label,
      minTouch: MociSize.minTouchTablet,
      clickSound: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              glyph,
              const SizedBox(width: 8),
              Text(
                label,
                style: MociText.button.copyWith(fontSize: 21, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel putih dengan bayangan padat tema.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.radius,
    required this.depth,
    required this.child,
  });

  final double radius;
  final double depth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _putih,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: MenuThemeScope.of(context).shadow,
            offset: Offset(0, depth),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
