import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ebad3a_ecommerce/services/cart_service.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../models/cart_item.dart';
import '../checkout_screen/checkout_shipping_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color scaffoldBg =
    isDark ? AppColors.darkScaffold : AppColors.kPageBg;
    final Color appBarBg =
    isDark ? AppColors.darkScaffold : AppColors.kPageBg;
    final Color cardBg =
    isDark ? AppColors.darkCard : AppColors.whiteColor;
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color secondaryText =
    isDark ? AppColors.darkTextSecondary : AppColors.kTextGrey;
    final Color borderColor =
    isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final Color dividerColor =
    isDark ? AppColors.darkBorder : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.kPrimaryPink,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr.tr('your_cart'),
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: CartService.instance.cartItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "${context.tr.tr('error')}: ${snapshot.error}",
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

          if (docs.isEmpty) {
            return Center(
              child: Text(
                context.tr.tr('cart_empty'),
                style: TextStyle(
                  fontSize: 16,
                  color: primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final items = docs
              .map((d) => CartItem.fromMap(d.data(), docId: d.id))
              .toList();

          items.sort((a, b) => b.cartItemId.compareTo(a.cartItemId));

          final double itemsTotal =
          items.fold<double>(0, (sum, it) => sum + it.total.toDouble());
          const double shipping = 50.0;
          final double subtotal = itemsTotal + shipping;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: [
                ...items.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CartItemTile(item: item),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.16 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        context.tr.tr('product_price'),
                        "EGP ${itemsTotal.toStringAsFixed(2)}",
                        primaryText: primaryText,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: dividerColor, height: 1),
                      const SizedBox(height: 16),
                      _summaryRow(
                        context.tr.tr('shipping'),
                        "EGP ${shipping.toStringAsFixed(2)}",
                        primaryText: primaryText,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: dividerColor, height: 1),
                      const SizedBox(height: 16),
                      _summaryRow(
                        context.tr.tr('subtotal'),
                        "EGP ${subtotal.toStringAsFixed(2)}",
                        primaryText: primaryText,
                        isBold: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimaryPink,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutShippingScreen(
                                  cartSubtotal: itemsTotal,
                                  cartItems: items,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            context.tr.tr('proceed_to_checkout'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _summaryRow(
      String title,
      String value, {
        required Color primaryText,
        bool isBold = false,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isBold ? 16 : 15,
              color: primaryText,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            color: AppColors.kPrimaryPink,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg =
    isDark ? AppColors.darkCard : AppColors.whiteColor;
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;
    final Color secondaryText =
    isDark ? AppColors.darkTextSecondary : Colors.grey.shade600;
    final Color imageFallbackBg =
    isDark ? AppColors.darkInputFill : Colors.grey.shade200;
    final Color borderColor =
    isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.16 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.image,
                width: 112,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 112,
                  color: imageFallbackBg,
                  child: Icon(
                    Icons.broken_image,
                    color: secondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: primaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () =>
                              CartService.instance.removeItem(item.cartItemId),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryPink,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppColors.whiteColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "EGP ${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: AppColors.kPrimaryPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${context.tr.tr('color')}: ${item.color}  |  ${context.tr.tr('size')}: ${item.size}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _qtyPill(
                        isDark: isDark,
                        onMinus: () {
                          if (item.quantity > 1) {
                            CartService.instance.setQuantity(
                              item.cartItemId,
                              item.quantity - 1,
                            );
                          }
                        },
                        onPlus: () {
                          CartService.instance.setQuantity(
                            item.cartItemId,
                            item.quantity + 1,
                          );
                        },
                        qty: item.quantity,
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
  }

  Widget _qtyPill({
    required bool isDark,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required int qty,
  }) {
    final Color borderColor = isDark
        ? AppColors.kPrimaryPink.withOpacity(.65)
        : AppColors.kPrimaryPink.withOpacity(.45);

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onMinus,
            child: const Icon(
              Icons.remove,
              size: 16,
              color: AppColors.kPrimaryPink,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "$qty",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.kPrimaryPink,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onPlus,
            child: const Icon(
              Icons.add,
              size: 16,
              color: AppColors.kPrimaryPink,
            ),
          ),
        ],
      ),
    );
  }
}