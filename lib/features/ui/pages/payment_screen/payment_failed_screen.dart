import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import 'payment_ui_helpers.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String cardNumber;
  final String holderName;
  final String expiryDate;
  final String cvc;

  const PaymentFailedScreen({
    super.key,
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
    required this.cvc,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;

    final secondaryText =
    isDark ? AppColors.darkTextSecondary : Colors.grey;

    return paymentShell(
      context: context,
      title: context.tr.tr('add_card'),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 120),
            children: [
              const SizedBox(height: 6),

              /// Card preview
              Container(
                height: 135,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF111111), Color(0xFF3D3D3D)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        cardNumber.isEmpty
                            ? '5523 1234 5678 1234'
                            : cardNumber,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            holderName.isEmpty
                                ? 'CARD HOLDER'
                                : holderName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                context.tr.tr('expiry_date'),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 8,
                                ),
                              ),
                              Text(
                                expiryDate.isEmpty ? '--/--' : expiryDate,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// Card type
              Row(
                children: [
                  const Icon(Icons.radio_button_checked, size: 22),
                  const SizedBox(width: 8),
                  Text(context.tr.tr('debit_card')),
                  const SizedBox(width: 24),
                  const Icon(Icons.radio_button_unchecked, size: 22),
                  const SizedBox(width: 8),
                  Text(context.tr.tr('credit_card')),
                ],
              ),

              const SizedBox(height: 14),

              /// Card number
              Text(context.tr.tr('card_number'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),

              TextField(
                controller: TextEditingController(text: cardNumber),
                style: TextStyle(color: primaryText),
                decoration: paymentInputDecoration('').copyWith(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  context.tr.tr('invalid_card'),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

              const SizedBox(height: 14),

              /// Holder
              Text(context.tr.tr('card_holder'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),

              TextField(
                controller: TextEditingController(text: holderName),
                style: TextStyle(color: primaryText),
                decoration: paymentInputDecoration(''),
              ),

              const SizedBox(height: 14),

              /// Expiry + CVC
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr.tr('expiry_date'),
                            style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: TextEditingController(text: expiryDate),
                          style: TextStyle(color: primaryText),
                          decoration: paymentInputDecoration(''),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr.tr('cvc'),
                            style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: TextEditingController(text: cvc),
                          style: TextStyle(color: primaryText),
                          decoration: paymentInputDecoration(''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// Error bottom sheet
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.redColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Text(
                        context.tr.tr('payment_failed_message'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}