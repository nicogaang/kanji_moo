enum JlptLevel { n5, n4, n3, n2, n1 }

extension JlptLevelX on JlptLevel {
  String get label => switch (this) {
    JlptLevel.n5 => 'N5',
    JlptLevel.n4 => 'N4',
    JlptLevel.n3 => 'N3',
    JlptLevel.n2 => 'N2',
    JlptLevel.n1 => 'N1',
  };

  String get assetPath => switch (this) {
    JlptLevel.n5 => 'assets/kanji/n5_flashcards.json',
    JlptLevel.n4 => 'assets/kanji/n4_flashcards.json',
    JlptLevel.n3 => 'assets/kanji/n3_flashcards.json',
    JlptLevel.n2 => 'assets/kanji/n2_flashcards.json',
    JlptLevel.n1 => 'assets/kanji/n1_flashcards.json',
  };

  static JlptLevel fromLabel(String value) => switch (value.toUpperCase()) {
    'N5' => JlptLevel.n5,
    'N4' => JlptLevel.n4,
    'N3' => JlptLevel.n3,
    'N2' => JlptLevel.n2,
    'N1' => JlptLevel.n1,
    _ => throw FormatException('Unknown JLPT level: $value'),
  };
}
