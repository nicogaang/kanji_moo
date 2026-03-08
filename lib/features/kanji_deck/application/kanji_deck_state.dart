import '../data/models/jlpt_level.dart';
import '../data/models/kanji_card.dart';

enum DeckStatus { loading, ready, error }

class KanjiDeckState {
  const KanjiDeckState({
    required this.level,
    required this.status,
    required this.cards,
    required this.initialIndex,
    required this.showReadings,
    this.errorMessage,
    required this.showMeanings,
  });

  final JlptLevel level;
  final DeckStatus status;
  final List<KanjiCard> cards;
  final int initialIndex;
  final bool showReadings;
  final bool showMeanings;
  final String? errorMessage;

  KanjiDeckState copyWith({
    JlptLevel? level,
    DeckStatus? status,
    List<KanjiCard>? cards,
    int? initialIndex,
    bool? showReadings,
    bool? showMeanings,
    String? errorMessage,
  }) {
    return KanjiDeckState(
      level: level ?? this.level,
      status: status ?? this.status,
      cards: cards ?? this.cards,
      initialIndex: initialIndex ?? this.initialIndex,
      showReadings: showReadings ?? this.showReadings,
      showMeanings: showMeanings ?? this.showMeanings,
      errorMessage: errorMessage,
    );
  }

  static KanjiDeckState initial() => const KanjiDeckState(
    level: JlptLevel.n5,
    status: DeckStatus.loading,
    cards: [],
    initialIndex: 0,
    showReadings: false,
    showMeanings: false,
  );
}
