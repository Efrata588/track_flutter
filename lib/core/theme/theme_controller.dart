import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemeModeKey = 'app_theme_mode';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main');
});

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_kThemeModeKey);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_kThemeModeKey, 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString(_kThemeModeKey, 'dark');
        break;
      case ThemeMode.system:
        await prefs.setString(_kThemeModeKey, 'system');
        break;
    }
  }
}
