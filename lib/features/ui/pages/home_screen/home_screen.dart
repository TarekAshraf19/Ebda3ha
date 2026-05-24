import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/ui_actions.dart';
import '../../../../models/home_section_model.dart';
import '../../../../models/product.dart';
import '../../../../services/home_sections_service.dart';
import '../../../../services/wishlist_service.dart';
import '../discover_page/category_products_page.dart';
import '../discover_page/discover_page.dart';
import '../product_details_screen/product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onOpenDiscoverTab;

  const HomeScreen({
    super.key,
    this.embedded = false,
    this.onOpenDiscoverTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  List<Product> _cachedAllProducts = [];

  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  final List<String> _bannerAssets = const [
    'assets/images/Banner 1.png',
    'assets/images/Banner 2.png',
    'assets/images/Banner 3.png',
  ];

  late final Stream<QuerySnapshot> _categoriesStream;
  late final Stream<QuerySnapshot> _allProductsStream;
  late final Stream<List<HomeSectionModel>> _sectionsStream;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  double get screenWidth => MediaQuery.of(context).size.width;

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: screenWidth < 380 ? 12 : 16,
    vertical: 10,
  );

  Color get pageBackgroundColor =>
      isDark ? AppColors.darkScaffold : AppColors.whiteColor;

  Color get surfaceColor =>
      isDark ? AppColors.darkCard : AppColors.whiteColor;

  Color get softSurfaceColor =>
      isDark ? AppColors.darkInputFill : Colors.grey.shade200;

  Color get primaryTextColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.blackColor;

  Color get secondaryTextColor =>
      isDark ? AppColors.darkTextSecondary : Colors.grey;

  Color get dividerColor =>
      isDark ? AppColors.darkBorder : const Color(0xFFEAEAEA);

  @override
  void initState() {
    super.initState();

    _categoriesStream =
        FirebaseFirestore.instance.collection('categories').snapshots();

    _allProductsStream = FirebaseFirestore.instance
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots();

    _sectionsStream = HomeSectionsService.instance.activeSectionsStream();

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_bannerController.hasClients) return;

      int next = _bannerIndex + 1;
      if (next >= _bannerAssets.length) next = 0;

      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  Future<void> _addToCart(Product product, {int qty = 1}) async {
    await UIActions.addToCart(context, product, qty: qty);
  }

  void _openDiscoverPage() {
    if (widget.onOpenDiscoverTab != null) {
      widget.onOpenDiscoverTab!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DiscoverPage(),
      ),
    );
  }

  void _openCategoryPage({
    required String title,
    required String category,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsPage(
          title: title,
          category: category,
        ),
      ),
    );
  }

  String _localizedCategoryLabel(String rawName) {
    switch (rawName.trim().toLowerCase()) {
      case 'shoes':
        return context.tr.tr('shoes');
      case 'bags':
        return context.tr.tr('bags');
      case 'clothing':
        return context.tr.tr('clothing');
      case 'accessories':
        return context.tr.tr('accessories_category');
      case 'collection':
      case 'others':
        return context.tr.tr('collection');
      default:
        return rawName;
    }
  }

  void _handleCategoryTap(String categoryName) {
    final name = categoryName.trim().toLowerCase();

    switch (name) {
      case 'clothing':
        _openCategoryPage(
          title: context.tr.tr('clothing_upper'),
          category: 'Clothing',
        );
        break;
      case 'bags':
      case 'accessories':
        _openCategoryPage(
          title: context.tr.tr('accessories_upper'),
          category: 'Accessories',
        );
        break;
      case 'shoes':
        _openCategoryPage(
          title: context.tr.tr('shoes_upper'),
          category: 'Shoes',
        );
        break;
      case 'others':
      case 'collection':
        _openCategoryPage(
          title: context.tr.tr('collection_upper'),
          category: 'Collection',
        );
        break;
      default:
        _openDiscoverPage();
    }
  }

  String _displaySectionTitle(HomeSectionModel section) {
    final raw = section.title.trim().toLowerCase();
    final category = section.category.trim().toLowerCase();
    final id = section.id.trim().toLowerCase();

    if (raw == 'recommended' || id == 'recommended') {
      return context.tr.tr('recommended');
    }

    if (raw == 'new arrival' ||
        raw == 'new_arrival' ||
        id == 'new-arrival' ||
        id == 'new_arrival') {
      return context.tr.tr('new_arrival');
    }

    if (raw == 'feature product' ||
        raw == 'featured product' ||
        raw == 'featured products' ||
        raw == 'feature products' ||
        id == 'feature-product' ||
        id == 'featured-product' ||
        id == 'featured' ||
        id == 'feature') {
      return context.tr.tr('featured_products');
    }

    if (raw == 'bags product' ||
        raw == 'bags products' ||
        id == 'bags-product' ||
        id == 'bags-products') {
      return context.tr.tr('bags_products');
    }

    if (category == 'bags' && raw.isEmpty) {
      return context.tr.tr('bags_products');
    }

    if (raw == 'shoes') return context.tr.tr('shoes');
    if (raw == 'bags') return context.tr.tr('bags');
    if (raw == 'clothing') return context.tr.tr('clothing');
    if (raw == 'accessories') return context.tr.tr('accessories_category');

    if (raw.isNotEmpty) return section.title.trim();

    if (id.isEmpty) return context.tr.tr('section');

    return id
        .split('-')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _handleSectionSeeAll(HomeSectionModel section) {
    final displayTitle = _displaySectionTitle(section).trim().toLowerCase();

    if (displayTitle == context.tr.tr('recommended').toLowerCase()) {
      _openDiscoverPage();
      return;
    }

    if (displayTitle == context.tr.tr('new_arrival').toLowerCase()) {
      _openCategoryPage(
        title: context.tr.tr('collection_upper'),
        category: 'Collection',
      );
      return;
    }

    final category = section.category.trim();
    if (category.isEmpty) {
      _openDiscoverPage();
      return;
    }

    _openCategoryPage(
      title: _displaySectionTitle(section),
      category: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      color: pageBackgroundColor,
      child: _buildHomeBody(),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      body: SafeArea(child: body),
    );
  }

  Widget _buildHomeBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: _allProductsStream,
      builder: (context, productsSnapshot) {
        if (productsSnapshot.hasData) {
          final docs = productsSnapshot.data!.docs;
          _cachedAllProducts = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return Product.fromDoc(doc.id, data);
          }).toList();
        }

        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            color: pageBackgroundColor,
            child: Padding(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildMainBanner(),
                  const SizedBox(height: 10),
                  _buildDots(
                    count: _bannerAssets.length,
                    activeIndex: _bannerIndex,
                  ),
                  const SizedBox(height: 20),
                  if (_searchText.isNotEmpty) ...[
                    _buildSearchResults(),
                    const SizedBox(height: 24),
                  ] else ...[
                    _buildSectionHeader(
                      context.tr.tr('categories'),
                      showArrow: true,
                      onSeeAllTap: _openDiscoverPage,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoriesList(),
                    const SizedBox(height: 24),
                    _buildSmallOffer(),
                    const SizedBox(height: 24),
                    _buildDynamicSections(),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final Color searchBg =
    isDark ? AppColors.darkSearchBg : AppColors.lightSearchBg;
    final Color searchText =
    isDark ? AppColors.darkSearchText : AppColors.lightSearchText;
    final Color searchHint =
    isDark ? AppColors.darkSearchHint : AppColors.lightSearchHint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: searchBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.kPrimaryPink,
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(
              Icons.search,
              color: AppColors.kPrimaryPink,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBanner() {
    final double bannerHeight = screenWidth < 380 ? 165 : 180;

    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: AppColors.kPrimaryPink,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _bannerAssets.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, index) {
              return Image.asset(
                _bannerAssets[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    context.tr.tr('banner_not_found'),
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDots({required int count, required int activeIndex}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == activeIndex ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == activeIndex
                ? AppColors.kPrimaryPink
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, {
        bool showArrow = false,
        VoidCallback? onSeeAllTap,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: screenWidth < 380 ? 18 : 21,
              fontWeight: FontWeight.bold,
              color: AppColors.kPrimaryPink,
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onSeeAllTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Text(
                  context.tr.tr('see_all'),
                  style: TextStyle(
                    color: AppColors.kPrimaryPink,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth < 380 ? 14 : 16,
                  ),
                ),
                if (showArrow) ...[
                  const SizedBox(width: 6),
                  Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList() {
    final double cardWidth = screenWidth < 380 ? 118 : 132;
    final double cardHeight = screenWidth < 380 ? 154 : 168;

    return SizedBox(
      height: cardHeight,
      child: StreamBuilder<QuerySnapshot>(
        stream: _categoriesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                context.tr.tr('error_loading_categories'),
                style: TextStyle(color: primaryTextColor),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.kPrimaryPink),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                context.tr.tr('no_categories_yet'),
                style: TextStyle(color: primaryTextColor),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>? ?? {};

              final String rawName = (data['name'] ?? '').toString();
              final String name = _localizedCategoryLabel(rawName);

              final int count = (data['count'] is int)
                  ? data['count']
                  : int.tryParse("${data['count']}") ?? 0;

              List<String> imagesList = [];
              if (data['images'] is List) {
                imagesList = List<String>.from(data['images']);
              }

              const String fallbackImage =
                  "https://via.placeholder.com/150x150.png?text=Category";

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _handleCategoryTap(rawName),
                child: Container(
                  width: cardWidth,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: isDark
                        ? Border.all(color: dividerColor, width: 1)
                        : null,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(4, (i) {
                            final String imgUrl =
                            (i < imagesList.length && imagesList[i].isNotEmpty)
                                ? imagesList[i]
                                : fallbackImage;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (_, __, ___) => Container(
                                  color: softSurfaceColor,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: isDark ? Colors.white54 : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth < 380 ? 12 : 13,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE3ED),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$count",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.kPrimaryPink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDynamicSections() {
    return StreamBuilder<List<HomeSectionModel>>(
      stream: _sectionsStream,
      builder: (context, sectionsSnapshot) {
        if (sectionsSnapshot.hasError) {
          return Center(
            child: Text(
              context.tr.tr('error_loading_sections'),
              style: TextStyle(color: primaryTextColor),
            ),
          );
        }

        final sections = sectionsSnapshot.data ?? [];
        if (sections.isEmpty) return const SizedBox.shrink();

        if (_cachedAllProducts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.kPrimaryPink),
          );
        }

        final visibleSections = sections.where((section) {
          return _cachedAllProducts.any(
                (product) => product.sectionIds.contains(section.id),
          );
        }).toList();

        return Column(
          children: visibleSections.map((section) {
            final displayTitle = _displaySectionTitle(section);

            final sectionProducts = _cachedAllProducts.where((product) {
              return product.sectionIds.contains(section.id);
            }).toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildSectionHeader(
                    displayTitle,
                    showArrow: true,
                    onSeeAllTap: () => _handleSectionSeeAll(section),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionProductsStrip(sectionProducts),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSectionProductsStrip(List<Product> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final double itemWidth = screenWidth < 380 ? 148 : 168;
    final double stripHeight = screenWidth < 380 ? 225 : 245;

    return SizedBox(
      height: stripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openDetails(product),
            child: Container(
              width: itemWidth,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isDark
                    ? Border.all(color: dividerColor, width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.05,
                          child: Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Container(
                              color: softSurfaceColor,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkInputFill
                                : AppColors.whiteColor,
                            shape: BoxShape.circle,
                          ),
                          child: StreamBuilder<bool>(
                            stream: WishlistService.instance
                                .isInWishlistStream(product.id),
                            builder: (context, snap) {
                              final liked = snap.data ?? false;
                              return IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: AppColors.kPrimaryPink,
                                ),
                                onPressed: () async {
                                  try {
                                    if (liked) {
                                      await WishlistService.instance
                                          .remove(product.id);
                                    } else {
                                      await WishlistService.instance
                                          .add(product);
                                    }

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          liked
                                              ? 'Removed from wishlist'
                                              : 'Added to wishlist',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Wishlist Error: $e'),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.kPrimaryPink,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () => _addToCart(product, qty: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth < 380 ? 12 : 12.5,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "EGP ${product.price}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.kPrimaryPink,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallOffer() {
    final double offerHeight = screenWidth < 380 ? 100 : 110;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _openCategoryPage(
        title: context.tr.tr('accessories_upper'),
        category: 'Accessories',
      ),
      child: Container(
        height: offerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: surfaceColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  color: AppColors.kPrimaryPink,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr.tr('offer_accessories_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr.tr('offer_accessories_subtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox.expand(
                  child: Image.asset(
                    'assets/images/accs 1.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final q = _searchText.trim().toLowerCase();

    if (_cachedAllProducts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.kPrimaryPink),
      );
    }

    final results = _cachedAllProducts.where((product) {
      final name = product.name.toLowerCase();
      final category = product.category.toLowerCase();
      return name.contains(q) || category.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.tr('search_results'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 10),
        if (results.isEmpty)
          Text(
            context.tr.tr('no_products_found'),
            style: TextStyle(color: primaryTextColor),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _openDetails(product),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: isDark
                        ? Border.all(color: dividerColor, width: 1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(18),
                        ),
                        child: Image.network(
                          product.image,
                          width: 90,
                          height: 110,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90,
                            height: 110,
                            color: softSurfaceColor,
                            child: Icon(
                              Icons.broken_image,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "EGP ${product.price}",
                                style: const TextStyle(
                                  color: AppColors.kPrimaryPink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}