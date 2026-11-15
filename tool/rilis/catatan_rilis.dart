/// Release notes grouped from the commits themselves.
///
/// `gh release create --generate-notes` lists merged pull requests only, and
/// most changes here go straight to main. These notes are built from the main
/// line instead: a merged pull request is one entry linked to the pull request,
/// its own commits folded into it; a commit made on main is one entry linked to
/// the commit. Subjects are parsed as conventional commits and grouped, and the
/// people who wrote the release are listed at the end.
///
///   fvm dart run tool/rilis/catatan_rilis.dart --to v1.1.0
///   fvm dart run tool/rilis/catatan_rilis.dart --from v1.0.0 --to v1.1.0 \
///     --write RELEASE_NOTES.md
///
/// A release can also speak in a person's voice: commit a `SUMMARY.md` with the
/// release title and a short version of what it brings, and `--summary` puts it
/// above the generated body. The release workflow snapshots the file when it
/// cuts the release and the bump commit clears it, so one release's words never
/// speak for the next.
library;

import 'dart:io';

/// The headings and the commit types that feed them, in display order.
///
/// Breaking changes come from a `!` in the subject, whatever the type is.
const _judul = <String, String>{
  'feat': 'Features',
  'fix': 'Fixes',
  'docs': 'Documentation',
  'ci': 'Build and CI',
  'build': 'Build and CI',
  'test': 'Other changes',
  'refactor': 'Other changes',
  'chore': 'Other changes',
};

/// Display order matters more than the alphabet: what a user must act on comes first.
const _urutanJudul = [
  'Breaking changes',
  'Features',
  'Fixes',
  'Documentation',
  'Build and CI',
];

/// Printed below the summary and above the entries, the same in every release.
const _pemasangan = '''
### Install

- **Android**: download the `.apk` and install it directly. Allow installs from unknown sources when asked.
- **iPhone and iPad**: download the `.ipa` and install it with [Sideloadly](https://sideloadly.io) or [AltStore](https://altstore.io) using your own Apple ID. The file is unsigned, so the tool signs it for you; with a free Apple account the app stops opening after 7 days and must be signed again.
- **Google Play**: the `.aab` is for the Play Store only and cannot be installed directly.''';

final _polaSubjek = RegExp(r'^([a-zA-Z]+)(?:\(([^)]+)\))?(!)?: (.+)$');
final _polaRujukan = RegExp(r'(?:^|[^\w&])#(\d+)');
final _polaGabung = RegExp(
  r'^Merge pull request #(\d+)(?: from \S+)?(?::\s*(.*))?$',
);

/// A version bump, or the revert of one, says nothing a reader of the notes needs.
final _polaRilis = RegExp(r'^(?:Revert ")?chore\((?:release|rilis)\):');

/// Fields and records of `git log`, chosen so no subject or body can contain them.
const _pemisah = '\x1f';
const _akhir = '\x1e';

/// A person behind a commit.
final class Penulis {
  const Penulis(this.nama, this.email);

  final String nama;
  final String email;

  bool get bot => nama.contains('[bot]') || email.contains('[bot]');
}

/// One entry in the notes: a commit on main, or a merged pull request.
final class Komit {
  Komit({
    required this.sha,
    required this.subject,
    this.jenis = 'other',
    this.scope = '',
    this.teks = '',
    this.rujukan = const [],
    this.pull = 0,
    this.penulis = const [],
  });

  final String sha;
  final String subject;
  final String jenis;
  final String scope;
  final String teks;

  /// Issue numbers the subject mentions, without the pull request's own number.
  final List<int> rujukan;

  /// The pull request this entry stands for; 0 for a commit made on main.
  final int pull;
  final List<Penulis> penulis;
}

/// A git command that failed, with the message git printed.
final class GitGalat implements Exception {
  GitGalat(this.argumen, this.pesan);

  final List<String> argumen;
  final String pesan;

  @override
  String toString() => 'git ${argumen.join(' ')}: $pesan';
}

/// Runs git in one repository.
final class Git {
  Git(this.root);

  final String root;

  /// Runs [argumen] and returns stdout, or throws [GitGalat].
  String jalankan(List<String> argumen) {
    final hasil = Process.runSync(
      'git',
      argumen,
      workingDirectory: root,
      stdoutEncoding: null,
      stderrEncoding: null,
    );
    if (hasil.exitCode != 0) {
      throw GitGalat(argumen, _utf8(hasil.stderr as List<int>));
    }
    return _utf8(hasil.stdout as List<int>);
  }

