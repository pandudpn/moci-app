import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/beranda/beranda_menu.dart';
import 'package:moci/features/beranda/widgets/continue_card.dart';
import 'package:moci/features/beranda/widgets/lang_switch.dart';
import 'package:moci/features/beranda/widgets/parents_button.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

/// Bayangan biru langit prototipe (`#8EC5EE`) dan tinta induk (`#2B2350`).
const _biruLangkah = Color(0xFF8EC5EE);
const _tinta = Color(0xFF2B2350);

void main() {
  testWidgets('kartu, pil bahasa, dan tombol Orang Tua: warna prototipe', (
    t,
  ) async {
    await pumpScreen(
      t,
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ContinueCard(
              menu: BerandaMenu.huruf,
              heading: 'Lanjutkan',
              label: 'Kenal Huruf',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            LangSwitch(lang: AppLang.id, label: 'Bahasa', onChanged: (_) {}),
            const SizedBox(height: 12),
            ParentsButton(label: 'Orang Tua', onTap: () {}),
          ],
        ),
      ),
    );

    final kartu = t.widget<MociPressable>(
      find
          .descendant(
            of: find.byType(ContinueCard),
            matching: find.byType(MociPressable),
          )
          .first,
    );
    expect(kartu.shadowColor, _biruLangkah);

    final pil = t.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(LangSwitch),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (pil.decoration as BoxDecoration).boxShadow!.first.color,
      _biruLangkah,
    );

    final tombol = t.widget<MociPressable>(
      find
          .descendant(
            of: find.byType(ParentsButton),
            matching: find.byType(MociPressable),
          )
          .first,
    );
    expect(tombol.color, _tinta);
  });
}
