import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../services/fcm_service.dart';
import '../../../../services/notification_service.dart';
import '../settings_screen/notification_screen.dart';
import 'app_drawer.dart';
import '../cart_screen/cart_screen.dart';
import '../discover_page/discover_page.dart';
import '../home_screen/home_screen.dart';
import '../orders_screen/my_orders_screen.dart';
import '../profile_screen/profile_screen.dart';
import '../settings_screen/settings_screen.dart';
import '../wishlist_screen/wishlist_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _index = 0;
  bool _didInitFcm = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didInitFcm) {
      _didInitFcm = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FcmService.instance.init();
        }
      });
    }
  }

  void _changeTab(int newIndex) {
    setState(() {
      _index = newIndex.clamp(0, 4);
    });
  }

  List<Widget> get _pages => [
    HomeScreen(
      embedded: true,
      onOpenDiscoverTab: () => _changeTab(1),
    ),
    const DiscoverPage(embedded: true),
    const MyOrdersScreen(),
    const WishlistScreen(embedded: true),
    const ProfileScreen(embedded: true),
  ];

  bool get _showSettings => _index == 4;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double navHeight = screenWidth < 380 ? 74 : 82;
    final double navIconSize = screenWidth < 380 ? 22 : 24;
    final double selectedCircleSize = screenWidth < 380 ? 44 : 48;
    final double horizontalPadding = screenWidth < 380 ? 8 : 12;

    final Color appBarBackgroundColor =
    isDark ? AppColors.darkScaffold : AppColors.whiteColor;

    final Color scaffoldBackgroundColor =
    isDark ? AppColors.darkScaffold : AppColors.lightScaffold;

    final Color bottomNavBackgroundColor =
    isDark ? const Color(0xFF111111) : AppColors.kPrimaryPink;

    final Color navSelectedBackgroundColor = AppColors.whiteColor;

    final Color navUnselectedBackgroundColor = Colors.transparent;

    final Color navSelectedIconColor = AppColors.kPrimaryPink;

    final Color navUnselectedIconColor =
    isDark ? Colors.white : Colors.white.withOpacity(0.95);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBackgroundColor,
      drawer: AppDrawer(
        selectedIndex: _index,
        onSelectIndex: _changeTab,
      ),
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: AppColors.kPrimaryPink,
            size: 28,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          context.tr.tr('app_name'),
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          StreamBuilder<int>(
            stream: NotificationService.instance.unreadCountStream(),
            builder: (context, snapshot) {
              final int unreadCount = snapshot.data ?? 0;

              return IconButton(
                tooltip: 'الإشعارات',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.kPrimaryPink,
                      size: 28,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          alignment: Alignment.center,
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
                            border: Border.all(
                              color: appBarBackgroundColor,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _showSettings ? Icons.settings : Icons.shopping_cart_outlined,
              color: AppColors.kPrimaryPink,
              size: 27,
            ),
            tooltip:
            _showSettings ? context.tr.tr('settings') : context.tr.tr('cart'),
            onPressed: () {
              if (_showSettings) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: bottomNavBackgroundColor,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Container(
            height: navHeight,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: bottomNavBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  iconData: Icons.home_outlined,
                  index: 0,
                  label: context.tr.tr('homepage'),
                  selectedCircleSize: selectedCircleSize,
                  navIconSize: navIconSize,
                  selectedBackgroundColor: navSelectedBackgroundColor,
                  unselectedBackgroundColor: navUnselectedBackgroundColor,
                  selectedIconColor: navSelectedIconColor,
                  unselectedIconColor: navUnselectedIconColor,
                ),
                _navItem(
                  iconData: Icons.search,
                  index: 1,
                  label: context.tr.tr('discover'),
                  selectedCircleSize: selectedCircleSize,
                  navIconSize: navIconSize,
                  selectedBackgroundColor: navSelectedBackgroundColor,
                  unselectedBackgroundColor: navUnselectedBackgroundColor,
                  selectedIconColor: navSelectedIconColor,
                  unselectedIconColor: navUnselectedIconColor,
                ),
                _navItem(
                  iconData: Icons.shopping_bag_outlined,
                  index: 2,
                  label: context.tr.tr('my_order'),
                  selectedCircleSize: selectedCircleSize,
                  navIconSize: navIconSize,
                  selectedBackgroundColor: navSelectedBackgroundColor,
                  unselectedBackgroundColor: navUnselectedBackgroundColor,
                  selectedIconColor: navSelectedIconColor,
                  unselectedIconColor: navUnselectedIconColor,
                ),
                _navItem(
                  iconData: Icons.favorite_border,
                  index: 3,
                  label: context.tr.tr('wishlist'),
                  selectedCircleSize: selectedCircleSize,
                  navIconSize: navIconSize,
                  selectedBackgroundColor: navSelectedBackgroundColor,
                  unselectedBackgroundColor: navUnselectedBackgroundColor,
                  selectedIconColor: navSelectedIconColor,
                  unselectedIconColor: navUnselectedIconColor,
                ),
                _navItem(
                  iconData: Icons.person_outline,
                  index: 4,
                  label: context.tr.tr('my_profile'),
                  selectedCircleSize: selectedCircleSize,
                  navIconSize: navIconSize,
                  selectedBackgroundColor: navSelectedBackgroundColor,
                  unselectedBackgroundColor: navUnselectedBackgroundColor,
                  selectedIconColor: navSelectedIconColor,
                  unselectedIconColor: navUnselectedIconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData iconData,
    required int index,
    required String label,
    required double selectedCircleSize,
    required double navIconSize,
    required Color selectedBackgroundColor,
    required Color unselectedBackgroundColor,
    required Color selectedIconColor,
    required Color unselectedIconColor,
  }) {
    final bool selected = _index == index;

    return GestureDetector(
      onTap: () => _changeTab(index),
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: selectedCircleSize,
          height: selectedCircleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? selectedBackgroundColor
                : unselectedBackgroundColor,
            boxShadow: selected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ]
                : null,
          ),
          child: Icon(
            iconData,
            size: navIconSize,
            color: selected ? selectedIconColor : unselectedIconColor,
          ),
        ),
      ),
    );
  }
}