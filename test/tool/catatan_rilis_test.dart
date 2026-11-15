import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/rilis/catatan_rilis.dart';

const _base = 'https://github.com/o/r';

late Directory _repo;
late Git _git;

/// Runs git in the fixture repository under one identity.
void _jalankanGit(List<String> argumen, {String who = 'Ana'}) {
  final hasil = Process.runSync(
    'git',
    [
      '-c',
      'user.name=$who',
      '-c',
      'user.email=${who.toLowerCase()}@example.com',
      ...argumen,
    ],
    workingDirectory: _repo.path,
    environment: {
      'HOME': _repo.path,
      'GIT_CONFIG_SYSTEM': '/dev/null',
      'GIT_TERMINAL_PROMPT': '0',
    },
  );
  if (hasil.exitCode != 0) {
    throw StateError('git ${argumen.join(' ')}: ${hasil.stderr}');
  }
}

void _komit(String subjek, {String who = 'Ana'}) =>
    _jalankanGit(['commit', '-q', '--allow-empty', '-m', subjek], who: who);

void main() {
  setUpAll(() {
    // Commits carry no dates or clock, so the fixture is deterministic; only the
    // graph and the identities matter.
    _repo = Directory.systemTemp.createTempSync('moci-catatan');
    _git = Git(_repo.path);
    _jalankanGit(['init', '-q', '-b', 'main']);
    _komit('feat: first');
    _jalankanGit(['tag', 'v1.0.0']);
    _komit('fix(api): keep the token out of the log');
    _jalankanGit(['checkout', '-q', '-b', 'feat/rpc']);
    _komit('feat(agent): talk over rpc', who: 'Budi');
    _komit('fix the rpc test', who: 'Budi');
    _jalankanGit(['checkout', '-q', 'main']);
    _jalankanGit([
      'merge',
      '-q',
      '--no-ff',
      'feat/rpc',
      '-m',
      'Merge pull request #9: talk over rpc',
      '-m',
      'feat(agent): talk over rpc instead of acp',
    ]);
    _komit('chore(release): v1.1.0');
    _komit('Revert "chore(release): v1.1.0"');
    _jalankanGit(['tag', 'v1.1.0']);
  });

  tearDownAll(() => _repo.deleteSync(recursive: true));

  test('a merged pull request is one entry linked to it and its author', () {
    final body = susun(
      komits: catatan(_git, 'v1.0.0', 'v1.1.0'),
      dari: 'v1.0.0',
      ke: 'v1.1.0',
      base: _base,
      logins: {'budi@example.com': 'budi-gh'},
    );
    expect(
      body,
      contains(
        '- **agent**: talk over rpc instead of acp '
        '([#9]($_base/pull/9) @budi-gh)',
      ),
    );
    // The pull request's own commits are folded into its entry, not listed again.
    expect(body, isNot(contains('fix the rpc test')));
    final api = body
        .split('\n')
        .firstWhere((baris) => baris.contains('keep the token'));
    // A commit on main credits its author too; one GitHub cannot match keeps the
    // git name, without the @ that would link the wrong person.
    expect(api.endsWith(' Ana)'), isTrue);
    expect(api, isNot(contains('@Ana')));
  });

  test('a version bump and its revert stay out of the notes', () {
    final subjek = catatan(_git, 'v1.0.0', 'v1.1.0').map((k) => k.subject);
    expect(subjek.where((s) => s.contains('chore(release)')), isEmpty);
  });

  test('a chore(rilis) bump is excluded too', () {
    expect(
      catatan(_git, '', 'v1.0.0').map((k) => k.subject),
      isNot(contains('chore(rilis): v1.0.0')),
    );
  });

  test('everyone who wrote the release is credited, a newcomer called out', () {
    final body = susun(
      komits: catatan(_git, 'v1.0.0', 'v1.1.0'),
      dari: 'v1.0.0',
      ke: 'v1.1.0',
      base: _base,
      logins: {'budi@example.com': 'budi-gh'},
      dikenal: emailDikenal(_git, 'v1.0.0'),
    );
    final kontributor = body.split('### Contributors')[1].split('###')[0];
    expect(kontributor, contains('@budi-gh'));
    expect(kontributor, contains('Ana'));
    final pendatang = body.split('### New contributors')[1];
    expect(
      pendatang,
      contains('@budi-gh made their first contribution in [#9]'),
    );
    expect(pendatang, isNot(contains('Ana')));
  });

  test('a bot is never credited', () {
    final komit = uraiKomit(
      'abc1234',
      'fix: y',
      penulis: [
        Penulis('github-actions[bot]', '41898282+github-actions[bot]@x'),
      ],
    );
    expect(
      susun(komits: [komit], dari: 'v1', ke: 'v2', base: _base),
      isNot(contains('Contributors')),
    );
  });

  test('the first release names no newcomers', () {
    final body = susun(
      komits: catatan(_git, '', 'v1.0.0'),
      dari: '',
      ke: 'v1.0.0',
      base: _base,
    );
    expect(body, contains('### Contributors'));
    expect(body, isNot(contains('New contributors')));
    expect(body, contains('$_base/commits/v1.0.0'));
  });

  test('a conventional subject is split into type, scope, and text', () {
    final komit = uraiKomit('abc1234', 'feat(menu): add the huruf game');
    expect(
      [komit.jenis, komit.scope, komit.teks],
      ['feat', 'menu', 'add the huruf game'],
    );
  });

  test('a plain subject lands in other changes', () {
    final komit = uraiKomit('abc1234', 'fix the thing by hand');
    expect(komit.jenis, 'other');
    expect(komit.teks, 'fix the thing by hand');
  });

  test('a bang marks breaking', () {
    expect(
      uraiKomit('abc1234', 'refactor(config)!: drop the old key').jenis,
      'breaking',
    );
  });

  test('issue references are collected', () {
    final komit = uraiKomit('abc1234', 'fix(menu): lock the tile (#12, #34)');
    expect(komit.rujukan, [12, 34]);
  });

  test('the body is grouped and links commits', () {
    final body = susun(
      komits: [
        uraiKomit('aaaaaaa', 'feat(api): expose the status endpoint'),
        uraiKomit('bbbbbbb', 'fix(logs): stop printing the token'),
        uraiKomit('ccccccc', 'docs: rewrite the README'),
        uraiKomit('ddddddd', 'ci(release): build once'),
      ],
      dari: 'v1.2.2',
      ke: 'v1.2.3',
      base: _base,
    );
    final judul = body
        .split('\n')
        .where((baris) => baris.startsWith('### '))
        .toList();
    expect(judul, [
      '### Install',
      '### Features',
      '### Fixes',
      '### Documentation',
      '### Build and CI',
    ]);
    expect(body, contains('**api**: expose the status endpoint'));
    expect(body, contains('$_base/commit/aaaaaaa'));
    expect(body.trimRight(), endsWith('compare/v1.2.2...v1.2.3'));
  });

  test('test, refactor, chore and unknown types share one Other changes', () {
    final body = susun(
      komits: [
        uraiKomit('a1', 'test: cover the tracing glyphs'),
        uraiKomit('b2', 'refactor(home): split the card'),
        uraiKomit('c3', 'chore: refresh the locks'),
        uraiKomit('d4', 'wip(menu): something odd'),
      ],
      dari: '',
      ke: 'v1.0.0',
      base: _base,
    );
    expect(RegExp('### Other changes').allMatches(body).length, 1);
    expect(body, contains('- **home**: split the card'));
    expect(body, contains('- something odd'));
    expect(
      body.indexOf('### Other changes'),
      greaterThan(body.indexOf('### Install')),
    );
  });

  test('a scope is bold and a plain subject is not', () {
    final scoped = susun(
      komits: [uraiKomit('abc1234', 'fix(x): y')],
      dari: '',
      ke: 'v1',
      base: 'u',
    );
    final plain = susun(
      komits: [uraiKomit('abc1234', 'no prefix here')],
      dari: '',
      ke: 'v1',
      base: 'u',
    );
    expect(scoped, contains('- **x**: y'));
    expect(plain, contains('- no prefix here'));
  });

  test('the install section explains the three files', () {
    final body = susun(
      komits: [uraiKomit('a1', 'feat: x')],
      dari: '',
      ke: 'v1',
      base: _base,
    );
    final pemasangan = body.split('### Install')[1].split('###')[0];
    expect(pemasangan, contains('.apk'));
    expect(pemasangan, contains('Sideloadly'));
    expect(pemasangan, contains('7 days'));
    expect(pemasangan, contains('.aab'));
    expect(body.indexOf('### Install'), lessThan(body.indexOf('### Features')));
  });

  test('arguments accept --flag=value', () {
    final opsi = uraiArgumen(['--to=v1.2.0', '--from', 'v1.1.0']);
    expect([opsi.dari, opsi.ke], ['v1.1.0', 'v1.2.0']);
  });

  test('a summary file is prepended to the written notes', () async {
    final out = Directory.systemTemp.createTempSync('moci-ringkasan');
    addTearDown(() => out.deleteSync(recursive: true));
    final ringkasan = File('${out.path}/SUMMARY.md')
      ..writeAsStringSync('## The short version\n\n- personas per bot\n');
    final berkas = '${out.path}/RELEASE_NOTES.md';
    final kode = await jalankan([
      '--from',
      'v1.0.0',
      '--to',
      'v1.1.0',
      '--summary',
      ringkasan.path,
      '--write',
      berkas,
    ], git: _git);
    expect(kode, 0);
    final body = File(berkas).readAsStringSync();
    expect(body.startsWith('## The short version'), isTrue);
    expect(
      body.indexOf('personas per bot'),
      lessThan(body.indexOf('### Install')),
    );
    expect(body.indexOf('### Install'), lessThan(body.indexOf('### Features')));
  });

  test('a missing summary file changes nothing', () async {
    final out = Directory.systemTemp.createTempSync('moci-ringkasan');
    addTearDown(() => out.deleteSync(recursive: true));
    final berkas = '${out.path}/RELEASE_NOTES.md';
    final kode = await jalankan([
      '--from',
      'v1.0.0',
      '--to',
      'v1.1.0',
      '--summary',
      '${out.path}/absent.md',
      '--write',
      berkas,
    ], git: _git);
    expect(kode, 0);
    expect(
      File(berkas).readAsStringSync(),
      isNot(contains('The short version')),
    );
  });

  test('an empty range refuses to publish', () async {
    expect(
      await jalankan(['--from', 'v1.1.0', '--to', 'v1.1.0'], git: _git),
      1,
    );
  });

  test('an unknown argument is a usage error', () async {
    expect(await jalankan(['--nope'], git: _git), 64);
  });
}