  /// Runs [argumen] and returns stdout, or null when git fails.
  String? coba(List<String> argumen) {
    try {
      return jalankan(argumen);
    } on GitGalat {
      return null;
    } on ProcessException {
      return null;
    }
  }
}

String _utf8(List<int> bytes) => const SystemEncoding().decode(bytes);

/// Splits a conventional subject into its type, scope, and text.
Komit uraiKomit(
  String sha,
  String subject, {
  int pull = 0,
  List<Penulis> penulis = const [],
}) {
  final cocok = _polaSubjek.firstMatch(subject);
  final kind = cocok == null
      ? 'other'
      : (cocok.group(3) == '!' ? 'breaking' : cocok.group(1)!.toLowerCase());
  final rujukan = <int>{
    for (final m in _polaRujukan.allMatches(subject)) int.parse(m.group(1)!),
  }..remove(pull);
  return Komit(
    sha: sha,
    subject: subject,
    jenis: kind,
    scope: (cocok?.group(2) ?? '').trim(),
    teks: cocok == null ? subject.trim() : cocok.group(4)!.trim(),
    rujukan: rujukan.toList()..sort(),
    pull: pull,
    penulis: penulis,
  );
}

/// Everyone who wrote a commit in [revisi], in the order they first appear.
List<Penulis> penulisDari(Git git, String revisi) {
  final terlihat = <String, Penulis>{};
  final keluaran = git.jalankan([
    'log',
    '--reverse',
    '--format=%an$_pemisah%ae',
    revisi,
  ]);
  for (final baris in keluaran.split('\n')) {
    if (baris.isEmpty) continue;
    final potong = baris.indexOf(_pemisah);
    final nama = potong < 0 ? baris : baris.substring(0, potong);
    final email = potong < 0 ? '' : baris.substring(potong + 1);
    terlihat.putIfAbsent(email.toLowerCase(), () => Penulis(nama, email));
  }
  return terlihat.values.toList();
}

/// The main line between two tags: one entry per commit made on main or pull
/// request merged.
List<Komit> catatan(Git git, String dari, String ke) {
  final revisi = dari.isEmpty ? ke : '$dari..$ke';
  final keluaran = git.jalankan([
    'log',
    '--first-parent',
    '--format=%h$_pemisah%P$_pemisah%an$_pemisah%ae$_pemisah%s$_pemisah%b$_akhir',
    revisi,
  ]);
  final hasil = <Komit>[];
  for (final rekaman in keluaran.split(_akhir)) {
    final bersih = rekaman.replaceAll(RegExp(r'^\n+|\n+$'), '');
    if (bersih.trim().isEmpty) continue;
    final bagian = bersih.split(_pemisah);
    if (bagian.length < 6) continue;
    final sha = bagian[0];
    final induk = bagian[1].trim().split(RegExp(r'\s+'));
    final subjek = bagian[4];
    final badan = bagian.sublist(5).join(_pemisah);
    if (_polaRilis.hasMatch(subjek)) continue;
    final gabung = _polaGabung.firstMatch(subjek);
    final Komit komit;
    if (gabung != null && induk.length == 2) {
      final baris = badan
          .split('\n')
          .map((satu) => satu.trim())
          .where((satu) => satu.isNotEmpty);
      final judul = baris.isEmpty ? '' : baris.first;
      komit = uraiKomit(
        sha,
        judul.isEmpty ? (gabung.group(2) ?? subjek) : judul,
        pull: int.parse(gabung.group(1)!),
        penulis: penulisDari(git, '${induk[0]}..${induk[1]}'),
      );
    } else if (induk.length > 1) {
      continue; // a merge that is not a pull request carries no change of its own
    } else {
      komit = uraiKomit(sha, subjek, penulis: [Penulis(bagian[2], bagian[3])]);
    }
    // A machine writes no release entry: bumps, generated files, and their ilk.
    if (komit.penulis.isNotEmpty && komit.penulis.every((p) => p.bot)) {
      continue;
    }
    hasil.add(komit);
  }
  return hasil;
}

/// The tag before [ke], or an empty string for the first release.
String tagSebelumnya(Git git, String ke) =>
    (git.coba(['describe', '--tags', '--abbrev=0', '$ke^']) ?? '').trim();

/// Author emails already in the history the previous release shipped.
Set<String> emailDikenal(Git git, String dari) {
  if (dari.isEmpty) return {};
  return {
    for (final email in git.jalankan(['log', '--format=%ae', dari]).split('\n'))
      if (email.isNotEmpty) email.toLowerCase(),
  };
}

