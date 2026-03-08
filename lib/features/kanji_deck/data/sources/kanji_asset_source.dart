import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kanji_moo/features/kanji_deck/data/models/jlpt_level.dart';
import 'package:kanji_moo/features/kanji_deck/data/models/kanji_card.dart';

class KanjiAssetSource {
  const KanjiAssetSource();

  Future<List<KanjiCard>> loadDeck(JlptLevel level) async {
    final raw = await rootBundle.loadString(level.assetPath);
    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      throw const FormatException('Deck JSON must be a top-level array.');
    }

    return decoded
        .map((e) {
          if (e is! Map<String, dynamic>) {
            throw const FormatException('Each card must be a JSON object.');
          }
          return KanjiCard.fromJson(e);
        })
        .toList(growable: false);
  }
}
