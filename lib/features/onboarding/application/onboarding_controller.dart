import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController();
});

class OnboardingController {
  static const String _boxName = 'app_settings';
  static const String _completedKey = 'onboarding_completed';

  Future<bool> isCompleted() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_completedKey, defaultValue: false) as bool;
  }

  Future<void> markCompleted() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_completedKey, true);
  }
}
