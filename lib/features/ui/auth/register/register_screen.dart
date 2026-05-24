import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_ebda3a.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'package:ebad3a_ecommerce/features/ui/auth/Authentication/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;


  double enImageWidth = 0.55.sw;
  double enImageHeight = 80.h;
  EdgeInsets enImagePadding = EdgeInsets.only(
    top: 50.h,
    bottom: 30.h,
  );


  double arImageWidth = 0.99.sw;
  double arImageHeight = 70.h;
  EdgeInsets arImagePadding = EdgeInsets.only(
    top: 40.h,
    bottom: 30.h,
  );

  BoxFit imageFit = BoxFit.contain;

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    mailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      final String? res = await AuthService().registerUser(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        email: mailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (res == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.tr('register_success')),
            backgroundColor: AppColors.greenColor,
          ),
        );
        Navigator.pushReplacementNamed(context, AppEbda3ha.loginEbda3ha);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res ?? context.tr.tr('register_failed')),
            backgroundColor: AppColors.redColor,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${context.tr.tr('error')}: ${e.toString()}"),
          backgroundColor: AppColors.redColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor =
    isDark ? AppColors.darkScaffold : AppColors.kPrimaryPink;

    final Color textColor =
    isDark ? AppColors.darkTextPrimary : AppColors.whiteColor;

    final Color hintColor =
    isDark ? AppColors.darkHintText : AppColors.lightHintText;

    final Color fieldColor =
    isDark ? AppColors.darkInputFill : AppColors.whiteColor;

    final Color buttonBg =
    isDark ? AppColors.kPrimaryPink : AppColors.whiteColor;

    final Color buttonText =
    isDark ? AppColors.whiteColor : AppColors.kPrimaryPink;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: isArabic ? arImagePadding : enImagePadding,
                child: Center(
                  child: Image.asset(
                    isArabic
                        ? AppAssets.appBarLeadingArabic
                        : AppAssets.appBarLeading,
                    width: isArabic ? arImageWidth : enImageWidth,
                    height: isArabic ? arImageHeight : enImageHeight,
                    fit: imageFit,
                  ),
                ),
              ),

              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLabel(context.tr.tr('full_name'), textColor),
                    SizedBox(height: 10.h),
                    _buildField(
                      controller: fullNameController,
                      hint: context.tr.tr('enter_full_name'),
                      hintColor: hintColor,
                      fillColor: fieldColor,
                      validator: AppValidators.validateFullName,
                    ),

                    SizedBox(height: 16.h),

                    _buildLabel(context.tr.tr('phone'), textColor),
                    SizedBox(height: 10.h),
                    _buildField(
                      controller: phoneController,
                      hint: context.tr.tr('enter_phone'),
                      hintColor: hintColor,
                      fillColor: fieldColor,
                      validator: AppValidators.validatePhoneNumber,
                    ),

                    SizedBox(height: 16.h),

                    _buildLabel(context.tr.tr('email_label'), textColor),
                    SizedBox(height: 10.h),
                    _buildField(
                      controller: mailController,
                      hint: context.tr.tr('enter_your_email'),
                      hintColor: hintColor,
                      fillColor: fieldColor,
                      validator: AppValidators.validateEmail,
                    ),

                    SizedBox(height: 16.h),

                    _buildLabel(context.tr.tr('password_label'), textColor),
                    SizedBox(height: 10.h),
                    _buildField(
                      controller: passwordController,
                      hint: context.tr.tr('enter_your_password'),
                      hintColor: hintColor,
                      fillColor: fieldColor,
                      isPassword: true,
                      validator: AppValidators.validatePassword,
                    ),

                    SizedBox(height: 16.h),

                    _buildLabel(context.tr.tr('confirm_password'), textColor),
                    SizedBox(height: 10.h),
                    _buildField(
                      controller: confirmPasswordController,
                      hint: context.tr.tr('confirm_password_hint'),
                      hintColor: hintColor,
                      fillColor: fieldColor,
                      isPassword: true,
                      validator: (val) =>
                          AppValidators.validateConfirmPassword(
                            val,
                            passwordController.text.trim(),
                          ),
                    ),

                    SizedBox(height: 32.h),

                    isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.kPrimaryPink,
                      ),
                    )
                        : CustomElevatedButton(
                      backgroundColor: buttonBg,
                      textStyle: AppStyles.semi20Primary.copyWith(
                        color: buttonText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      text: context.tr.tr('sign_up'),
                      onPressed: register,
                    ),

                    SizedBox(height: 26.h),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppEbda3ha.loginEbda3ha,
                        );
                      },
                      child: Text(
                        context.tr.tr('already_have_account_login'),
                        textAlign: TextAlign.center,
                        style: AppStyles.medium18White.copyWith(
                          color: textColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: AppStyles.medium18White.copyWith(
        color: color,
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required Color hintColor,
    required Color fillColor,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return CustomTextFormField(
      isPassword: isPassword,
      keyboardType:
      isPassword ? TextInputType.visiblePassword : TextInputType.text,
      isObscureText: isPassword,
      hintText: hint,
      hintStyle: AppStyles.light18HintText.copyWith(
        color: hintColor,
        fontSize: 15.sp,
      ),
      filledColor: fillColor,
      controller: controller,
      validator: validator,
    );
  }
}