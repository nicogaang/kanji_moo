import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_moo/features/kanji_deck/data/models/jlpt_level.dart';

import '../../application/kanji_deck_controller.dart';
import '../../application/kanji_deck_state.dart';
import '../dialogs/kanji_settings_dialog.dart';
import '../widgets/deck_view.dart';
import '../widgets/error_view.dart';

const _levels = [JlptLevel.n5, JlptLevel.n4, JlptLevel.n3];

class KanjiDeckPage extends ConsumerStatefulWidget {
  const KanjiDeckPage({super.key});

  @override
  ConsumerState<KanjiDeckPage> createState() => _KanjiDeckPageState();
}

class _KanjiDeckPageState extends ConsumerState<KanjiDeckPage> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kanjiDeckControllerProvider);
    ref.listen(kanjiDeckControllerProvider, (prev, next) {
      if (next.status != DeckStatus.ready) return;
      if (!_pageController.hasClients) return;

      final current = (_pageController.page ?? _pageController.initialPage).round();
      final target = next.initialIndex;
      if (current == target) return;

      _pageController.jumpToPage(target);
    });
    final selected = _levels.indexOf(state.level);
    return Scaffold(
      appBar: AppBar(
        title: Text(state.level.label),
        actions: [IconButton(icon: const Icon(Icons.tune), onPressed: () => openKanjiSettingsDialog(context))],
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: switch (state.status) {
          DeckStatus.loading => const Center(child: CircularProgressIndicator()),
          DeckStatus.error => ErrorView(message: state.errorMessage ?? 'Load error'),
          DeckStatus.ready => DeckView(state: state, pageController: _pageController),
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book), selectedIcon: Icon(Icons.menu_book_outlined), label: 'N5'),
          NavigationDestination(icon: Icon(Icons.book), selectedIcon: Icon(Icons.menu_book_outlined), label: 'N4'),
          NavigationDestination(icon: Icon(Icons.book), selectedIcon: Icon(Icons.menu_book_outlined), label: 'N3'),
        ],
        onDestinationSelected: (index) async {
          final level = _levels[index];
          await ref.read(kanjiDeckControllerProvider.notifier).setLevel(level);
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        },
      ),
    );
  }
}
