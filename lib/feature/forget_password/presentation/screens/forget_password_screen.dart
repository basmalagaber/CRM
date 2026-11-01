import 'package:erp_system/core/localization/app_strings.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/app_decorations.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';
import '../widgets/forget_password_form.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendCode() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  void _onBackToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
              ColorManager.pageGradientDarkTop,
              ColorManager.pageGradientDarkBottom,
            ]
                : const [
              ColorManager.pageGradientLightTop,
              ColorManager.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0, constraints.maxHeight - 48.h),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Directionality(
                        textDirection: context.dir,
                        child: Container(
                          padding: EdgeInsets.all(24.r),
                          decoration: AppDecorations.card(context, radius: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  width: 64.r,
                                  height: 64.r,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        ColorManager.primaryLightShade,
                                        ColorManager.primaryDarkShade,
                                      ],
                                    ),

                                  ),
                                  child: Icon(
                                    Icons.lock_reset_rounded,
                                    color: Colors.white,
                                    size: 30.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorManager.primaryColor
                                        .withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_open_rounded,
                                        color: ColorManager.primaryColor,
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        context.tr('استعادة الحساب'),
                                        style: TextStyle(
                                          fontFamily: FontConstants.fontFamily,
                                          fontSize: FontSize.s12.sp,
                                          fontWeight: FontWeightManager.bold,
                                          color: ColorManager.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                context.tr('استعادة كلمة المرور'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                context.tr('أدخل بريدك الإلكتروني لاستلام رمز التحقق'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: 24.h),
                              ForgetPasswordForm(
                                emailController: emailController,
                                isLoading: _isLoading,
                                onSendCode: _onSendCode,
                                onBackToLogin: _onBackToLogin,
                              ),
                              SizedBox(height: 16.h),
                              Center(
                                child: Text(
                                  context.tr('منصة إدارة الأعمال'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: FontSize.s12.sp,
                                    fontWeight: FontWeightManager.medium,
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
              );
            },
          ),
        ),
      ),
    );
  }
}