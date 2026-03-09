import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/models/jlpt_level.dart';
import '../data/repositories/kanji_deck_repository.dart';
import '../data/sources/kanji_asset_source.dart';
import 'kanji_deck_state.dart';

final kanjiDeckRepositoryProvider = Provider<KanjiDeckRepository>((ref) {
  return KanjiDeckRepository(const KanjiAssetSource());
});

final kanjiDeckControllerProvider = NotifierProvider<KanjiDeckController, KanjiDeckState>(KanjiDeckController.new);

class KanjiDeckController extends Notifier<KanjiDeckState> {
  static const _boxName = 'kanji_deck';
  static const _kSelectedLevel = 'selected_level';

  Future<Box<dynamic>>? _boxFuture;

  Future<Box<dynamic>> _box() => _boxFuture ??= Hive.openBox<dynamic>(_boxName);

  @override
  KanjiDeckState build() {
    state = KanjiDeckState.initial();
    unawaited(_restoreAndLoad());
    return state;
  }

  void setShowReadings(bool value) {
    state = state.copyWith(showReadings: value);
  }

  void setShowMeanings(bool value) {
    state = state.copyWith(showMeanings: value);
  }

  Future<void> setLevel(JlptLevel level) async {
    if (state.level == level) return;

    final box = await _box();

    // Persist selected level
    await box.put(_kSelectedLevel, level.label);

    state = state.copyWith(level: level, initialIndex: 0, status: DeckStatus.loading, cards: const []);

    await _load(level);
  }

  void setLastSeenIndex(int index) {
    if (state.initialIndex == index) return;

    state = state.copyWith(initialIndex: index);
  }

  void reshuffleCurrentDeck() {
    if (state.cards.isEmpty) return;

    final reshuffled = [...state.cards]..shuffle();

    state = state.copyWith(cards: reshuffled, initialIndex: 0);
  }

  Future<void> _restoreAndLoad() async {
    final box = await _box();

    // Restore selected level
    final saved = box.get(_kSelectedLevel);
    final restoredLevel = saved is String ? JlptLevelX.fromLabel(saved) : JlptLevel.n5;

    state = state.copyWith(level: restoredLevel, initialIndex: 0, status: DeckStatus.loading, cards: const []);

    await _load(restoredLevel);
  }

  Future<void> _load(JlptLevel level) async {
    try {
      final repo = ref.read(kanjiDeckRepositoryProvider);
      final cards = await repo.fetchDeck(level);
      final shuffledCards = [...cards]..shuffle();

      state = state.copyWith(status: DeckStatus.ready, cards: shuffledCards, initialIndex: 0);
    } catch (e) {
      state = state.copyWith(status: DeckStatus.error, errorMessage: e.toString(), cards: const []);
    }
  }
}
