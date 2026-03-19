import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onFinish});

  final Future<void> Function() onFinish;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      icon: Icons.style_outlined,
      title: 'Study JLPT Kanji Simply',
      description: 'KanjiMoo helps you review N5, N4, and N3 kanji with a clean flashcard experience.',
    ),
    _OnboardingItem(
      icon: Icons.swipe_vertical_outlined,
      title: 'Swipe Through Cards',
      description: 'Swipe up or down to move through each kanji card and stay focused on one item at a time.',
    ),
    _OnboardingItem(
      icon: Icons.touch_app_outlined,
      title: 'Double Tap to Reveal',
      description: 'Double tap a card to quickly show the reading and meaning while studying.',
    ),
    _OnboardingItem(
      icon: Icons.tune_outlined,
      title: 'Adjust Your Study View',
      description: 'Use settings to control readings, meanings, and learning tips based on your study style.',
    ),
  ];

  int _currentIndex = 0;
  bool _isFinishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentIndex == _items.length - 1;

  Future<void> _handleNext() async {
    if (_isFinishing) return;

    if (_isLastPage) {
      setState(() {
        _isFinishing = true;
      });
      await widget.onFinish();
      if (!mounted) return;
      setState(() {
        _isFinishing = false;
      });
      return;
    }

    await _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _handleSkip() async {
    if (_isFinishing) return;
    setState(() {
      _isFinishing = true;
    });
    await widget.onFinish();
    if (!mounted) return;
    setState(() {
      _isFinishing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _isFinishing ? null : _handleSkip, child: const Text('Skip')),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(item.icon, size: 44),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_items.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isFinishing ? null : _handleNext,
                child: Text(_isLastPage ? 'Start Learning' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;
}
