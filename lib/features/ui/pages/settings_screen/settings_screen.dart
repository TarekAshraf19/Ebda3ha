import 'package:ebad3a_ecommerce/core/localization/app_localizations.dart';
import 'package:ebad3a_ecommerce/core/localization/locale_controller.dart';
import 'package:ebad3a_ecommerce/core/themes/theme_controller.dart';
import 'package:ebad3a_ecommerce/core/utils/app_colors.dart';
import 'package:ebad3a_ecommerce/core/utils/app_ebda3a.dart';
import 'package:ebad3a_ecommerce/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'notification_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showLanguageDialog(BuildContext context) async {
    String selected;

    if (LocaleController.currentLocale == null) {
      selected = 'System';
    } else if (LocaleController.currentLocale?.languageCode == 'ar') {
      selected = 'Arabic';
    } else {
      selected = 'English';
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor:
            isDark ? AppColors.darkCard : AppColors.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              context.tr.tr('choose_language'),
              style: const TextStyle(
                color: AppColors.kPrimaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  activeColor: AppColors.kPrimaryPink,
                  value: 'System',
                  groupValue: selected,
                  title: Text(context.tr.tr('system')),
                  onChanged: (value) {
                    setState(() => selected = value!);
                  },
                ),
                RadioListTile<String>(
                  activeColor: AppColors.kPrimaryPink,
                  value: 'English',
                  groupValue: selected,
                  title: const Text('English'),
                  onChanged: (value) {
                    setState(() => selected = value!);
                  },
                ),
                RadioListTile<String>(
                  activeColor: AppColors.kPrimaryPink,
                  value: 'Arabic',
                  groupValue: selected,
                  title: const Text('العربية'),
                  onChanged: (value) {
                    setState(() => selected = value!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.tr.tr('cancel'),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.blackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (selected == 'System') {
                    await LocaleController.setLocale(null);
                  } else if (selected == 'Arabic') {
                    await LocaleController.setLocale(const Locale('ar'));
                  } else {
                    await LocaleController.setLocale(const Locale('en'));
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  context.tr.tr('save'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    ThemeMode selected = ThemeController.currentMode;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor:
            isDark ? AppColors.darkCard : AppColors.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              context.tr.tr('choose_theme'),
              style: const TextStyle(
                color: AppColors.kPrimaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  activeColor: AppColors.kPrimaryPink,
                  value: ThemeMode.system,
                  groupValue: selected,
                  title: Text(context.tr.tr('system')),
                  onChanged: (value) {
                    setState(() => selected = value!);
                  },
                ),
                RadioListTile<ThemeMode>(
                  activeColor: AppColors.kPrimaryPink,
                  value: ThemeMode.light,
                  groupValue: selected,
                  title: Text(context.tr.tr('light_mode')),
                  onChanged: (value) {
                    setState(() => selected = value!);
                  },
                ),
                RadioListTile<ThemeMode>(
                  activeColor: AppColors.kPrimaryPink,
                  value: ThemeMode.dark,
                  groupValue: selected,
                  title: Text(context.tr.tr('dark_mode')),
                  onChanged: (value) {
                    setState(() => selected = value!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.tr.tr('cancel'),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.blackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await ThemeController.setTheme(selected);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  context.tr.tr('save'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showNotificationsScreen(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }

  Future<void> _showTermsDialog(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
        isDark ? AppColors.darkCard : AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          context.tr.tr('terms_of_use'),
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            context.tr.tr('terms_content'),
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.blackColor,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.tr.tr('close'),
              style: const TextStyle(
                color: AppColors.kPrimaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          context.tr.tr('logout'),
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(context.tr.tr('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.tr.tr('cancel'),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kPrimaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.tr.tr('logout'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppEbda3ha.loginEbda3ha,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.darkScaffold : AppColors.kPrimaryPink,
      appBar: AppBar(
        backgroundColor:
        isDark ? AppColors.darkScaffold : AppColors.kPrimaryPink,
        elevation: 0,
        toolbarHeight: 72,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14, top: 10, bottom: 10),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.kPrimaryPink,
                size: 17,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            context.tr.tr('settings'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
        child: Column(
          children: [
            _settingsItem(
              icon: Icons.language_outlined,
              title: context.tr.tr('language'),
              onTap: () => _showLanguageDialog(context),
            ),
            const SizedBox(height: 14),
            _divider(),

            const SizedBox(height: 14),
            _settingsItem(
              icon: Icons.dark_mode_outlined,
              title: context.tr.tr('theme'),
              onTap: () => _showThemeDialog(context),
            ),
            const SizedBox(height: 14),
            _divider(),

            const SizedBox(height: 14),
            StreamBuilder<int>(
              stream: NotificationService.instance.unreadCountStream(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;

                return _settingsItem(
                  icon: Icons.notifications_none_outlined,
                  title: context.tr.tr('notifications'),
                  onTap: () => _showNotificationsScreen(context),
                  badgeCount: unreadCount,
                );
              },
            ),
            const SizedBox(height: 14),
            _divider(),

            const SizedBox(height: 14),
            _settingsItem(
              icon: Icons.assignment_outlined,
              title: context.tr.tr('terms_of_use'),
              onTap: () => _showTermsDialog(context),
            ),
            const SizedBox(height: 14),
            _divider(),

            const SizedBox(height: 14),
            _settingsItem(
              icon: Icons.logout,
              title: context.tr.tr('logout'),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 14),
            _divider(),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: Colors.white.withOpacity(0.55),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}