/// `owner/repo` from the origin remote, or an empty string.
String slugRepo(Git git) {
  final url = (git.coba(['remote', 'get-url', 'origin']) ?? '').trim();
  for (final pola in [
    RegExp(r'^git@github\.com:(?<slug>[^/]+/[^/]+?)(?:\.git)?$'),
    RegExp(r'^https://(?:[^@]+@)?github\.com/(?<slug>[^/]+/[^/]+?)(?:\.git)?$'),
  ]) {
    final cocok = pola.firstMatch(url);
    if (cocok != null) return cocok.namedGroup('slug')!;
  }
  return '';
}

/// GitHub usernames by author email, looked up from one commit each author wrote.
///
/// An author GitHub cannot match to an account (or no network, or no gh) keeps
/// their git name in the notes, without the @ that would link the wrong person.
Future<Map<String, String>> loginGithub(
  Git git,
  List<Komit> komits,
  String slug,
) async {
  final login = <String, String>{};
  if (slug.isEmpty) return login;
  for (final komit in komits) {
    for (final penulis in komit.penulis) {
      final email = penulis.email.toLowerCase();
      if (login.containsKey(email) || penulis.bot) continue;
      login[email] = await _loginUntuk(git, slug, komit, penulis);
    }
  }
  return login;
}

Future<String> _loginUntuk(
  Git git,
  String slug,
  Komit komit,
  Penulis penulis,
) async {
  try {
    final revisi = komit.pull == 0 ? komit.sha : '${komit.sha}^2';
    final sha =
        (git.coba([
                  'log',
                  '-1',
                  '--fixed-strings',
                  '--author=<${penulis.email}>',
                  '--format=%H',
                  revisi,
                ]) ??
                '')
            .trim();
    if (sha.isEmpty) return '';
    final hasil = await Process.run('gh', [
      'api',
      'repos/$slug/commits/$sha',
      '--jq',
      '.author.login // ""',
    ]).timeout(const Duration(seconds: 30));
    return (hasil.stdout as String).trim();
  } catch (_) {
    // No gh, no token, or no network: the notes fall back to the git name.
    return '';
  }
}

/// The notes body: the summary and the install steps, then the grouped entries.
String susun({
  required List<Komit> komits,
  required String dari,
  required String ke,
  required String base,
  Map<String, String> logins = const {},
  Set<String> dikenal = const {},
  String ringkasan = '',
}) {
  String tautan(Komit komit) => komit.pull > 0
      ? '[#${komit.pull}]($base/pull/${komit.pull})'
      : '[${komit.sha}]($base/commit/${komit.sha})';

  String siapa(Penulis penulis) {
    final login = logins[penulis.email.toLowerCase()] ?? '';
    return login.isEmpty ? penulis.nama : '@$login';
  }

  String entri(Komit komit, {bool scopeTebal = true}) {
    final teks = scopeTebal && komit.scope.isNotEmpty
        ? '**${komit.scope}**: ${komit.teks}'
        : komit.teks;
    final kredit = komit.penulis
        .where((penulis) => !penulis.bot)
        .map((penulis) => ' ${siapa(penulis)}')
        .join();
    var baris = '- $teks (${tautan(komit)}$kredit)';
    for (final nomor in komit.rujukan) {
      baris += ', #$nomor';
    }
    return baris;
  }

  final kelompok = <String, List<(Komit, bool)>>{};
  for (final komit in komits) {
    final judul = komit.jenis == 'breaking'
        ? 'Breaking changes'
        : (_judul[komit.jenis] ?? 'Other changes');
    final tebal = komit.jenis == 'breaking' || _judul.containsKey(komit.jenis);
    kelompok.putIfAbsent(judul, () => []).add((komit, tebal));
  }

  final baris = <String>[];
  if (ringkasan.trim().isNotEmpty) {
    baris
      ..addAll(ringkasan.trim().split('\n'))
      ..add('');
  }
  baris
    ..addAll(_pemasangan.split('\n'))
    ..add('');
  for (final judul in [..._urutanJudul, 'Other changes']) {
    final isi = kelompok.remove(judul);
    if (isi == null || isi.isEmpty) continue;
    baris
      ..add('### $judul')
      ..add('');
    baris.addAll([
      for (final (komit, tebal) in isi) entri(komit, scopeTebal: tebal),
    ]);
    baris.add('');
  }

  // Oldest first, so a contribution is credited to the entry that brought the
  // person in.
  final orang = <String, (Penulis, Komit)>{};
  for (final komit in komits.reversed) {
    for (final penulis in komit.penulis) {
      if (!penulis.bot) {
        orang.putIfAbsent(penulis.email.toLowerCase(), () => (penulis, komit));
      }
    }
  }
  if (orang.isNotEmpty) {
    final nama = {
      for (final (penulis, _) in orang.values) siapa(penulis),
    }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    baris
      ..add('### Contributors')
      ..add('')
      ..addAll([for (final satu in nama) '- $satu'])
      ..add('');
  }
  final pendatang = [
    for (final entri in orang.entries)
      if (dari.isNotEmpty && !dikenal.contains(entri.key)) entri.value,
  ];
  if (pendatang.isNotEmpty) {
    baris
      ..add('### New contributors')
      ..add('')
      ..addAll([
        for (final (penulis, komit) in pendatang)
          '- ${siapa(penulis)} made their first contribution in ${tautan(komit)}',
      ])
      ..add('');
  }

  baris.add(
    dari.isEmpty
        ? '**Full changelog**: $base/commits/$ke'
        : '**Full changelog**: $base/compare/$dari...$ke',
  );
  return '${baris.join('\n').trim()}\n';
}

