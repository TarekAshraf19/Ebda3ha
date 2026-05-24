import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../services/payment_service.dart';
import 'payment_failed_screen.dart';
import 'payment_success_screen.dart';
import 'payment_ui_helpers.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  bool isDebit = true;
  bool isLoading = false;
  bool showCardError = false;

  static const Color _textColor = Colors.black;
  static const Color _hintColor = Colors.black54;
  static const Color _errorColor = Colors.red;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  String _formattedPreviewNumber() {
    final clean = _cardNumberController.text.replaceAll(' ', '');
    if (clean.isEmpty) return '•••• •••• •••• ••••';

    final shown = clean.length >= 4 ? clean.substring(0, 4) : clean;
    return '$shown •••• •••• ••••';
  }

  InputDecoration _inputDecoration(String hint) {
    return paymentInputDecoration(hint).copyWith(
      hintStyle: const TextStyle(
        color: _hintColor,
        fontSize: 14,
      ),
    );
  }

  TextStyle get _labelStyle => const TextStyle(
    fontWeight: FontWeight.w700,
    color: _textColor,
  );

  TextStyle get _fieldStyle => const TextStyle(
    color: _textColor,
    fontSize: 16,
  );

  TextStyle get _helperStyle => const TextStyle(
    color: _textColor,
    fontSize: 12,
  );

  Future<void> _submit() async {
    setState(() {
      showCardError = false;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final isValid = await PaymentService.instance.mockValidateCard(
      cardNumber: _cardNumberController.text,
      holderName: _holderController.text,
      expiry: _expiryController.text,
      cvc: _cvcController.text,
    );

    if (!mounted) return;

    if (!isValid) {
      setState(() {
        isLoading = false;
        showCardError = true;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentFailedScreen(
            cardNumber: _cardNumberController.text,
            holderName: _holderController.text,
            expiryDate: _expiryController.text,
            cvc: _cvcController.text,
          ),
        ),
      );
      return;
    }

    final expiryParts = _expiryController.text.split('/');
    final expMonth = int.parse(expiryParts[0]);
    final expYear = 2000 + int.parse(expiryParts[1]);

    final brand =
    PaymentService.instance.detectBrand(_cardNumberController.text);

    await PaymentService.instance.addCard(
      cardNumber: _cardNumberController.text,
      holderName: _holderController.text,
      expMonth: expMonth,
      expYear: expYear,
      brand: brand,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentSuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return paymentShell(
      context: context,
      title: context.tr.tr('add_card'),
      child: Theme(
        data: Theme.of(context).copyWith(
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.all(_textColor),
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
            children: [
              const SizedBox(height: 2),
              _CardPreview(
                cardNumber: _formattedPreviewNumber(),
                holderName: _holderController.text.isEmpty
                    ? context.tr.tr('card_holder').toUpperCase()
                    : _holderController.text.toUpperCase(),
                expiryDate: _expiryController.text.isEmpty
                    ? '•• / ••'
                    : _expiryController.text,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: isDebit,
                    onChanged: (_) => setState(() => isDebit = false),
                  ),
                  Text(
                    context.tr.tr('card_type_credit'),
                    style: const TextStyle(color: _textColor),
                  ),
                  const SizedBox(width: 18),
                  Radio<bool>(
                    value: true,
                    groupValue: isDebit,
                    onChanged: (_) => setState(() => isDebit = true),
                  ),
                  Text(
                    context.tr.tr('debit_card'),
                    style: const TextStyle(color: _textColor),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr.tr('card_number'),
                style: _labelStyle,
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                style: _fieldStyle,
                cursorColor: _textColor,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: _inputDecoration('•••• •••• •••• ••••'),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final clean = (value ?? '').replaceAll(' ', '');
                  if (clean.isEmpty) return context.tr.tr('field_required');
                  if (clean.length < 16) return context.tr.tr('field_required');
                  if (!RegExp(r'^\d+$').hasMatch(clean)) {
                    return context.tr.tr('invalid_number');
                  }
                  return null;
                },
              ),
              if (showCardError)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    context.tr.tr('invalid_card'),
                    style: const TextStyle(
                      color: _errorColor,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    context.tr.tr('field_required'),
                    style: _helperStyle,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                context.tr.tr('card_holder'),
                style: _labelStyle,
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _holderController,
                style: _fieldStyle,
                cursorColor: _textColor,
                decoration: _inputDecoration(''),
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return context.tr.tr('field_required');
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  context.tr.tr('field_required'),
                  style: _helperStyle,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr.tr('expiry_date'),
                          style: _labelStyle,
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          style: _fieldStyle,
                          cursorColor: _textColor,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _ExpiryDateFormatter(),
                          ],
                          decoration: _inputDecoration('MM/YY'),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return context.tr.tr('field_required');
                            }
                            if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
                              return context.tr.tr('field_required');
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            context.tr.tr('field_required'),
                            style: _helperStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr.tr('cvc'),
                          style: _labelStyle,
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _cvcController,
                          keyboardType: TextInputType.number,
                          style: _fieldStyle,
                          cursorColor: _textColor,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: _inputDecoration(''),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return context.tr.tr('field_required');
                            }
                            if ((value ?? '').length < 3) {
                              return context.tr.tr('field_required');
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            context.tr.tr('field_required'),
                            style: _helperStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPrimaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: Text(
                    isLoading
                        ? context.tr.tr('loading')
                        : context.tr.tr('complete'),
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

class _CardPreview extends StatelessWidget {
  final String cardNumber;
  final String holderName;
  final String expiryDate;

  const _CardPreview({
    required this.cardNumber,
    required this.holderName,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A6A6A), Color(0xFF202020)],
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Colors.black26,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 24,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8C85C),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              cardNumber,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        expiryDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    holderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digits.length) {
        buffer.write(' ');
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}