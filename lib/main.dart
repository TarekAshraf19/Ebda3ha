import 'package:ebad3a_ecommerce/features/ui/pages/bottom_nav_bar/root_screen.dart';
import 'package:ebad3a_ecommerce/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/ui/pages/settings_screen/settings_screen.dart';
import 'firebase_options.dart';
import 'core/utils/app_ebda3a.dart';
import 'core/themes/app_theme.dart';
import 'core/themes/theme_controller.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/app_localizations.dart';
import 'features/ui/auth/login/login_screen.dart';
import 'features/ui/auth/register/register_screen.dart';
import 'features/ui/auth/splash_screen/splash_screen.dart';
import 'features/ui/pages/cart_screen/cart_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ThemeController.init();
  await LocaleController.init();
  await LocalNotificationService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, currentMode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: LocaleController.localeNotifier,
          builder: (context, currentLocale, _) {
            return ScreenUtilInit(
              designSize: const Size(430, 932),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  initialRoute: '/',
                  locale: currentLocale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                  AppLocalizations.localizationsDelegates,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: currentMode,
                  routes: {
                    '/': (context) => const SplashScreen(),
                    AppEbda3ha.loginEbda3ha: (context) =>
                    const LoginScreen(),
                    AppEbda3ha.registerEbda3ha: (context) =>
                    const RegisterScreen(),
                    AppEbda3ha.homeEbda3ha: (context) =>
                    const RootScreen(),
                    AppEbda3ha.cartEbda3ha: (context) =>
                    const CartScreen(),
                    AppEbda3ha.settingsEbda3ha: (context) =>
                    const SettingsScreen(),
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}