import 'package:flutter/material.dart';
import 'package:ebad3a_ecommerce/models/product.dart';
import 'package:ebad3a_ecommerce/services/wishlist_service.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/ui_actions.dart';
import '../cart_screen/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int qty = 1;
  bool loading = false;
  int activeDot = 0;

  final List<Color> colors = const [
    Color(0xFFD7B9A3),
    Color(0xFF000000),
    Color(0xFFFF5A5A),
  ];
  int selectedColor = 0;

  final List<String> sizes = const ['S', 'M', 'L'];
  int selectedSize = 1;

  String get selectedSizeValue => sizes[selectedSize];

  String get selectedColorName {
    switch (selectedColor) {
      case 0:
        return 'Beige';
      case 1:
        return 'Black';
      case 2:
        return 'Red';
      default:
        return 'Unknown';
    }
  }

  Future<void> _toggleWishlist(Product product) async {
    try {
      await UIActions.toggleWishlist(context, product);

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${context.tr.tr('error')}: $e")),
      );
    }
  }

  Future<void> _addToCart(Product product) async {
    setState(() => loading = true);

    try {
      await UIActions.addToCart(
        context,
        product,
        qty: qty,
        size: selectedSizeValue,
        color: selectedColorName,
      );

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${context.tr.tr('error')}: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final double rating = p.rating.toDouble();
    final int reviewsCount = p.reviewsCount;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color scaffoldBg =
    isDark ? AppColors.darkScaffold : const Color(0xFFFFF8FA);
    final Color surfaceBg =
    isDark ? AppColors.darkSurface : AppColors.whiteColor;
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;
    final Color secondaryText =
    isDark ? AppColors.darkTextSecondary : Colors.grey.shade700;
    final Color softBg =
    isDark ? AppColors.darkCard : const Color(0xFFFFFCFD);
    final Color softBorder =
    isDark ? AppColors.darkBorder : const Color(0xFFF3E8ED);
    final Color chipBg =
    isDark ? AppColors.darkInputFill : const Color(0xFFFFEAF1);
    final Color cardBg =
    isDark ? AppColors.darkCard : AppColors.whiteColor;
    final Color dividerLight =
    isDark ? AppColors.darkBorder : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopSection(p, isDark),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(34),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleAndPrice(p, isDark),
                          const SizedBox(height: 12),
                          _buildRatingRow(
                            rating,
                            reviewsCount,
                            secondaryText,
                          ),
                          const SizedBox(height: 22),
                          _buildColorAndSize(isDark, secondaryText),
                          const SizedBox(height: 22),
                          _buildInfoCard(
                            softBg,
                            softBorder,
                            _expandTile(
                              title: context.tr.tr('description'),
                              initiallyExpanded: true,
                              titleColor: primaryText,
                              trailingColor:
                              Theme.of(context).iconTheme.color ?? primaryText,
                              child: Text(
                                p.description.isEmpty
                                    ? context.tr.tr('no_description')
                                    : p.description,
                                style: TextStyle(
                                  color: secondaryText,
                                  height: 1.65,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildInfoCard(
                            softBg,
                            softBorder,
                            _expandTile(
                              title: context.tr.tr('reviews'),
                              titleColor: primaryText,
                              trailingColor:
                              Theme.of(context).iconTheme.color ?? primaryText,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: primaryText,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.tr.tr('out_of_5'),
                                        style: TextStyle(
                                          color: secondaryText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      _starsRow(rating, iconSize: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _reviewBar(
                                    label: '5',
                                    value: 0.80,
                                    secondaryText: secondaryText,
                                    isDark: isDark,
                                  ),
                                  _reviewBar(
                                    label: '4',
                                    value: 0.12,
                                    secondaryText: secondaryText,
                                    isDark: isDark,
                                  ),
                                  _reviewBar(
                                    label: '3',
                                    value: 0.05,
                                    secondaryText: secondaryText,
                                    isDark: isDark,
                                  ),
                                  _reviewBar(
                                    label: '2',
                                    value: 0.03,
                                    secondaryText: secondaryText,
                                    isDark: isDark,
                                  ),
                                  _reviewBar(
                                    label: '1',
                                    value: 0.00,
                                    secondaryText: secondaryText,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildQuantityRow(chipBg, primaryText),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                decoration: BoxDecoration(
                  color: cardBg.withOpacity(0.98),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimaryPink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: loading ? null : () => _addToCart(p),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          loading
                              ? context.tr.tr('adding')
                              : context.tr.tr('add_to_cart'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(Product p, bool isDark) {
    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          Positioned(
            top: 55,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 265,
                height: 265,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                      Color(0xFF402533),
                      Color(0xFF2A1C24),
                    ]
                        : const [
                      Color(0xFFFFE9F1),
                      Color(0xFFFFF3F7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 14,
            child: _circleIcon(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
              bg: isDark ? AppColors.darkCard : Colors.white,
              iconColor: isDark ? Colors.white : Colors.black,
            ),
          ),
          Positioned(
            top: 16,
            right: 14,
            child: StreamBuilder<bool>(
              stream: WishlistService.instance.isInWishlistStream(p.id),
              builder: (context, snapshot) {
                final liked = snapshot.data ?? false;

                return _circleIcon(
                  icon: liked ? Icons.favorite : Icons.favorite_border,
                  onTap: () => _toggleWishlist(p),
                  bg: isDark ? AppColors.darkCard : Colors.white,
                  iconColor: AppColors.kPrimaryPink,
                );
              },
            ),
          ),
          Positioned(
            top: 52,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 240,
              child: Hero(
                tag: "product_${p.id}",
                child: Image.network(
                  p.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                        size: 42,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: _dotsRow(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndPrice(Product p, bool isDark) {
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            p.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: primaryText,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkInputFill
                : const Color(0xFFFFEDF4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            "EGP ${p.price}",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.kPrimaryPink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(
      double rating,
      int reviewsCount,
      Color secondaryText,
      ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6DA),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "$reviewsCount ${context.tr.tr('reviews')}",
          style: TextStyle(
            color: secondaryText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildColorAndSize(bool isDark, Color secondaryText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _labelBlock(
            title: context.tr.tr('color'),
            color: secondaryText,
            child: Row(
              children: List.generate(colors.length, (i) {
                final c = colors[i];
                final selected = selectedColor == i;

                return GestureDetector(
                  onTap: () => setState(() => selectedColor = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 10),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.kPrimaryPink
                            : (isDark ? AppColors.darkSurface : Colors.white),
                        width: selected ? 2.4 : 1.2,
                      ),
                      boxShadow: [
                        if (selected)
                          BoxShadow(
                            color: AppColors.kPrimaryPink.withOpacity(0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _labelBlock(
            title: context.tr.tr('size'),
            color: secondaryText,
            child: Row(
              children: List.generate(sizes.length, (i) {
                final s = sizes[i];
                final selected = selectedSize == i;

                return GestureDetector(
                  onTap: () => setState(() => selectedSize = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 10),
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected
                          ? AppColors.kPrimaryPink
                          : (isDark
                          ? AppColors.darkInputFill
                          : const Color(0xFFF6F6F6)),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: selected ? Colors.white : secondaryText,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Color bg, Color border, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _buildQuantityRow(Color chipBg, Color primaryText) {
    return Row(
      children: [
        Text(
          context.tr.tr('quantity'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: primaryText,
          ),
        ),
        const Spacer(),
        _qtyBtn(
          icon: Icons.remove,
          bg: chipBg,
          onTap: () => setState(() => qty = (qty > 1) ? qty - 1 : 1),
        ),
        SizedBox(
          width: 52,
          child: Center(
            child: Text(
              "$qty",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: primaryText,
              ),
            ),
          ),
        ),
        _qtyBtn(
          icon: Icons.add,
          bg: chipBg,
          onTap: () => setState(() => qty = qty + 1),
        ),
        const SizedBox(width: 16),
        _circleIcon(
          icon: Icons.shopping_cart_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            );
          },
          bg: chipBg,
          iconColor: AppColors.kPrimaryPink,
        ),
      ],
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }

  Widget _dotsRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = activeDot == i;

        return GestureDetector(
          onTap: () => setState(() => activeDot = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.kPrimaryPink
                  : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }

  Widget _starsRow(double rating, {double iconSize = 16}) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;

    return Row(
      children: List.generate(5, (i) {
        IconData icon;

        if (i < full) {
          icon = Icons.star;
        } else if (i == full && half) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return Icon(
          icon,
          size: iconSize,
          color: Colors.amber,
        );
      }),
    );
  }

  Widget _labelBlock({
    required String title,
    required Widget child,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _expandTile({
    required String title,
    required Widget child,
    required Color titleColor,
    required Color trailingColor,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 14),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            color: titleColor,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: trailingColor,
        ),
        children: [child],
      ),
    );
  }

  Widget _reviewBar({
    required String label,
    required double value,
    required Color secondaryText,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.blackColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: isDark
                    ? AppColors.darkBorder
                    : const Color(0xFFF1F1F1),
                valueColor: const AlwaysStoppedAnimation(Colors.amber),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(
              "${(value * 100).round()}%",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: secondaryText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.remove,
          color: AppColors.kPrimaryPink,
          size: 20,
        ),
      ),
    ).copyWithIcon(icon);
  }
}

extension on Widget {
  Widget copyWithIcon(IconData icon) {
    if (this is! InkWell) return this;
    final ink = this as InkWell;
    final container = ink.child as Container;
    return InkWell(
      onTap: ink.onTap,
      borderRadius: ink.borderRadius,
      child: Container(
        width: container.constraints?.maxWidth ?? 42,
        height: container.constraints?.maxHeight ?? 42,
        decoration: container.decoration,
        child: Icon(
          icon,
          color: AppColors.kPrimaryPink,
          size: 20,
        ),
      ),
    );
  }
}