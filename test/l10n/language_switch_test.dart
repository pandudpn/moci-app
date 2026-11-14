import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/providers.dart';
import 'package:moci/core/storage/key_value_store.dart';
import 'package:moci/l10n/l10n.dart';

Widget _app({Widget Function(BuildContext)? home}) => Consumer(
  builder: (context, ref, _) => MaterialApp(
    locale: Locale(ref.watch(prefsProvider).lang.name),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Builder(builder: home ?? (c) => Text(c.l10n.commonBack)),
  ),
);

ProviderContainer _container(String lang) {
  final store = MemoryKeyValueStore();
  store.setString('moci.bahasa', lang);
  final c = ProviderContainer(
    overrides: [keyValueStoreProvider.overrideWithValue(store)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  testWidgets('bahasa berganti tanpa membangun ulang aplikasi', (tester) async {
    final c = _container('id');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: _app()),
    );
    expect(find.text('Kembali ke beranda'), findsOneWidget);

    await c.read(prefsProvider.notifier).setLang(AppLang.en);
    await tester.pump();
    expect(find.text('Back to home'), findsOneWidget);
  });

  for (final lang in ['id', 'en']) {
    testWidgets('TextField material_ui aman di locale $lang', (tester) async {
      final c = _container(lang);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: _app(
            home: (_) => const Scaffold(body: Material(child: TextField())),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
