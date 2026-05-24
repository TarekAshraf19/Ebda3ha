import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../models/cart_item.dart';
import '../../../../services/checkout_order_service.dart';
import 'checkout_payment_screen.dart';

class CheckoutShippingScreen extends StatefulWidget {
  final double cartSubtotal;
  final List<CartItem> cartItems;

  const CheckoutShippingScreen({
    super.key,
    required this.cartSubtotal,
    required this.cartItems,
  });

  @override
  State<CheckoutShippingScreen> createState() =>
      _CheckoutShippingScreenState();
}

class _CheckoutShippingScreenState extends State<CheckoutShippingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _country = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _coupon = TextEditingController();

  bool _copyAddress = false;
  bool _loading = false;

  String selectedShippingMethod = 'home';
  double selectedShippingPrice = 50.0;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _country.dispose();
    _street.dispose();
    _city.dispose();
    _phone.dispose();
    _coupon.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required String label,
    required Color borderColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 16,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.kPrimaryPink, width: 1.4),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await CheckoutOrderService.instance.saveShippingAddress(
      firstName: _firstName.text,
      lastName: _lastName.text,
      country: _country.text,
      streetName: _street.text,
      city: _city.text,
      phoneNumber: _phone.text,
      shippingMethod: selectedShippingMethod,
      shippingPrice: selectedShippingPrice,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPaymentScreen(
          cartSubtotal: widget.cartSubtotal,
          shippingPrice: selectedShippingPrice,
          cartItems: widget.cartItems,
          shippingAddress: {
            'firstName': _firstName.text.trim(),
            'lastName': _lastName.text.trim(),
            'country': _country.text.trim(),
            'streetName': _street.text.trim(),
            'city': _city.text.trim(),
            'phoneNumber': _phone.text.trim(),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg =
    isDark ? AppColors.darkScaffold : const Color(0xFFF8F8F8);

    final titleColor =
    isDark ? AppColors.darkTextPrimary : AppColors.kPrimaryPink;

    final borderColor =
    isDark ? AppColors.darkBorder : const Color(0xFFE5E5EA);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildStepIndicator(currentStep: 1),
              const SizedBox(height: 18),
              Text(
                context.tr.tr('step_1'),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr.tr('shipping'),
                style: TextStyle(
                  color: titleColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              _field(
                controller: _firstName,
                borderColor: borderColor,
                label: context.tr.tr('first_name'),
              ),
              const SizedBox(height: 14),

              _field(
                controller: _lastName,
                borderColor: borderColor,
                label: context.tr.tr('last_name'),
              ),
              const SizedBox(height: 14),

              _field(
                controller: _country,
                borderColor: borderColor,
                label: context.tr.tr('country'),
              ),
              const SizedBox(height: 14),

              _field(
                controller: _street,
                borderColor: borderColor,
                label: context.tr.tr('street'),
              ),
              const SizedBox(height: 14),

              _field(
                controller: _city,
                borderColor: borderColor,
                label: context.tr.tr('city'),
              ),
              const SizedBox(height: 14),

              _field(
                controller: _phone,
                borderColor: borderColor,
                label: context.tr.tr('phone'),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 34),

              Text(
                context.tr.tr('shipping_method'),
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              _shippingMethodCard(
                title: 'EGP 50',
                subtitle: context.tr.tr('home_delivery'),
                desc: context.tr.tr('home_delivery_desc'),
                value: 'home',
                price: 50,
                borderColor: borderColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _shippingMethodCard(
                title: 'EGP 100',
                subtitle: context.tr.tr('fast_delivery'),
                desc: context.tr.tr('fast_delivery_desc'),
                value: 'fast',
                price: 100,
                borderColor: borderColor,
                isDark: isDark,
              ),

              const SizedBox(height: 28),

              Text(
                context.tr.tr('coupon_code'),
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : const Color(0xFFF2F2F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _coupon,
                        decoration: InputDecoration(
                          hintText: context.tr.tr('coupon_hint'),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      context.tr.tr('validate'),
                      style: const TextStyle(
                        color: Color(0xFF4D9B8A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                context.tr.tr('billing_address'),
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _copyAddress,
                      activeColor: AppColors.kPrimaryPink,
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) => setState(() => _copyAddress = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr.tr('billing_copy_address'),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFF5B5B66),
                        fontSize: 15,
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
                    elevation: 0,
                    backgroundColor: AppColors.kPrimaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _loading ? null : _continue,
                  child: Text(
                    _loading
                        ? context.tr.tr('loading')
                        : context.tr.tr('continue_payment'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
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
          active: false,
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

  Widget _field({
    required TextEditingController controller,
    required Color borderColor,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _dec(
        label: label,
        borderColor: borderColor,
      ),
      validator: (v) =>
      (v == null || v.trim().isEmpty) ? context.tr.tr('field_required') : null,
    );
  }

  Widget _shippingMethodCard({
    required String title,
    required String subtitle,
    required String desc,
    required String value,
    required double price,
    required Color borderColor,
    required bool isDark,
  }) {
    final isSelected = selectedShippingMethod == value;

    final titleColor = isDark ? Colors.white : const Color(0xFF2C2C34);
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade700;
    final descColor = isDark ? Colors.white54 : Colors.grey.shade400;

    return InkWell(
      onTap: () {
        setState(() {
          selectedShippingMethod = value;
          selectedShippingPrice = price;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1957F2)
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1957F2),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 2),
                    child: Text(
                      desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: descColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}