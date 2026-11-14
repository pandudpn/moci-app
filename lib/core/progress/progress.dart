/// Format `yyyy-MM-dd` dari tahun/bulan/hari milik [local] sendiri.
String dateKey(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-${two(local.day)}';
}

/// Hitungan dari berkas tidak boleh negatif: nilai aneh dianggap nol.
int _int(Object? v) => v is int && v > 0 ? v : 0;

List<String> _strings(Object? v) => v is List
    ? [
        for (final e in v)
          if (e is String) e,
      ]
    : <String>[];

Map<String, List<String>> _stringLists(Object? v) => v is Map
    ? {
        for (final e in v.entries)
          if (e.key is String && e.value is List)
            e.key as String: _strings(e.value),
      }
    : <String, List<String>>{};

final class LastActivity {
  const LastActivity(this.route, [this.params = const {}]);

  final String route;
  final Map<String, String> params;

  static LastActivity? fromJson(Object? v) {
    if (v is! Map || v['rute'] is! String) return null;
    final param = v['param'];
    return LastActivity(v['rute'] as String, {
      if (param is Map)
        for (final e in param.entries)
          if (e.key is String && e.value is String)
            e.key as String: e.value as String,
    });
  }

  Map<String, Object?> toJson() => {'rute': route, 'param': params};
}

final class DayStats {
  const DayStats({
    this.stars = 0,
    this.stickers = 0,
    this.karya = 0,
    this.items = const {},
  });

  final int stars, stickers, karya;
  final Map<String, List<String>> items;

  factory DayStats.fromJson(Object? v) {
    if (v is! Map) return const DayStats();
    return DayStats(
      stars: _int(v['bintang']),
      stickers: _int(v['stiker']),
      karya: _int(v['karya']),
      items: _stringLists(v['item']),
    );
  }

  DayStats copyWith({
    int? stars,
    int? stickers,
    int? karya,
    Map<String, List<String>>? items,
  }) => DayStats(
    stars: stars ?? this.stars,
    stickers: stickers ?? this.stickers,
    karya: karya ?? this.karya,
    items: items ?? this.items,
  );

  Map<String, Object?> toJson() => {
    'bintang': stars,
    'stiker': stickers,
    'karya': karya,
    'item': items,
  };
}

final class Progress {
  const Progress({
    this.stars = 0,
    this.stickers = const [],
    this.lastActivity,
    this.playSeconds = const {},
    this.perkembangan = const {},
    this.harian = const {},
  });

  static const int versi = 1;

  final int stars;
  final List<String> stickers;
  final LastActivity? lastActivity;
  final Map<String, int> playSeconds;
  final Map<String, Map<String, List<String>>> perkembangan;
  final Map<String, DayStats> harian;

  factory Progress.fromJson(Map<String, Object?> json) {
    final play = json['waktuBermain'];
    final perk = json['perkembangan'];
    final har = json['harian'];
    return Progress(
      stars: _int(json['bintang']),
      stickers: _strings(json['stiker']),
      lastActivity: LastActivity.fromJson(json['kegiatanTerakhir']),
      playSeconds: {
        if (play is Map)
          for (final e in play.entries)
            if (e.key is String && e.value is int)
              e.key as String: e.value as int,
      },
      perkembangan: {
        if (perk is Map)
          for (final e in perk.entries)
            if (e.key is String && e.value is Map)
              e.key as String: _stringLists(e.value),
      },
      harian: {
        if (har is Map)
          for (final e in har.entries)
            if (e.key is String && e.value is Map)
              e.key as String: DayStats.fromJson(e.value),
      },
    );
  }

  Map<String, Object?> toJson() => {
    'versi': versi,
    'bintang': stars,
    'stiker': stickers,
    if (lastActivity != null) 'kegiatanTerakhir': lastActivity!.toJson(),
    'waktuBermain': playSeconds,
    'perkembangan': perkembangan,
    'harian': {for (final e in harian.entries) e.key: e.value.toJson()},
  };

  static const _keep = Object();

  Progress copyWith({
    int? stars,
    List<String>? stickers,
    Object? lastActivity = _keep,
    Map<String, int>? playSeconds,
    Map<String, Map<String, List<String>>>? perkembangan,
    Map<String, DayStats>? harian,
  }) => Progress(
    stars: stars ?? this.stars,
    stickers: stickers ?? this.stickers,
    lastActivity: identical(lastActivity, _keep)
        ? this.lastActivity
        : lastActivity as LastActivity?,
    playSeconds: playSeconds ?? this.playSeconds,
    perkembangan: perkembangan ?? this.perkembangan,
    harian: harian ?? this.harian,
  );
}
