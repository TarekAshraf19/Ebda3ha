import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static const String _themeKey = 'app_theme_mode';

  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.system); // 👈 خليه system افتراضي

  static ThemeMode get currentMode => themeNotifier.value;

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    switch (savedTheme) {
      case 'dark':
        themeNotifier.value = ThemeMode.dark;
        break;
      case 'light':
        themeNotifier.value = ThemeMode.light;
        break;
      case 'system':
      default:
        themeNotifier.value = ThemeMode.system;
    }
  }

  static Future<void> setTheme(ThemeMode mode) async {
    themeNotifier.value = mode;

    final prefs = await SharedPreferences.getInstance();
    String value = 'system';

    if (mode == ThemeMode.dark) {
      value = 'dark';
    } else if (mode == ThemeMode.light) {
      value = 'light';
    }

    await prefs.setString(_themeKey, value);
  }
}