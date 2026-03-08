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
  static const _kLastIndexByLevel = 'last_index_by_level';

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

    // Restore last index for this level
    final map = _readIndexMap(box);
    final restoredIndex = map[level.label] ?? 0;

    state = state.copyWith(level: level, initialIndex: restoredIndex, status: DeckStatus.loading, cards: const []);

    await _load(level);
  }

  Future<void> setLastSeenIndex(int index) async {
    if (state.initialIndex == index) return;

    state = state.copyWith(initialIndex: index);

    final box = await _box();
    final map = _readIndexMap(box);
    map[state.level.label] = index;
    await box.put(_kLastIndexByLevel, map);
  }

  Future<void> _restoreAndLoad() async {
    final box = await _box();

    // Restore selected level
    final saved = box.get(_kSelectedLevel);
    final restoredLevel = saved is String ? JlptLevelX.fromLabel(saved) : JlptLevel.n5;

    // Restore last index map and pick index for selected level
    final map = _readIndexMap(box);
    final restoredIndex = map[restoredLevel.label] ?? 0;

    state = state.copyWith(
      level: restoredLevel,
      initialIndex: restoredIndex,
      status: DeckStatus.loading,
      cards: const [],
    );

    await _load(restoredLevel);
  }

  Map<String, int> _readIndexMap(Box<dynamic> box) {
    final raw = box.get(_kLastIndexByLevel);
    final map = <String, int>{};

    if (raw is Map) {
      for (final entry in raw.entries) {
        final k = entry.key;
        final v = entry.value;
        if (k is String && v is int) {
          map[k] = v;
        }
      }
    }
    return map;
  }

  Future<void> _load(JlptLevel level) async {
    try {
      final repo = ref.read(kanjiDeckRepositoryProvider);
      final cards = await repo.fetchDeck(level);
      state = state.copyWith(status: DeckStatus.ready, cards: cards);
    } catch (e) {
      state = state.copyWith(status: DeckStatus.error, errorMessage: e.toString(), cards: const []);
    }
  }
}
