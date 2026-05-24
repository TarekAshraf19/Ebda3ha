import 'package:flutter/material.dart';
import 'package:ebad3a_ecommerce/features/ui/auth/Authentication/auth_service.dart';
import 'package:ebad3a_ecommerce/core/utils/app_colors.dart';
import 'package:ebad3a_ecommerce/core/localization/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    final String? res = await _authService.sendPasswordReset(
      email: emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (res == "Password reset email sent") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr.tr('reset_email_sent_success'),
          ),
          backgroundColor: AppColors.greenColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res ?? context.tr.tr('error_generic'),
          ),
          backgroundColor: AppColors.redColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryTextColor =
    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color secondaryTextColor =
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color cardColor =
    isDark ? AppColors.darkCard : AppColors.lightCard;
    final Color inputFillColor =
    isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final Color borderColor =
    isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final Color hintColor =
    isDark ? AppColors.darkHintText : AppColors.lightHintText;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.tr('forgot_password')),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.20 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        size: 52,
                        color: AppColors.kPrimaryPink,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr.tr('forgot_password'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr.tr('forgot_password_description'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          hintText: context.tr.tr('enter_your_email'),
                          hintStyle: TextStyle(color: hintColor),
                          filled: true,
                          fillColor: inputFillColor,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.kPrimaryPink,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.kPrimaryPink,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.redColor,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.redColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return context.tr.tr('email_required');
                          }
                          if (!val.contains('@')) {
                            return context.tr.tr('enter_valid_email');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.kPrimaryPink,
                        ),
                      )
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kPrimaryPink,
                          foregroundColor: AppColors.whiteColor,
                          padding:
                          const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: resetPassword,
                        child: Text(
                          context.tr.tr('send_reset_email'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}