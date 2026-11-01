import 'package:erp_system/core/localization/app_strings.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/app_decorations.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';
import '../widgets/login_buttton.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                                    Icons.business_center_rounded,
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
                                        Icons.shield_outlined,
                                        color: ColorManager.primaryColor,
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        context.tr('دخول آمن'),
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
                                context.tr('تسجيل الدخول'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                context.tr('أدخل بياناتك للوصول إلى مساحة العمل'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: 24.h),
                              LoginForm(
                                emailController: emailController,
                                passwordController: passwordController,
                              ),
                              SizedBox(height: 4.h),
                              LoginButtton(
                                emailController: emailController,
                                passwordController: passwordController,
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