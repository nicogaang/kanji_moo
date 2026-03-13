import 'package:flutter/material.dart';

import '../home/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoOpacityIn;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacityOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));

    // Logo: fade in, scale up, then fade out near the end.
    _logoOpacityIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.35, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 1.02, end: 1.22).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 1.00, curve: Curves.easeInOutCubic),
      ),
    );

    _logoOpacityOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.00, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const MainScreen()));
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Combine fade-in + fade-out without needing an extra controller.
    final logoOpacity = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final inValue = _logoOpacityIn.value;
        final outValue = _logoOpacityOut.value;
        return Opacity(opacity: (inValue * outValue).clamp(0.0, 1.0), child: const _SplashLogo());
      },
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            // Center logo + text.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(scale: _logoScale, child: logoOpacity),
                  const SizedBox(height: 12),
                  const Text(
                    'Kanji Practice',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  const Text('N5 • N4 • N3', style: TextStyle(fontSize: 14, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/kanjimoo2.png', width: 280, fit: BoxFit.contain);
  }
}
