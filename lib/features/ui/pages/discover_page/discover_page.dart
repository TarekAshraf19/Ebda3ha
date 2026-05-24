import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../cart_screen/cart_screen.dart';
import 'category_products_page.dart';

class DiscoverPage extends StatefulWidget {
  final bool embedded;

  const DiscoverPage({super.key, this.embedded = false});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // ================================
  // تثبيت الـ stream هنا يقلل الإحساس بالـ refresh
  // وقت تغيير الـ dark / light mode
  // ================================
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _categoriesStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _categoriesStream = FirebaseFirestore.instance
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeCategory(String value) {
    final raw = value.trim().toLowerCase();

    switch (raw) {
      case 'bags':
      case 'accessories':
        return 'Accessories';
      case 'others':
      case 'collection':
        return 'Collection';
      case 'clothing':
        return 'Clothing';
      case 'shoes':
        return 'Shoes';
      default:
        return value.trim();
    }
  }

  String _displayTitle(String value) {
    return _normalizeCategory(value).toUpperCase();
  }

  // ================================
  // الاسم المعروض حسب اللغة
  // لو عربي يطلع بالعربي
  // لو مش موجود ترجمة يرجع الإنجليزي
  // ================================
  String _localizedDisplayTitle(BuildContext context, String value) {
    final normalized = _normalizeCategory(value).trim().toLowerCase();

    switch (normalized) {
      case 'clothing':
        return context.tr.tr('clothing_upper');
      case 'accessories':
        return context.tr.tr('accessories_upper');
      case 'shoes':
        return context.tr.tr('shoes_upper');
      case 'collection':
        return context.tr.tr('collection_upper');
      default:
        return _displayTitle(value);
    }
  }

  int _categoryOrder(String category) {
    switch (category.trim().toLowerCase()) {
      case 'clothing':
        return 0; // 👈 أول كارد
      case 'accessories':
      case 'bags':
        return 1; // 👈 تاني كارد
      case 'shoes':
        return 2; // 👈 تالت كارد
      case 'collection':
      case 'others':
        return 3; // 👈 رابع كارد
      default:
        return 99;
    }
  }

  Color _categoryColor(String category, bool isDark) {
    switch (category.trim().toLowerCase()) {
      case 'clothing':
        return isDark ? const Color(0xFF8A8A7D) : const Color(0xFFB9BAAA);

      case 'accessories':
      case 'bags':
        return isDark ? const Color(0xFF8C8383) : const Color(0xFFA79F9F);

      case 'shoes':
        return isDark ? const Color(0xFF526872) : const Color(0xFF4F6670);

      case 'collection':
      case 'others':
        return isDark ? const Color(0xFF9F9199) : const Color(0xFFC9BEC4);

      default:
        return isDark ? const Color(0xFF5C5C5C) : Colors.grey.shade400;
    }
  }

