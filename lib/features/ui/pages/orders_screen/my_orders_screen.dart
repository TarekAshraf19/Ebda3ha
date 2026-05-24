import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../models/order_model.dart';
import '../../../../services/orders_service.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> _statuses = ['pending', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _titleFromStatus(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return context.tr.tr('pending_upper');
      case 'delivered':
        return context.tr.tr('delivered_upper');
      case 'cancelled':
        return context.tr.tr('cancelled_upper');
      default:
        return status.toUpperCase();
    }
  }

  String _tabTitle(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return context.tr.tr('pending');
      case 'delivered':
        return context.tr.tr('delivered');
      case 'cancelled':
        return context.tr.tr('cancelled');
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFE67E22);
      case 'delivered':
        return const Color(0xFF00A86B);
      case 'cancelled':
        return AppColors.redColor;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int _totalQuantity(OrderModel order) {
    return order.items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  Widget _buildOrderCard(OrderModel order) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg =
    isDark ? AppColors.darkCard : AppColors.whiteColor;
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;
    final Color secondaryText =
    isDark ? AppColors.darkTextSecondary : const Color(0xFF7D8597);
    final Color borderColor =
    isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final tracking = order.trackingNumber.isEmpty
        ? context.tr.tr('not_assigned_yet')
        : order.trackingNumber;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.16 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.tr.tr('order_number')} #${order.orderId.substring(0, 4).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                  ),
                ),
              ),
              Text(
                _formatDate(order.createdAt),
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${context.tr.tr('tracking_number')}: ',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Text(
                  tracking,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${context.tr.tr('quantity')}: ${_totalQuantity(order)}',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${context.tr.tr('subtotal')}: EGP ${order.total.toStringAsFixed(0)}',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _titleFromStatus(context, order.status),
                style: TextStyle(
                  color: _statusColor(order.status),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 110,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPrimaryPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                  child: Text(
                    context.tr.tr('details'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(String status) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;
    final Color emptyColor =
    isDark ? AppColors.darkTextSecondary : Colors.grey;

    return StreamBuilder<List<OrderModel>>(
      stream: OrdersService.instance.ordersStreamByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '${context.tr.tr('error')}: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.kPrimaryPink,
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Text(
              _emptyStateTitle(context, status),
              style: TextStyle(
                color: emptyColor,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
        );
      },
    );
  }

  String _emptyStateTitle(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return context.tr.tr('no_pending_orders');
      case 'delivered':
        return context.tr.tr('no_delivered_orders');
      case 'cancelled':
        return context.tr.tr('no_cancelled_orders');
      default:
        return context.tr.tr('no_orders');
    }
  }

  Widget _buildTopTabs() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color unselectedColor =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.kPrimaryPink,
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: unselectedColor,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: context.tr.tr('pending')),
          Tab(text: context.tr.tr('delivered')),
          Tab(text: context.tr.tr('cancelled')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.darkScaffold : AppColors.kPageBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              context.tr.tr('my_orders'),
              style: const TextStyle(
                color: AppColors.kPrimaryPink,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTopTabs(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _statuses.map(_buildOrdersTab).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}