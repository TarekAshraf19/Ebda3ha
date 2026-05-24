import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/themes/theme_controller.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../support/presentation/pages/support_chat_page.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color drawerBackgroundColor =
    isDark ? AppColors.darkScaffold : AppColors.kPrimaryPink;

    final Color selectedTileColor = AppColors.whiteColor;

    final Color selectedTextColor =
    isDark ? AppColors.blackColor : AppColors.blackColor;

    final Color unselectedTextColor = AppColors.whiteColor;

    const Color toggleOuterColor = Colors.transparent;

    final Color lightActiveToggleColor = AppColors.whiteColor;
    final Color darkActiveToggleColor =
    isDark ? const Color(0xFF1A1A1A) : AppColors.whiteColor;

    final Color inactiveTextColor =
    isDark ? Colors.white70 : AppColors.whiteColor;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
        child: Container(
          color: drawerBackgroundColor,
          child: SafeArea(
            child: user == null
                ? Center(
              child: Text(
                context.tr.tr('not_logged_in'),
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snap) {
                final data = snap.data?.data() ?? {};
                final fullName =
                (data['fullName'] ?? user.displayName ?? context.tr.tr('user'))
                    .toString();
                final email =
                (data['email'] ?? user.email ?? '').toString();
                final photoUrl = (data['photoUrl'] ?? '').toString();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white24,
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty
                                ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 34,
                            )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    _drawerItem(
                      icon: Icons.home_outlined,
                      title: context.tr.tr('homepage'),
                      selected: selectedIndex == 0,
                      selectedTileColor: selectedTileColor,
                      selectedTextColor: selectedTextColor,
                      unselectedTextColor: unselectedTextColor,
                      onTap: () => _select(context, 0),
                    ),
                    _drawerItem(
                      icon: Icons.search,
                      title: context.tr.tr('discover'),
                      selected: selectedIndex == 1,
                      selectedTileColor: selectedTileColor,
                      selectedTextColor: selectedTextColor,
                      unselectedTextColor: unselectedTextColor,
                      onTap: () => _select(context, 1),
                    ),
                    _drawerItem(
                      icon: Icons.shopping_bag_outlined,
                      title: context.tr.tr('my_order'),
                      selected: selectedIndex == 2,
                      selectedTileColor: selectedTileColor,
                      selectedTextColor: selectedTextColor,
                      unselectedTextColor: unselectedTextColor,
                      onTap: () => _select(context, 2),
                    ),
                    _drawerItem(
                      icon: Icons.favorite_border,
                      title: context.tr.tr('wishlist'),
                      selected: selectedIndex == 3,
                      selectedTileColor: selectedTileColor,
                      selectedTextColor: selectedTextColor,
                      unselectedTextColor: unselectedTextColor,
                      onTap: () => _select(context, 3),
                    ),
                    _drawerItem(
                      icon: Icons.person_outline,
                      title: context.tr.tr('my_profile'),
                      selected: selectedIndex == 4,
                      selectedTileColor: selectedTileColor,
                      selectedTextColor: selectedTextColor,
                      unselectedTextColor: unselectedTextColor,
                      onTap: () => _select(context, 4),
                    ),
                    _drawerItem(
                      icon: Icons.near_me_outlined,
                      title: context.tr.tr('chat_support'),
                      selected: false,
                      selectedTileColor: selectedTileColor,
                      selectedTextColor: selectedTextColor,
                      unselectedTextColor: unselectedTextColor,
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupportChatPage(),
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                      child: Container(
                        height: 62,
                        decoration: BoxDecoration(
                          color: toggleOuterColor,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await ThemeController.setTheme(
                                    ThemeMode.light,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: ThemeController.currentMode ==
                                        ThemeMode.light
                                        ? lightActiveToggleColor
                                        : Colors.transparent,
                                    borderRadius:
                                    BorderRadius.circular(28),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wb_sunny_outlined,
                                        color: ThemeController.currentMode ==
                                            ThemeMode.light
                                            ? AppColors.kPrimaryPink
                                            : inactiveTextColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        context.tr.tr('light'),
                                        style: TextStyle(
                                          color: ThemeController.currentMode ==
                                              ThemeMode.light
                                              ? AppColors.kPrimaryPink
                                              : inactiveTextColor,
                                          fontSize: 16,
                                          fontWeight: ThemeController.currentMode ==
                                              ThemeMode.light
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await ThemeController.setTheme(
                                    ThemeMode.dark,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: ThemeController.currentMode ==
                                        ThemeMode.dark
                                        ? darkActiveToggleColor
                                        : Colors.transparent,
                                    borderRadius:
                                    BorderRadius.circular(28),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.dark_mode_outlined,
                                        color: ThemeController.currentMode ==
                                            ThemeMode.dark
                                            ? AppColors.kPrimaryPink
                                            : inactiveTextColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        context.tr.tr('dark'),
                                        style: TextStyle(
                                          color: ThemeController.currentMode ==
                                              ThemeMode.dark
                                              ? AppColors.kPrimaryPink
                                              : inactiveTextColor,
                                          fontSize: 16,
                                          fontWeight: ThemeController.currentMode ==
                                              ThemeMode.dark
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, int index) {
    Navigator.pop(context);
    onSelectIndex(index);
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required bool selected,
    required Color selectedTileColor,
    required Color selectedTextColor,
    required Color unselectedTextColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: selected ? selectedTileColor : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? selectedTextColor : unselectedTextColor,
                  size: 30,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? selectedTextColor : unselectedTextColor,
                      fontSize: 17,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}