  // ================================
  // الصور من الـ assets
  // ================================
  // clothing      = أول صورة
  // accessories   = تاني صورة
  // shoes         = تالت صورة
  // collection    = رابع صورة
  String _assetImageForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'clothing':
        return 'assets/images/cloth-category.png'; // 👈 أول صورة
      case 'accessories':
      case 'bags':
        return 'assets/images/access-category.png'; // 👈 تاني صورة
      case 'shoes':
        return 'assets/images/shoes-categoryy.png'; // 👈 تالت صورة
      case 'collection':
      case 'others':
        return 'assets/images/collec-category.png'; // 👈 رابع صورة
      default:
        return 'assets/images/cloth-category.png';
    }
  }

  // ================================
  // هنا بتتحكم في Padding كل صورة لوحدها
  // ================================
  // لو عايز تزق صورة لليمين/الشمال/فوق/تحت عدّل هنا
  // المهم: في العربي عملنا Mirror للإنجليزي
  // يعني نفس الشكل لكن معكوس
  EdgeInsets _imagePaddingForCategory(String category, bool isArabic) {
    switch (category.trim().toLowerCase()) {
      case 'clothing':
      // 👈 أول صورة
      // EN: right: 32
      // AR: left: 32
        return isArabic
            ? const EdgeInsets.only(
          left: 42,
          top: 10,
          bottom: 10,
          right: 0,
        )
            : const EdgeInsets.only(
          right: 32,
          top: 10,
          bottom: 10,
          left: 0,
        );

      case 'accessories':
      case 'bags':
      // 👈 تاني صورة
      // EN: right: 0
      // AR: left: 0
        return isArabic
            ? const EdgeInsets.only(
          left: 0,
          top: 14,
          bottom: 14,
          right: 0,
        )
            : const EdgeInsets.only(
          right: 0,
          top: 14,
          bottom: 14,
          left: 0,
        );

      case 'shoes':
      // 👈 تالت صورة
      // EN: right: 38
      // AR: left: 38
        return isArabic
            ? const EdgeInsets.only(
          left: 28,
          top: 6,
          bottom: 6,
          right: 0,
        )
            : const EdgeInsets.only(
          right: 38,
          top: 6,
          bottom: 6,
          left: 0,
        );

      case 'collection':
      case 'others':
      // 👈 رابع صورة
      // EN: right: 55
      // AR: left: 55
        return isArabic
            ? const EdgeInsets.only(
          left: 50,
          top: 10,
          bottom: 10,
          right: 0,
        )
            : const EdgeInsets.only(
          right: 55,
          top: 10,
          bottom: 10,
          left: 0,
        );

      default:
        return isArabic
            ? const EdgeInsets.only(
          left: 8,
          top: 8,
          bottom: 8,
          right: 0,
        )
            : const EdgeInsets.only(
          right: 8,
          top: 8,
          bottom: 8,
          left: 0,
        );
    }
  }

  // ================================
  // هنا بتتحكم في عرض كل صورة لوحدها
  // ================================
  // زوّد الرقم = الصورة تكبر
  // قلل الرقم = الصورة تصغر
  double _imageWidthForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'clothing':
        return 200; // 👈 أول صورة

      case 'accessories':
      case 'bags':
        return 160; // 👈 تاني صورة

      case 'shoes':
        return 280; // 👈 تالت صورة

      case 'collection':
      case 'others':
        return 170; // 👈 رابع صورة

      default:
        return 180;
    }
  }

  // ================================
  // هنا بتتحكم في طريقة عرض كل صورة
  // ================================
  // غالبًا سيبها contain
  BoxFit _imageFitForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'clothing':
        return BoxFit.contain; // 👈 أول صورة
      case 'accessories':
      case 'bags':
        return BoxFit.contain; // 👈 تاني صورة
      case 'shoes':
        return BoxFit.contain; // 👈 تالت صورة
      case 'collection':
      case 'others':
        return BoxFit.contain; // 👈 رابع صورة
      default:
        return BoxFit.contain;
    }
  }

  // ================================
  // هنا بتتحكم في مكان محاذاة كل صورة
  // ================================
  // في العربي الصورة شمال
  // في الإنجليزي الصورة يمين
  Alignment _imageAlignmentForCategory(String category, bool isArabic) {
    if (isArabic) {
      return Alignment.centerLeft;
    }
    return Alignment.centerRight;
  }

  Widget _buildCategoryImage(String category, bool isArabic) {
    final assetPath = _assetImageForCategory(category);

    return Align(
      alignment: _imageAlignmentForCategory(category, isArabic),
      child: Image.asset(
        assetPath,
        fit: _imageFitForCategory(category),
        alignment: _imageAlignmentForCategory(category, isArabic),
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.white.withOpacity(0.12),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }

  // ================================
  // الدايرة الأولى لكل صورة لوحدها
  // ================================
  // size   = حجم الدايرة
  // offset = مكانها أفقيًا
  // top    = مكانها رأسيًا
  // في العربي بتتنقل للشمال بنفس القيمة
  Map<String, double> _circle1Config(String category) {
    switch (category.trim().toLowerCase()) {
      case 'clothing':
      // 👈 الدايرة الأولى لأول صورة
        return {
          'size': 92,
          'offset': 42,
          'top': 18,
        };

      case 'accessories':
      case 'bags':
      // 👈 الدايرة الأولى لتاني صورة
        return {
          'size': 92,
          'offset': 42,
          'top': 18,
        };

      case 'shoes':
      // 👈 الدايرة الأولى لتالت صورة
        return {
          'size': 80,
          'offset': 42,
          'top': 23,
        };

      case 'collection':
      case 'others':
      // 👈 الدايرة الأولى لرابع صورة
        return {
          'size': 92,
          'offset': 42,
          'top': 18,
        };

      default:
        return {
          'size': 92,
          'offset': 42,
          'top': 18,
        };
    }
  }

  // ================================
  // الدايرة الثانية لكل صورة لوحدها
  // ================================
  Map<String, double> _circle2Config(String category) {
    switch (category.trim().toLowerCase()) {
      case 'clothing':
      // 👈 الدايرة الثانية لأول صورة
        return {
          'size': 126,
          'offset': 24,
          'top': 0,
        };

      case 'accessories':
      case 'bags':
      // 👈 الدايرة الثانية لتاني صورة
        return {
          'size': 126,
          'offset': 24,
          'top': 0,
        };

      case 'shoes':
      // 👈 الدايرة الثانية لتالت صورة
        return {
          'size': 115,
          'offset': 24,
          'top': 5,
        };

      case 'collection':
      case 'others':
      // 👈 الدايرة الثانية لرابع صورة
        return {
          'size': 126,
          'offset': 24,
          'top': 0,
        };

      default:
        return {
          'size': 126,
          'offset': 24,
          'top': 0,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;

    final Color scaffoldBg =
    isDark ? AppColors.darkScaffold : const Color(0xFFF5F3F4);
    final Color searchBg = isDark ? AppColors.darkSearchBg : Colors.white;
    final Color searchText =
    isDark ? AppColors.darkSearchText : AppColors.lightSearchText;
    final Color searchHint =
    isDark ? AppColors.darkSearchHint : AppColors.lightSearchHint;
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.kPrimaryPink;

    final body = SafeArea(
      bottom: false,
      child: Column(
        children: [
          if (!widget.embedded) const SizedBox(height: 8),

          if (!widget.embedded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 72,
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu,
                      color: AppColors.kPrimaryPink,
                      size: 31,
                    ),
                    const Spacer(),
                    Text(
                      context.tr.tr('app_name'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kPrimaryPink,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CartScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: AppColors.kPrimaryPink,
                          size: 31,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 14),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: AppColors.kPrimaryPink,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  const Icon(
                    Icons.search,
                    color: AppColors.kPrimaryPink,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        color: searchText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: context.tr.tr('search'),
                        hintStyle: TextStyle(
                          color: searchHint,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _categoriesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      context.tr.tr('error_loading_categories'),
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryText,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kPrimaryPink,
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final categories = docs
                    .map((doc) {
                  final data = doc.data();
                  final rawName = (data['name'] ?? '').toString().trim();
                  final normalizedName = _normalizeCategory(rawName);
                  final isActive = (data['isActive'] ?? true) as bool;

                  return {
                    'id': doc.id,
                    'name': normalizedName,
                    'isActive': isActive,
                  };
                })
                    .where((item) => (item['name'] as String).isNotEmpty)
                    .where((item) => item['isActive'] as bool)
                    .toList();

                categories.sort((a, b) {
                  final aName = a['name'] as String;
                  final bName = b['name'] as String;
                  return _categoryOrder(aName).compareTo(_categoryOrder(bName));
                });

                final filtered = categories.where((item) {
                  if (_searchText.isEmpty) return true;
                  final name = (item['name'] as String).toLowerCase();
                  return name.contains(_searchText);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      context.tr.tr('no_categories_found'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: primaryText,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final categoryName = item['name'] as String;

                    return _DiscoverCategoryCard(
                      title: _localizedDisplayTitle(context, categoryName),
                      category: categoryName,
                      color: _categoryColor(categoryName, isDark),
                      imageWidget: _buildCategoryImage(categoryName, isArabic),
                      imageWidth: _imageWidthForCategory(categoryName),
                      imagePadding:
                      _imagePaddingForCategory(categoryName, isArabic),
                      circle1Config: _circle1Config(categoryName),
                      circle2Config: _circle2Config(categoryName),
                      isArabic: isArabic,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryProductsPage(
                              title:
                              _localizedDisplayTitle(context, categoryName),
                              category: categoryName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: body,
    );
  }
}

class _DiscoverCategoryCard extends StatelessWidget {
  final String title;
  final String category;
  final Color color;
  final Widget imageWidget;
  final double imageWidth;
  final EdgeInsets imagePadding;
  final Map<String, double> circle1Config;
  final Map<String, double> circle2Config;
  final bool isArabic;
  final VoidCallback onTap;

  const _DiscoverCategoryCard({
    required this.title,
    required this.category,
    required this.color,
    required this.imageWidget,
    required this.imageWidth,
    required this.imagePadding,
    required this.circle1Config,
    required this.circle2Config,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 125; // 👈 حجم الكارد كله
    const double textSize = 18; // 👈 حجم النص

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // ================================
                // الدايرة الأولى
                // offset = نفس قيمة right في الإنجليزي
                // وفي العربي بتروح left بنفس القيمة
                // top    = تحريك فوق/تحت
                // size   = حجم الدايرة
                // ================================
                Positioned(
                  right: isArabic ? null : (circle1Config['offset'] ?? 42),
                  left: isArabic ? (circle1Config['offset'] ?? 42) : null,
                  top: circle1Config['top'] ?? 18,
                  child: Container(
                    width: circle1Config['size'] ?? 92,
                    height: circle1Config['size'] ?? 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // ================================
                // الدايرة الثانية
                // ================================
                Positioned(
                  right: isArabic ? null : (circle2Config['offset'] ?? 24),
                  left: isArabic ? (circle2Config['offset'] ?? 24) : null,
                  top: circle2Config['top'] ?? 0,
                  child: Container(
                    width: circle2Config['size'] ?? 126,
                    height: circle2Config['size'] ?? 126,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),

                // ================================
                // النص
                // في الإنجليزي: النص شمال والصورة يمين
                // في العربي: النص يمين والصورة شمال
                // left/right هنا معكوسين حسب اللغة
                // ================================
                Positioned(
                  left: isArabic ? 170 : 24,
                  right: isArabic ? 24 : 170,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment:
                    isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      title,
                      textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: textSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // ================================
                // الصورة
                // في الإنجليزي الصورة يمين
                // في العربي الصورة شمال
                // imageWidth   = حجم الصورة من فوق
                // imagePadding = مكان الصورة من فوق
                // ================================
                Positioned(
                  right: isArabic ? null : 0,
                  left: isArabic ? 0 : null,
                  top: 0,
                  bottom: 0,
                  width: imageWidth,
                  child: Padding(
                    padding: imagePadding,
                    child: imageWidget,
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