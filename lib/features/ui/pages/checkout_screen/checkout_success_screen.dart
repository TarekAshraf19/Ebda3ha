import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  Widget _stepHeader(bool isDark) {
    final Color dividerColor =
    isDark ? AppColors.darkBorder : Colors.grey.shade300;

    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.kPrimaryPink, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1.2,
            color: dividerColor,
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.credit_card, color: AppColors.kPrimaryPink, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1.2,
            color: dividerColor,
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.check_circle, color: AppColors.kPrimaryPink, size: 22),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color scaffoldBg =
    isDark ? AppColors.darkScaffold : AppColors.kPageBg;
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.kPrimaryPink;
    final Color secondaryText =
    isDark ? AppColors.darkTextSecondary : AppColors.kPrimaryPink;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  context.tr.tr('checkout'),
                  style: const TextStyle(
                    color: AppColors.kPrimaryPink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _stepHeader(isDark),
              const SizedBox(height: 34),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.tr.tr('order_completed'),
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.shopping_bag_outlined,
                size: 110,
                color: AppColors.kPrimaryPink.withOpacity(.95),
              ),
              const SizedBox(height: 18),
              Text(
                context.tr.tr('thank_you_purchase'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 18,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPrimaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    context.tr.tr('continue_shopping'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
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