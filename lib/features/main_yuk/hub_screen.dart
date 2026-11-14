import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout/device_layout.dart';
import '../../app/layout/moci_stage.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/pressable.dart';
import '../../widgets/star_counter.dart';
import 'main_yuk_game.dart';

const _subColor = Color(0xFF3D7F80);
const _ageBackground = Color(0xFFF3EEFF);
const _gridLeft = 69.0;
const _gridTop = 136.0;
const _gridWidth = 1042.0;
const _gridHeight = 606.0;
const _cardWidth = 330.0;
const _cardHeight = 276.0;

/// Hub Main Yuk: enam kartu permainan dengan lencana usia dan bintang.
class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  static ValueKey<String> cardKey(MainYukGame g) =>
      ValueKey('main-yuk-${g.name}');

  static const ageKeyPrefix = 'main-yuk-age-';

  void _open(BuildContext context, WidgetRef ref, MainYukGame game) {
    final l10n = context.l10n;
    // Narasi tidak dihentikan: terus berbunyi di layar berikutnya.
    ref
        .read(narratorProvider)
        .say(
          barisUi(game.labelKey, game.labelHub(l10n)),
          ref.read(prefsProvider).lang,
        );
    context.push(game.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return MociStage(
      theme: MenuTheme.mainYuk,
      tablet: (context) => SizedBox.fromSize(
        size: kTabletBase,
        child: Stack(
          children: [
            Positioned(
              left: 32,
              right: 32,
              top: 22,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MociBackButton(),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.menuMainTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MociText.title,
                        ),
                        Text(
                          l10n.mainYukSub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MociText.label.copyWith(
                            fontSize: 18,
                            color: _subColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
                ],
              ),
            ),
            Positioned(
              left: _gridLeft,
              top: _gridTop,
              width: _gridWidth,
              height: _gridHeight,
              child: Column(
                children: [
                  _row(context, ref, l10n, MainYukGame.values.sublist(0, 3)),
                  const SizedBox(height: 30),
                  _row(context, ref, l10n, MainYukGame.values.sublist(3, 6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<MainYukGame> games,
  ) {
    return Row(
      children: [
        for (var i = 0; i < games.length; i++) ...[
          if (i > 0) const SizedBox(width: 26),
          _HubCard(
            key: cardKey(games[i]),
            game: games[i],
            label: games[i].labelHub(l10n),
            age: games[i].labelUsia(l10n),
            ageKey: ValueKey('$ageKeyPrefix${games[i].name}'),
            onTap: () => _open(context, ref, games[i]),
          ),
        ],
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    super.key,
    required this.game,
    required this.label,
    required this.age,
    required this.ageKey,
    required this.onTap,
  });

  final MainYukGame game;
  final String label;
  final String age;
  final ValueKey<String> ageKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MociPressable(
      onTap: onTap,
      semanticLabel: label,
      depth: 12,
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      child: SizedBox(
        width: _cardWidth,
        height: _cardHeight,
        child: Column(
          children: [
            Expanded(
              child: Center(child: ExcludeSemantics(child: _HubArt(game))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _Pill(game: game, label: label, age: age, ageKey: ageKey),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.game,
    required this.label,
    required this.age,
    required this.ageKey,
  });

  final MainYukGame game;
  final String label;
  final String age;
  final ValueKey<String> ageKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: game.color.withValues(alpha: 0.45), width: 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MociText.button.copyWith(fontSize: 24),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            key: ageKey,
            padding: const EdgeInsets.fromLTRB(9, 4, 10, 4),
            decoration: const BoxDecoration(
              color: _ageBackground,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: game.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(age, style: MociText.label.copyWith(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Seni kartu: cuplikan tiap permainan dari ilustrasi yang sudah ada.
class _HubArt extends StatelessWidget {
  const _HubArt(this.game);

  final MainYukGame game;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: const Size(210, 150),
      child: switch (game) {
        MainYukGame.cocokkan => const _TwinCards(),
        MainYukGame.memori => const _MemoryCards(),
        MainYukGame.bayangan => const _ShadowPair(),
        MainYukGame.puzzle => const _PuzzlePieces(),
        MainYukGame.balon => const _Balloons(),
        MainYukGame.besarKecil => const _Growing(),
      },
    );
  }
}

/// Dua kartu kembar bertumpuk.
class _TwinCards extends StatelessWidget {
  const _TwinCards();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _MiniCard(left: 18, top: 32, angle: -7, ilustrasi: 'apel'),
        _MiniCard(left: 96, top: 22, angle: 6, ilustrasi: 'apel'),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.left,
    required this.top,
    required this.angle,
    required this.ilustrasi,
  });

  static const _size = 86.0;

  final double left;
  final double top;
  final double angle;
  final String ilustrasi;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: Container(
          width: _size,
          height: _size * 1.16,
          decoration: const BoxDecoration(
            color: MociColors.white,
            borderRadius: BorderRadius.all(Radius.circular(18)),
            boxShadow: [
              BoxShadow(color: Color(0xFF9EDCDD), offset: Offset(0, 6)),
            ],
          ),
          child: Center(child: MociIllustration(ilustrasi, size: _size * 0.7)),
        ),
      ),
    );
  }
}

/// Tiga kartu Memori: satu terbuka, dua masih tertutup.
class _MemoryCards extends StatelessWidget {
  const _MemoryCards();

  @override
  Widget build(BuildContext context) {
    Widget card(double left, double top, double angle, {String? id}) =>
        Positioned(
          left: left,
          top: top,
          child: Transform.rotate(
            angle: angle * math.pi / 180,
            child: Container(
              width: 74,
              height: 96,
              decoration: const BoxDecoration(
                color: MociColors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                boxShadow: [
                  BoxShadow(color: Color(0xFF9EDCDD), offset: Offset(0, 6)),
                ],
              ),
              child: id == null
                  ? const Center(child: _CardBack())
                  : Center(child: MociIllustration(id, size: 54)),
            ),
          ),
        );
    return Stack(
      children: [
        card(14, 26, -8),
        card(68, 16, 0, id: 'kucing'),
        card(122, 26, 8),
      ],
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF4DA8FF),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

/// Gambar dan bayangannya berdampingan.
class _ShadowPair extends StatelessWidget {
  const _ShadowPair();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MociIllustration('harimau', size: 96),
        SizedBox(width: 14),
        MociIllustration('harimau', size: 96, silhouette: true),
      ],
    );
  }
}

/// Empat keping puzzle dari satu gambar.
class _PuzzlePieces extends StatelessWidget {
  const _PuzzlePieces();

  static const _tile = 66.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    Widget piece(Alignment a) => ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: SizedBox.square(
        dimension: _tile,
        child: ColoredBox(
          color: MociColors.white,
          child: ClipRect(
            child: Align(
              alignment: a,
              widthFactor: 0.5,
              heightFactor: 0.5,
              child: const MociIllustration('gajah', size: _tile * 2),
            ),
          ),
        ),
      ),
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              piece(Alignment.topLeft),
              const SizedBox(width: _gap),
              piece(Alignment.topRight),
            ],
          ),
          const SizedBox(height: _gap),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              piece(Alignment.bottomLeft),
              const SizedBox(width: _gap),
              piece(Alignment.bottomRight),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tiga balon huruf A, B, C.
class _Balloons extends StatelessWidget {
  const _Balloons();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(top: 18), child: _Balon('A', 54)),
        SizedBox(width: 6),
        Padding(padding: EdgeInsets.only(top: 4), child: _Balon('B', 66)),
        SizedBox(width: 6),
        Padding(padding: EdgeInsets.only(top: 18), child: _Balon('C', 54)),
      ],
    );
  }
}

class _Balon extends StatelessWidget {
  const _Balon(this.huruf, this.size);

  final String huruf;
  final double size;

  static const _warna = [
    Color(0xFFFF7EB6),
    Color(0xFF22C1C3),
    Color(0xFFFFD43B),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _warna[(huruf.codeUnitAt(0) - 65) % _warna.length];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size * 1.18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
          ),
          child: Center(
            child: Text(
              huruf,
              style: MociText.title.copyWith(
                fontSize: size * 0.42,
                height: 1,
                color: MociColors.white,
              ),
            ),
          ),
        ),
        Container(width: 2, height: 20, color: const Color(0xFF129A9C)),
      ],
    );
  }
}

/// Tiga ukuran benda: 56, 84, dan 118.
class _Growing extends StatelessWidget {
  const _Growing();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 2,
          bottom: 8,
          child: MociIllustration('apel', size: 56),
        ),
        Positioned(
          left: 48,
          bottom: 8,
          child: MociIllustration('apel', size: 84),
        ),
        Positioned(
          left: 92,
          bottom: 8,
          child: MociIllustration('apel', size: 118),
        ),
      ],
    );
  }
}
