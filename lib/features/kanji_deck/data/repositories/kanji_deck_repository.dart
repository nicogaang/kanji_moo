import 'package:kanji_moo/features/kanji_deck/data/models/jlpt_level.dart';
import 'package:kanji_moo/features/kanji_deck/data/models/kanji_card.dart';
import 'package:kanji_moo/features/kanji_deck/data/sources/kanji_asset_source.dart';

class KanjiDeckRepository {
  const KanjiDeckRepository(this._source);

  final KanjiAssetSource _source;

  Future<List<KanjiCard>> fetchDeck(JlptLevel level) => _source.loadDeck(level);
}
