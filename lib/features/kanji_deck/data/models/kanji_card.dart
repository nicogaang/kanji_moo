import 'package:kanji_moo/features/kanji_deck/data/models/jlpt_level.dart';

class KanjiCard {
  KanjiCard({
    required this.kanji,
    required this.onyomi,
    required this.kunyomi,
    required this.meanings,
    required this.jlpt,
  });
  final String kanji;
  final List<String> onyomi;
  final List<String> kunyomi;
  final List<String> meanings;
  final JlptLevel jlpt;

  factory KanjiCard.fromJson(Map<String, dynamic> json) {
    String requireString(String key) {
      final value = json[key];
      if (value is String) return value;
      throw FormatException('Expected a string for key "$key", but got: ${value.runtimeType}');
    }

    List<String> requireStringList(String key) {
      final value = json[key];
      if (value is List) {
        return value.map((e) => e.toString()).toList(growable: false);
      }
      throw FormatException('Expected a list of strings for key "$key", but got: ${value.runtimeType}');
    }

    return KanjiCard(
      kanji: requireString('kanji'),
      onyomi: requireStringList('onyomi'),
      kunyomi: requireStringList('kunyomi'),
      meanings: requireStringList('meanings'),
      jlpt: JlptLevelX.fromLabel(requireString('jlpt')),
    );
  }

  // UI helper methods
  String get onyomiDisplay => onyomi.join('・');
  String get kunyomiDisplay => kunyomi.join('・');
}
