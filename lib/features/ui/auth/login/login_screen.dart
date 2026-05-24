import 'package:ebad3a_ecommerce/features/ui/auth/Authentication/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_ebda3a.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ForgotPasswordScreen/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isPasswordHidden = true;


  double enImageWidth = 0.55.sw;
  double enImageHeight = 95.h;
  EdgeInsets enImagePadding = EdgeInsets.only(
    top: 70.h,
    bottom: 50.h,
  );

  // ==============================
  // Arabic Image Control
  // ==============================
  double arImageWidth = 0.99.sw;
  double arImageHeight = 95.h;
  EdgeInsets arImagePadding = EdgeInsets.only(
    top: 70.h,
    bottom: 50.h,
  );

  BoxFit imageFit = BoxFit.contain;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    final String? res = await AuthService().loginUser(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res == "success") {
      Navigator.pushReplacementNamed(context, AppEbda3ha.homeEbda3ha);
      if (kDebugMode) {
        print("Login Successfully");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res ?? context.tr.tr('login_failed')),
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

    final Color secondaryTextColor =
    isDark ? AppColors.darkTextSecondary : AppColors.whiteColor;

    final Color fieldFillColor =
    isDark ? AppColors.darkInputFill : AppColors.whiteColor;

    final Color hintColor =
    isDark ? AppColors.darkHintText : AppColors.lightHintText;

    final Color buttonBgColor =
    isDark ? AppColors.kPrimaryPink : AppColors.whiteColor;

    final Color buttonTextColor =
    isDark ? AppColors.whiteColor : AppColors.kPrimaryPink;

    final Color loadingColor = AppColors.whiteColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
              AutoSizeText(
                context.tr.tr('welcome_back_to_ebda3ha'),
                style: AppStyles.semi24White.copyWith(
                  color: textColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
                maxLines: 1,
              ),

              SizedBox(height: 6.h),

              AutoSizeText(
                context.tr.tr('please_sign_in_with_your_email'),
                style: AppStyles.light16White.copyWith(
                  color: secondaryTextColor.withOpacity(0.95),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
                maxLines: 2,
              ),

              SizedBox(height: 38.h),

              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr.tr('email_label'),
                      style: AppStyles.medium18White.copyWith(
                        color: textColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    CustomTextFormField(
                      isPassword: false,
                      keyboardType: TextInputType.emailAddress,
                      isObscureText: false,
                      hintText: context.tr.tr('enter_your_email'),
                      hintStyle: AppStyles.light18HintText.copyWith(
                        color: hintColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      filledColor: fieldFillColor,
                      controller: emailController,
                      validator: AppValidators.validateEmail,
                    ),

                    SizedBox(height: 18.h),

                    Text(
                      context.tr.tr('password_label'),
                      style: AppStyles.medium18White.copyWith(
                        color: textColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    CustomTextFormField(
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                      isObscureText: isPasswordHidden,
                      hintText: context.tr.tr('enter_your_password'),
                      hintStyle: AppStyles.light18HintText.copyWith(
                        color: hintColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      filledColor: fieldFillColor,
                      controller: passwordController,
                      validator: AppValidators.validatePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade500,
                          size: 22.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Text(
                            context.tr.tr('forgot_password'),
                            style: AppStyles.regular18White.copyWith(
                              color: textColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 50.h),

                    isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: loadingColor,
                      ),
                    )
                        : CustomElevatedButton(
                      backgroundColor: buttonBgColor,
                      textStyle: AppStyles.semi20Primary.copyWith(
                        color: buttonTextColor,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      text: context.tr.tr('login'),
                      onPressed: login,
                    ),

                    SizedBox(height: 28.h),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppEbda3ha.registerEbda3ha,
                        );
                      },
                      child: Text(
                        context.tr.tr('dont_have_account_create_account'),
                        style: AppStyles.medium18White.copyWith(
                          color: textColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}