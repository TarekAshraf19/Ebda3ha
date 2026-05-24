import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import 'payment_details_screen.dart';
import 'payment_ui_helpers.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return paymentShell(
      context: context,
      title: context.tr.tr('payment_validation'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.kPrimaryPink,
            borderRadius: BorderRadius.circular(34),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.check,
                  size: 54,
                  color: AppColors.kPrimaryPink,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr.tr('thank_you'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr.tr('payment_done_successfully'),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 170,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentDetailsScreen(),
                      ),
                          (route) => route.isFirst,
                    );
                  },
                  child: Text(
                    context.tr.tr('home'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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