/// The hand-written summary, or an empty string when the file is absent.
String bacaRingkasan(String path) {
  if (path.isEmpty) return '';
  final berkas = File(path);
  if (!berkas.existsSync()) return '';
  return berkas.readAsStringSync().trim();
}

/// The parsed command line.
final class Opsi {
  const Opsi({
    this.dari = '',
    this.ke = 'HEAD',
    this.tulis = '',
    this.ringkasan = '',
  });

  final String dari;
  final String ke;
  final String tulis;
  final String ringkasan;
}

/// Reads `--from`, `--to`, `--write`, and `--summary`; both `--flag value` and
/// `--flag=value` are accepted.
Opsi uraiArgumen(List<String> argumen) {
  String dari = '';
  var ke = 'HEAD';
  var tulis = '';
  var ringkasan = '';
  for (var i = 0; i < argumen.length; i++) {
    final bagian = argumen[i].split('=');
    final nama = bagian.first;
    String nilai() {
      if (bagian.length > 1) return bagian.sublist(1).join('=');
      if (i + 1 >= argumen.length) {
        throw FormatException('$nama needs a value');
      }
      i++;
      return argumen[i];
    }

    switch (nama) {
      case '--from':
        dari = nilai();
      case '--to':
        ke = nilai();
      case '--write':
        tulis = nilai();
      case '--summary':
        ringkasan = nilai();
      default:
        throw FormatException('unknown argument: ${argumen[i]}');
    }
  }
  return Opsi(dari: dari, ke: ke, tulis: tulis, ringkasan: ringkasan);
}

/// Builds the notes and prints or writes them. Returns the process exit code.
Future<int> jalankan(List<String> argumen, {Git? git}) async {
  final Opsi opsi;
  try {
    opsi = uraiArgumen(argumen);
  } on FormatException catch (galat) {
    stderr.writeln('error: ${galat.message}');
    stderr.writeln(
      'usage: dart run tool/rilis/catatan_rilis.dart [--from TAG] [--to TAG] '
      '[--summary FILE] [--write FILE]',
    );
    return 64;
  }
  final repo = git ?? Git(Directory.current.path);
  final dari = opsi.dari.isNotEmpty ? opsi.dari : tagSebelumnya(repo, opsi.ke);
  final List<Komit> komits;
  final Set<String> dikenal;
  try {
    komits = catatan(repo, dari, opsi.ke);
    dikenal = emailDikenal(repo, dari);
  } on GitGalat catch (galat) {
    stderr.writeln('error: git log failed: $galat');
    return 1;
  }
  if (komits.isEmpty) {
    stderr.writeln(
      'error: no commits in range, refusing to publish empty notes',
    );
    return 1;
  }

  final slug = slugRepo(repo);
  final base = slug.isEmpty ? '' : 'https://github.com/$slug';
  final badan = susun(
    komits: komits,
    dari: dari,
    ke: opsi.ke,
    base: base,
    logins: await loginGithub(repo, komits, slug),
    dikenal: dikenal,
    ringkasan: bacaRingkasan(opsi.ringkasan),
  );
  if (opsi.tulis.isNotEmpty) {
    File(opsi.tulis).writeAsStringSync(badan);
    stdout.writeln(
      'wrote ${opsi.tulis} (${komits.length} entries, ${badan.length} bytes)',
    );
  } else {
    stdout.write(badan);
  }
  return 0;
}

Future<void> main(List<String> argumen) async {
  exitCode = await jalankan(argumen);
}
