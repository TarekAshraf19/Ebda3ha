import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../models/product.dart';
import '../../../../services/wishlist_service.dart';
import '../../../../core/utils/ui_actions.dart';
import '../cart_screen/cart_screen.dart';
import '../product_details_screen/product_details_screen.dart';

class CategoryProductsPage extends StatefulWidget {
  final String title;
  final String category;

  const CategoryProductsPage({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  String get _normalizedCategory {
    final raw = widget.category.trim().toLowerCase();

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
        return widget.category.trim();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts() {
    final products = FirebaseFirestore.instance.collection('products');

    if (_normalizedCategory == 'Accessories') {
      return products
          .where('category', whereIn: ['Accessories', 'Bags'])
          .where('isActive', isEqualTo: true)
          .snapshots();
    }

    if (_normalizedCategory == 'Collection') {
      return products
          .where('category', whereIn: ['Collection', 'Others'])
          .where('isActive', isEqualTo: true)
          .snapshots();
    }

    return products
        .where('category', isEqualTo: _normalizedCategory)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  void _openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    await UIActions.addToCart(context, product);
  }

  Future<void> _toggleWishlist(Product product) async {
    try {
      final isInWishlist =
      await WishlistService.instance.isInWishlist(product.id);

      if (isInWishlist) {
        await WishlistService.instance.remove(product.id);
      } else {
        await WishlistService.instance.add(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isInWishlist
                ? "Removed from wishlist 💔"
                : "Added to wishlist ❤️",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Wishlist Error: $e"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color scaffoldBg =
    isDark ? AppColors.darkScaffold : AppColors.kPageBg;
    final Color appBarBg =
    isDark ? AppColors.darkScaffold : AppColors.kPageBg;
    final Color cardBg =
    isDark ? AppColors.darkCard : AppColors.whiteColor;
    final Color searchBg =
    isDark ? AppColors.darkSearchBg : AppColors.lightSearchBg;
    final Color searchTextColor =
    isDark ? AppColors.darkSearchText : AppColors.lightSearchText;
    final Color searchHint =
    isDark ? AppColors.darkSearchHint : AppColors.lightSearchHint;
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;
    final Color secondaryText =
    isDark ? AppColors.darkTextSecondary : Colors.grey.shade600;
    final Color borderColor =
    isDark ? AppColors.darkBorder : const Color(0xFFE8E8E8);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.kPrimaryPink),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.kPrimaryPink,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.kPrimaryPink,
                  width: 1.5,
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
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                      style: TextStyle(
                        color: searchTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
              stream: getProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      context.tr.tr('error'),
                      style: TextStyle(color: primaryText),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kPrimaryPink,
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final products = docs
                    .map((d) => Product.fromDoc(d.id, d.data()))
                    .toList();

                final query = _searchText.trim().toLowerCase();

                final filtered = products.where((p) {
                  if (query.isEmpty) return true;

                  final name = p.name.toLowerCase();
                  final category = p.category.toLowerCase();
                  final description = p.description.toLowerCase();

                  return name.contains(query) ||
                      category.contains(query) ||
                      description.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      context.tr.tr('no_products'),
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: filtered.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.64,
                  ),
                  itemBuilder: (context, index) {
                    final product = filtered[index];

                    return _CategoryProductCard(
                      product: product,
                      cardBg: cardBg,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      borderColor: borderColor,
                      onTap: () => _openDetails(product),
                      onAdd: () => _addToCart(product),
                      onWishlist: () => _toggleWishlist(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryProductCard extends StatelessWidget {
  final Product product;
  final Color cardBg;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onWishlist;

  const _CategoryProductCard({
    required this.product,
    required this.cardBg,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
    required this.onTap,
    required this.onAdd,
    required this.onWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.16 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark
                              ? AppColors.darkInputFill
                              : Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image,
                            color: secondaryText,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkInputFill
                            : Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                      ),
                      child: StreamBuilder<bool>(
                        stream:
                        WishlistService.instance.isInWishlistStream(product.id),
                        builder: (context, snapshot) {
                          final liked = snapshot.data ?? false;

                          return IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                            onPressed: onWishlist,
                            icon: Icon(
                              liked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.kPrimaryPink,
                              size: 18,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "EGP ${product.price}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.kPrimaryPink,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.kPrimaryPink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}