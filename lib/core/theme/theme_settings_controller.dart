import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeSettingsState {
  const ThemeSettingsState({required this.mode, required this.loaded});

  final ThemeMode mode;
  final bool loaded;

  ThemeSettingsState copyWith({ThemeMode? mode, bool? loaded}) {
    return ThemeSettingsState(mode: mode ?? this.mode, loaded: loaded ?? this.loaded);
  }
}

final themeSettingsProvider = NotifierProvider<ThemeSettingsController, ThemeSettingsState>(
  ThemeSettingsController.new,
);

class ThemeSettingsController extends Notifier<ThemeSettingsState> {
  static const _boxName = 'app_settings';
  static const _keyDarkMode = 'dark_mode';

  Future<Box<dynamic>>? _boxFuture;
  Future<Box<dynamic>> _box() => _boxFuture ??= Hive.openBox<dynamic>(_boxName);

  @override
  ThemeSettingsState build() {
    // Default to light until we load from disk.
    state = const ThemeSettingsState(mode: ThemeMode.light, loaded: false);
    unawaited(_load());
    return state;
  }

  Future<void> _load() async {
    final box = await _box();
    final raw = box.get(_keyDarkMode);
    final isDark = raw is bool ? raw : false;

    state = state.copyWith(mode: isDark ? ThemeMode.dark : ThemeMode.light, loaded: true);
  }

  Future<void> setDarkMode(bool enabled) async {
    final box = await _box();
    await box.put(_keyDarkMode, enabled);

    state = state.copyWith(mode: enabled ? ThemeMode.dark : ThemeMode.light, loaded: true);
  }
}
