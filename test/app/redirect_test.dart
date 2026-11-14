import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/redirect.dart';
import 'package:moci/app/routes.dart';

void main() {
  final cases = <(String, bool, bool, bool, String?)>[
    // path, onboarded, limitReached, parentUnlocked, expected
    ('/splash', false, false, false, null),
    ('/', false, false, false, '/sambutan'),
    ('/hewan', false, true, false, '/sambutan'),
    ('/sambutan', false, false, false, null),
    ('/sambutan', true, false, false, '/'),
    ('/', true, false, false, null),
    ('/orang-tua', true, false, false, '/gerbang?lanjut=%2Forang-tua'),
    ('/orang-tua', true, false, true, null),
    ('/hewan', true, true, false, '/habis'),
    ('/istirahat', true, true, false, '/habis'),
    ('/habis', true, true, false, null),
    ('/gerbang', true, true, false, null),
    ('/orang-tua', true, true, true, null),
    ('/orang-tua', true, true, false, '/gerbang?lanjut=%2Forang-tua'),
    ('/habis', true, false, false, '/'),
    // Garis miring di ujung mengikuti aturan path tanpa garis miring.
    ('/orang-tua/', true, false, false, '/gerbang?lanjut=%2Forang-tua'),
    ('/orang-tua/', true, false, true, null),
    ('/sambutan/', false, false, false, null),
    ('/habis/', true, false, false, '/'),
  ];
  for (final (path, onb, lim, par, exp) in cases) {
    test('$path onboarded=$onb limit=$lim parent=$par → $exp', () {
      expect(
        resolveRedirect(
          path: path,
          onboarded: onb,
          limitReached: lim,
          parentUnlocked: par,
        ),
        exp,
      );
    });
  }

  test('garis miring di ujung path dinormalkan', () {
    for (final path in ['/hewan/', '/hewan//', '/hewan']) {
      expect(
        resolveRedirect(
          path: path,
          onboarded: true,
          limitReached: true,
          parentUnlocked: false,
        ),
        '/habis',
        reason: path,
      );
    }
    // Garis miring saja tetap Beranda, bukan path kosong.
    expect(
      resolveRedirect(
        path: '//',
        onboarded: true,
        limitReached: false,
        parentUnlocked: false,
      ),
      isNull,
    );
  });

  test('jenis rute', () {
    expect(routeKindOf('/'), RouteKind.play);
    expect(routeKindOf('/hebat'), RouteKind.play);
    expect(routeKindOf('/gerbang'), RouteKind.parent);
    expect(routeKindOf('/istirahat'), RouteKind.timer);
    expect(routeKindOf('/sambutan'), RouteKind.intro);
  });
}
