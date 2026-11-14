import '../lang.dart';

/// Teks yang sama dalam dua bahasa.
final class Bilingual {
  const Bilingual(this.id, this.en);

  factory Bilingual.fromJson(Object? value) {
    if (value is! Map) {
      return const Bilingual('', '');
    }
    return Bilingual(_str(value['id']), _str(value['en']));
  }

  final String id;
  final String en;

  String of(AppLang lang) => lang == AppLang.en ? en : id;

  Map<String, Object?> toJson() => {'id': id, 'en': en};
}

String _str(Object? value) => value is String ? value : '';
