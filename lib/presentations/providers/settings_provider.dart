import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box('settings');
});

class SettingsState {
  final ThemeMode themeMode;
  final String defaultCity;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.defaultCity = 'London',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? defaultCity,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      defaultCity: defaultCity ?? this.defaultCity,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Box settingsBox;

  SettingsNotifier(this.settingsBox) : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final themeIndex = settingsBox.get('theme_mode', defaultValue: 0);
    final defaultCity = settingsBox.get('default_city', defaultValue: 'London');
    
    state = state.copyWith(
      themeMode: ThemeMode.values[themeIndex],
      defaultCity: defaultCity,
    );
  }

  void setThemeMode(ThemeMode mode) {
    settingsBox.put('theme_mode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setDefaultCity(String city) {
    settingsBox.put('default_city', city);
    state = state.copyWith(defaultCity: city);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return SettingsNotifier(box);
});

// Individual providers for easier access
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

final defaultCityProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).defaultCity;
});