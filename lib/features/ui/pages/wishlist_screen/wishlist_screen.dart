import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../models/product.dart';
import '../../../../services/cart_service.dart';
import '../../../../services/wishlist_service.dart';
import '../bottom_nav_bar/app_drawer.dart';
import '../cart_screen/cart_screen.dart';
import '../product_details_screen/product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  final bool embedded;
  const WishlistScreen({super.key, this.embedded = false});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _search = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String q = '';

  // تثبيت الـ stream هنا يقلل الإحساس بالـ refresh
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _wishlistStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _wishlistStream = WishlistService.instance.wishlistStream();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.kPrimaryPink,
                width: 1.4,
              ),
              color: isDark ? AppColors.darkCard : Colors.white,
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
                    controller: _search,
                    onChanged: (v) => setState(() => q = v.trim().toLowerCase()),
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: context.tr.tr('search'),
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.grey,
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
            stream: _wishlistStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "${context.tr.tr('error')}: ${snapshot.error}",
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    context.tr.tr('wishlist_empty'),
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }

              final filtered = docs.where((d) {
                final name = (d.data()['name'] ?? '').toString().toLowerCase();
                return q.isEmpty ? true : name.contains(q);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(context.tr.tr('no_results')),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final data = filtered[i].data();

                  final p = Product(
                    id: (data['productId'] ?? '').toString(),
                    name: (data['name'] ?? '').toString(),
                    image: (data['image'] ?? '').toString(),
                    price: (data['price'] ?? 0) as num,
                    category: (data['category'] ?? '').toString(),
                    description: (data['description'] ?? '').toString(),
                    rating: ((data['rating'] ?? 0) as num).toDouble(),
                    reviewsCount: ((data['reviewsCount'] ?? 0) as num).toInt(),
                  );

                  return _WishlistTile(product: p);
                },
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedded) return SafeArea(child: body);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.darkScaffold : Colors.white,
      drawer: AppDrawer(
        selectedIndex: 3,
        onSelectIndex: (index) {
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkScaffold : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.kPrimaryPink),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: true,
        title: const Text(
          "Ebda3ha",
          style: TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.bold,
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
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: body,
    );
  }
}

class _WishlistTile extends StatefulWidget {
  final Product product;
  const _WishlistTile({required this.product});

  @override
  State<_WishlistTile> createState() => _WishlistTileState();
}

class _WishlistTileState extends State<_WishlistTile> {
  bool adding = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: p),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 118),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : const Color(0xFFFFD3E3),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(18)),
                child: Image.network(
                  p.image,
                  width: 110,
                  height: 118,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110,
                    height: 118,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              splashRadius: 20,
                              icon: const Icon(
                                Icons.favorite,
                                color: AppColors.kPrimaryPink,
                                size: 26,
                              ),
                              onPressed: () async {
                                try {
                                  await WishlistService.instance.remove(p.id);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.tr.tr('removed_from_wishlist'),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Wishlist Error: $e'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              "EGP ${p.price}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.kPrimaryPink,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.kPrimaryPink,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                minimumSize: const Size(125, 38),
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: adding
                                  ? null
                                  : () async {
                                setState(() => adding = true);
                                try {
                                  await CartService.instance.addToCart(p);

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.tr.tr('added_to_cart'),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text('Cart Error: $e'),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => adding = false);
                                  }
                                }
                              },
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  adding
                                      ? context.tr.tr('adding')
                                      : context.tr.tr('add_to_cart'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}