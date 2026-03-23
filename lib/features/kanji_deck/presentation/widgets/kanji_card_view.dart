import 'package:flutter/material.dart';

import '../../data/models/kanji_card.dart';

class KanjiCardView extends StatefulWidget {
  const KanjiCardView({
    super.key,
    required this.card,
    required this.showReadings,
    required this.showMeanings,
    required this.isLastCard,
    required this.onShuffleAgain,
  });

  final KanjiCard card;
  final bool showReadings;
  final bool showMeanings;
  final bool isLastCard;
  final VoidCallback onShuffleAgain;

  @override
  State<KanjiCardView> createState() => _KanjiCardViewState();
}

class _KanjiCardViewState extends State<KanjiCardView> {
  bool _isRevealed = false;

  @override
  void didUpdateWidget(covariant KanjiCardView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset reveal state when the card changes.
    if (oldWidget.card.kanji != widget.card.kanji) {
      _isRevealed = false;
    }
  }

  void _handleDoubleTap() {
    if (widget.showReadings && widget.showMeanings) return;

    final effectiveShowReadings = widget.showReadings || _isRevealed;
    final effectiveShowMeanings = widget.showMeanings || _isRevealed;

    if (!effectiveShowReadings || !effectiveShowMeanings) {
      setState(() => _isRevealed = true);
      return;
    }

    setState(() => _isRevealed = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final effectiveShowReadings = widget.showReadings || _isRevealed;
    final effectiveShowMeanings = widget.showMeanings || _isRevealed;
    final showDetails = effectiveShowReadings || effectiveShowMeanings || widget.isLastCard;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: _handleDoubleTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Account for the vertical padding used below so our zones always fit.
          const verticalPadding = 24.0 * 2;
          final availableH = (constraints.maxHeight - verticalPadding).clamp(0.0, double.infinity);

          // Allocate two zones that always fit within `availableH`.
          const minDetailsH = 140.0;

          var kanjiZoneHeight = (availableH * 0.58).clamp(220.0, 420.0);
          if (availableH - kanjiZoneHeight < minDetailsH) {
            kanjiZoneHeight = (availableH - minDetailsH).clamp(160.0, kanjiZoneHeight);
          }
          final detailsZoneHeight = (availableH - kanjiZoneHeight).clamp(0.0, availableH);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SizedBox(
              height: availableH,
              child: Column(
                children: [
                  SizedBox(
                    height: kanjiZoneHeight,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(widget.card.kanji, style: textTheme.displayLarge?.copyWith(fontSize: 120)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: detailsZoneHeight,
                    child: AnimatedOpacity(
                      opacity: showDetails ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: IgnorePointer(
                        ignoring: !showDetails,
                        child: Column(
                          children: [
                            Expanded(
                              child: Scrollbar(
                                thumbVisibility: false,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 520),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (effectiveShowReadings) ...[
                                            _Readings(card: widget.card),
                                            if (effectiveShowMeanings) const SizedBox(height: 20),
                                          ],
                                          if (effectiveShowMeanings)
                                            Text(
                                              widget.card.meanings.join(', '),
                                              textAlign: TextAlign.center,
                                              style: textTheme.titleMedium,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (widget.isLastCard) ...[
                              const SizedBox(height: 16),
                              FilledButton.tonal(onPressed: widget.onShuffleAgain, child: const Text('Shuffle Again')),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Readings extends StatelessWidget {
  const _Readings({required this.card});

  final KanjiCard card;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    String line(String label, String value) => '$label: ${value.isEmpty ? '—' : value}';

    return Column(
      key: const ValueKey('readings'),
      children: [
        Text(line('On', card.onyomiDisplay), style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(line('Kun', card.kunyomiDisplay), style: textTheme.titleMedium),
      ],
    );
  }
}
