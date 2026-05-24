import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../models/payment_model.dart';
import '../../../../services/payment_service.dart';
import 'add_card_screen.dart';
import 'payment_ui_helpers.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.blackColor;

    return paymentShell(
      context: context,
      title: context.tr.tr('payment_details'),
      child: StreamBuilder<List<PaymentCardModel>>(
        stream: PaymentService.instance.cardsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${context.tr.tr('error')}: ${snapshot.error}',
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

          final cards = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
            child: Column(
              children: [
                const SizedBox(height: 10),
                if (cards.isEmpty) ...[
                  const _StackedMockCards(),
                  const SizedBox(height: 18),
                  Text(
                    context.tr.tr('no_saved_cards'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _AddCardButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddCardScreen(),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  SizedBox(
                    height: 264,
                    child: ListView.separated(
                      itemCount: cards.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return _SavedCardView(card: card);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _AddCardButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddCardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddCardButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCardButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.kPrimaryPink,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onTap,
        child: Text(
          context.tr.tr('add_card'),
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StackedMockCards extends StatelessWidget {
  const _StackedMockCards();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        alignment: Alignment.topCenter,
        children: const [
          Positioned(
            top: 0,
            child: _MiniCard(
              color: Color(0xFFA96A6A),
              brandText: 'VISA',
            ),
          ),
          Positioned(
            top: 26,
            child: _MiniCard(
              color: Color(0xFFC49A42),
              brandText: 'VISA',
            ),
          ),
          Positioned(
            top: 52,
            child: _MiniCard(
              color: Color(0xFF9B58E8),
              brandText: '',
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final Color color;
  final String brandText;

  const _MiniCard({
    required this.color,
    required this.brandText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 130,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 5),
            color: Colors.black26,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (brandText.isNotEmpty)
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  brandText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            const Spacer(),
            const Text(
              '•••• •••• •••• 4765',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    context.tr.tr('card_name'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr.tr('expiry_date'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                      ),
                    ),
                    const Text(
                      '11 / 23',
                      style: TextStyle(
                        color: Colors.white,
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
    );
  }
}

class _SavedCardView extends StatelessWidget {
  final PaymentCardModel card;

  const _SavedCardView({required this.card});

  @override
  Widget build(BuildContext context) {
    final isVisa = card.brand.toLowerCase() == 'visa';

    return GestureDetector(
      onTap: () async {
        await PaymentService.instance.setDefaultCard(card.id);
      },
      child: Container(
        width: double.infinity,
        height: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isVisa
                ? const [Color(0xFF6E52F5), Color(0xFFA45AE8)]
                : const [Color(0xFF333333), Color(0xFF6A6A6A)],
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, 6),
              color: Colors.black26,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      card.brand.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '•••• •••• •••• ${card.last4}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25), // زوّد أو قلّل الرقم حسب ما تحتاج
                          child: Text(
                            card.holderName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr.tr('expiry_date'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            '${card.expMonth.toString().padLeft(2, '0')}/${(card.expYear % 100).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
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
            if (card.isDefault)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.tr.tr('default_card'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 2,
              right: 2,
              child: IconButton(
                onPressed: () async {
                  await PaymentService.instance.deleteCard(card.id);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}