import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../models/order_model.dart';
import 'rate_product_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  bool get canRate => order.status == 'delivered';

  String _headerTitle(BuildContext context) {
    if (order.status == 'delivered') {
      return context.tr.tr('your_order_delivered');
    }
    if (order.status == 'cancelled') {
      return context.tr.tr('your_order_cancelled');
    }
    return context.tr.tr('your_order_on_way');
  }

  String _headerSubtitle(BuildContext context) {
    if (order.status == 'delivered') {
      return context.tr.tr('rate_product_points');
    }
    if (order.status == 'cancelled') {
      return context.tr.tr('this_order_cancelled');
    }
    return context.tr.tr('click_track_order');
  }

  IconData get headerIcon {
    if (order.status == 'delivered') return Icons.handshake_outlined;
    if (order.status == 'cancelled') return Icons.cancel_outlined;
    return Icons.local_shipping_outlined;
  }

  String get displayOrderNumber =>
      '#${order.orderId.substring(0, 4).toUpperCase()}';

  String get deliveryAddress {
    final first = (order.shippingAddress['firstName'] ?? '').toString();
    final last = (order.shippingAddress['lastName'] ?? '').toString();
    final street = (order.shippingAddress['streetName'] ?? '').toString();
    final city = (order.shippingAddress['city'] ?? '').toString();
    final country = (order.shippingAddress['country'] ?? '').toString();

    return '$first $last, $street, $city, $country';
  }

  Widget _infoRow(
      BuildContext context,
      String title,
      String value, {
        required Color titleColor,
        required Color valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(
      BuildContext context,
      OrderItemModel item, {
        required Color primaryText,
        required Color secondaryText,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                color: primaryText,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            'x${item.quantity}',
            style: TextStyle(
              color: secondaryText,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            'EGP ${item.total.toStringAsFixed(2)}',
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      BuildContext context,
      String title,
      String value, {
        bool bold = false,
        required Color primaryText,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: primaryText,
              fontSize: bold ? 18 : 16,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: primaryText,
              fontSize: bold ? 18 : 16,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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
    isDark ? AppColors.darkTextPrimary : Colors.black87;
    final Color secondaryText =
    isDark ? AppColors.darkTextSecondary : const Color(0xFF8A8FA3);
    final Color borderColor =
    isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final tracking = order.trackingNumber.isEmpty
        ? context.tr.tr('not_assigned_yet')
        : order.trackingNumber;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${context.tr.tr('order')} $displayOrderNumber',
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.kPrimaryPink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.kPrimaryPink,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _headerTitle(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _headerSubtitle(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  headerIcon,
                  color: Colors.white,
                  size: 38,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.14 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _infoRow(
                  context,
                  context.tr.tr('order_number'),
                  displayOrderNumber,
                  titleColor: secondaryText,
                  valueColor: primaryText,
                ),
                _infoRow(
                  context,
                  context.tr.tr('tracking_number'),
                  tracking,
                  titleColor: secondaryText,
                  valueColor: primaryText,
                ),
                _infoRow(
                  context,
                  context.tr.tr('delivery_address'),
                  deliveryAddress,
                  titleColor: secondaryText,
                  valueColor: primaryText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.14 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                ...order.items.map(
                      (item) => _itemRow(
                    context,
                    item,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                _summaryRow(
                  context,
                  context.tr.tr('sub_total'),
                  'EGP ${order.subtotal.toStringAsFixed(2)}',
                  primaryText: primaryText,
                ),
                _summaryRow(
                  context,
                  context.tr.tr('shipping'),
                  'EGP ${order.shippingPrice.toStringAsFixed(2)}',
                  primaryText: primaryText,
                ),
                Divider(color: borderColor),
                _summaryRow(
                  context,
                  context.tr.tr('total'),
                  'EGP ${order.total.toStringAsFixed(2)}',
                  bold: true,
                  primaryText: primaryText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (order.status == 'delivered')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: secondaryText),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.tr.tr('return_home'),
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimaryPink,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: canRate
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RateProductScreen(order: order),
                        ),
                      );
                    }
                        : null,
                    child: Text(
                      context.tr.tr('rate'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.tr.tr('continue_shopping'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}