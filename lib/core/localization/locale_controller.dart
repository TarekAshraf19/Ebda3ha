import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  LocaleController._();

  static const String _localeKey = 'app_locale';

  // 👇 null = system
  static final ValueNotifier<Locale?> localeNotifier =
  ValueNotifier<Locale?>(null);

  static Locale? get currentLocale => localeNotifier.value;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_localeKey);

    if (savedLanguageCode == null || savedLanguageCode == 'system') {
      localeNotifier.value = null; // 👈 system
    } else {
      localeNotifier.value = Locale(savedLanguageCode);
    }
  }

  static Future<void> setLocale(Locale? locale) async {
    localeNotifier.value = locale;

    final prefs = await SharedPreferences.getInstance();

    if (locale == null) {
      await prefs.setString(_localeKey, 'system');
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }

  static bool isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }
}