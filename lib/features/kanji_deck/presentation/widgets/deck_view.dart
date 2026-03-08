import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_moo/features/kanji_deck/data/models/jlpt_level.dart';

import '../../application/kanji_deck_controller.dart';
import '../../application/kanji_deck_state.dart';
import '../widgets/kanji_card_view.dart';

class DeckView extends ConsumerWidget {
  const DeckView({super.key, required this.state, required this.pageController});

  final KanjiDeckState state;
  final PageController pageController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.cards.isEmpty) {
      return const Center(child: Text('No cards found.'));
    }

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: state.cards.length,
      itemBuilder: (context, index) {
        final card = state.cards[index];

        final child = KanjiCardView(
          key: ValueKey('${state.level.label}:${card.kanji}'),
          card: card,
          showReadings: state.showReadings,
          showMeanings: state.showMeanings,
        );

        return AnimatedBuilder(
          animation: pageController,
          child: child,
          builder: (context, child) {
            final double page;
            if (pageController.hasClients) {
              page = pageController.page ?? pageController.initialPage.toDouble();
            } else {
              page = pageController.initialPage.toDouble();
            }

            final distance = (page - index).abs();
            const fadeEnd = 0.50;
            final t = (distance / fadeEnd).clamp(0.0, 1.0);
            final opacity = 1.0 - Curves.easeInOut.transform(t);

            return Opacity(opacity: opacity, child: child);
          },
        );
      },
      onPageChanged: (index) {
        if (state.initialIndex != index) {
          ref.read(kanjiDeckControllerProvider.notifier).setLastSeenIndex(index);
        }
      },
    );
  }
}
