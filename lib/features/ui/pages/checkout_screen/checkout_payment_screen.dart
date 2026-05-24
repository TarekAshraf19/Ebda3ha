import 'package:flutter/material.dart';
import 'package:ebad3a_ecommerce/services/cart_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../models/cart_item.dart';
import '../../../../models/payment_model.dart';
import '../../../../services/checkout_order_service.dart';
import '../../../../services/payment_service.dart';
import '../payment_screen/add_card_screen.dart';
import 'checkout_success_screen.dart';

class CheckoutPaymentScreen extends StatefulWidget {
  final double cartSubtotal;
  final double shippingPrice;
  final Map<String, dynamic> shippingAddress;
  final List<CartItem> cartItems;

  const CheckoutPaymentScreen({
    super.key,
    required this.cartSubtotal,
    required this.shippingPrice,
    required this.shippingAddress,
    required this.cartItems,
  });

  @override
  State<CheckoutPaymentScreen> createState() =>
      _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  String selectedMethod = 'cash';
  bool agreeTerms = true;
  bool loading = false;
  PaymentCardModel? selectedCard;

  Future<void> _placeOrder() async {
    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.tr('agree_terms_error'))),
      );
      return;
    }

    if (selectedMethod == 'card' && selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.tr('choose_card_first'))),
      );
      return;
    }

    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.tr('cart_empty'))),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final orderItems = widget.cartItems.map((item) {
        return {
          'cartItemId': item.cartItemId,
          'productId': item.productId,
          'title': item.name,
          'imageUrl': item.image,
          'price': item.price,
          'quantity': item.quantity,
          'size': item.size,
          'color': item.color,
          'total': item.total,
        };
      }).toList();

      await CheckoutOrderService.instance.createOrder(
        items: orderItems,
        shippingAddress: widget.shippingAddress,
        paymentMethod: selectedMethod,
        selectedCard: selectedMethod == 'card'
            ? {
          'brand': selectedCard!.brand,
          'last4': selectedCard!.last4,
          'holderName': selectedCard!.holderName,
          'expMonth': selectedCard!.expMonth,
          'expYear': selectedCard!.expYear,
        }
            : null,
        subtotal: widget.cartSubtotal,
        shippingPrice: widget.shippingPrice,
      );

      for (final item in widget.cartItems) {
        await CartService.instance.removeItem(item.cartItemId);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CheckoutSuccessScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${context.tr.tr('error')}: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg =
    isDark ? AppColors.darkScaffold : const Color(0xFFF8F8F8);

    final cardBg =
    isDark ? AppColors.darkCard : AppColors.whiteColor;

    final primaryText =
    isDark ? AppColors.darkTextPrimary : AppColors.kPrimaryPink;

    final borderColor =
    isDark ? AppColors.darkBorder : const Color(0xFFE8E8EE);

    final productPrice = widget.cartSubtotal;
    final shipping = widget.shippingPrice;
    final total = productPrice + shipping;

    final termsColor = isDark ? AppColors.kPrimaryPink : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildStepIndicator(currentStep: 2),
            const SizedBox(height: 18),
            Text(
              context.tr.tr('step_2'),
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr.tr('payment'),
              style: TextStyle(
                color: primaryText,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: _payMethodTile(
                    icon: Icons.payments_outlined,
                    label: context.tr.tr('cash'),
                    value: 'cash',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _payMethodTile(
                    icon: Icons.credit_card,
                    label: context.tr.tr('credit_card'),
                    value: 'card',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (selectedMethod == 'card') ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr.tr('choose_card'),
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddCardScreen(),
                        ),
                      );
                    },
                    child: Text(
                      context.tr.tr('add_new'),
                      style: const TextStyle(
                        color: Color(0xFF145CFF),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<PaymentCardModel>>(
                stream: PaymentService.instance.cardsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final cards = snapshot.data!;

                  if (cards.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        context.tr.tr('no_saved_cards'),
                        style: TextStyle(color: primaryText),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        return _cardView(cards[index]);
                      },
                    ),
                  );
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  context.tr.tr('cash_on_delivery_selected'),
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              context.tr.tr('or_checkout_with'),
              style: TextStyle(
                color: primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _miniPayBox('PayPal'),
                _miniPayBox('VISA'),
                _miniPayBox('Master'),
                _miniPayBox('Alipay'),
                _miniPayBox('AMEX'),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _summaryRow(
                    context.tr.tr('product_price'),
                    "EGP ${productPrice.toStringAsFixed(2)}",
                    primaryText,
                  ),
                  Divider(color: borderColor, height: 28),
                  _summaryRow(
                    context.tr.tr('shipping'),
                    "EGP ${shipping.toStringAsFixed(2)}",
                    primaryText,
                  ),
                  Divider(color: borderColor, height: 28),
                  _summaryRow(
                    context.tr.tr('subtotal'),
                    "EGP ${total.toStringAsFixed(2)}",
                    primaryText,
                    isBold: true,
                    valueSize: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: agreeTerms,
                    activeColor: const Color(0xFF67C56F),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (v) => setState(() => agreeTerms = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr.tr('agree_terms'),
                    style: TextStyle(
                      color: termsColor,
                      fontSize: 15,
                      fontWeight: isDark ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimaryPink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: loading ? null : _placeOrder,
                child: Text(
                  loading
                      ? context.tr.tr('loading')
                      : context.tr.tr('place_order'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppColors.kPrimaryPink,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Center(
            child: Text(
              context.tr.tr('checkout_title'),
              style: const TextStyle(
                color: AppColors.kPrimaryPink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({required int currentStep}) {
    Color active = AppColors.kPrimaryPink;
    Color inactive = Colors.grey.shade300;

    return Row(
      children: [
        _stepIcon(
          icon: Icons.location_on,
          active: currentStep >= 1,
          activeColor: active,
          inactiveColor: inactive,
        ),
        _stepLine(),
        _stepIcon(
          icon: Icons.credit_card,
          active: currentStep >= 2,
          activeColor: active,
          inactiveColor: inactive,
        ),
        _stepLine(),
        _stepCircle(inactive),
      ],
    );
  }

  Widget _stepIcon({
    required IconData icon,
    required bool active,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return SizedBox(
      width: 26,
      child: Icon(
        icon,
        size: 22,
        color: active ? activeColor : inactiveColor,
      ),
    );
  }

  Widget _stepCircle(Color color) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Row(
        children: List.generate(
          7,
              (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _payMethodTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    final selected = selectedMethod == value;

    return GestureDetector(
      onTap: () => setState(() => selectedMethod = value),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.kPrimaryPink
              : (isDark ? AppColors.darkCard : AppColors.whiteColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.kPrimaryPink,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.kPrimaryPink,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
      String title,
      String value,
      Color primaryText, {
        bool isBold = false,
        double valueSize = 16,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.kPrimaryPink,
            fontSize: valueSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _miniPayBox(String text) {
    return Container(
      width: 50,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E6EC)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3A3A46),
        ),
      ),
    );
  }

  Widget _cardView(PaymentCardModel card) {
    final isSelected = selectedCard?.id == card.id;

    return GestureDetector(
      onTap: () => setState(() => selectedCard = card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 328,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isSelected
                ? const [
              Color(0xFF4AA4F6),
              Color(0xFF1599C8),
            ]
                : const [
              Color(0xFF9BB7D4),
              Color(0xFF6E95B6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: Opacity(
                opacity: .08,
                child: Icon(
                  Icons.public,
                  size: 140,
                  color: Colors.white,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    card.brand.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "**** **** **** ${card.last4}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _cardInfo(
                        context.tr.tr('cardholder_name'),
                        card.holderName,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _cardInfo(
                      context.tr.tr('valid_thru'),
                      "${card.expMonth.toString().padLeft(2, '0')}/${card.expYear.toString().substring(card.expYear.toString().length - 2)}",
                      alignEnd: true,
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

  Widget _cardInfo(String title, String value, {bool alignEnd = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(.85),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: .4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}