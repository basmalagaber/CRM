import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/home/presentation/widgets/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';
import '../../../../core/routes_manager/routes.dart';
import '../../../../core/widgets/app_primary_button.dart';

enum UserRole { manager, employee, leader }

class LoginButtton extends StatefulWidget {
  const LoginButtton({
    super.key,
    this.emailController,
    this.passwordController,
  });

  final TextEditingController? emailController;
  final TextEditingController? passwordController;

  @override
  State<LoginButtton> createState() => _LoginButttonState();
}

class _LoginButttonState extends State<LoginButtton> {
  bool _rememberMe = false;
  String? _loginErrorMessage;

  // TODO: remove when the login API is connected.
  final Map<String, Map<String, dynamic>> _users = {
    'omar@gmail.com': {
      'password': '123',
      'role': UserRole.manager,
      'name': 'عمر',
    },
    'mohamed@gmail.com': {
      'password': '123',
      'role': UserRole.leader,
      'name': 'محمد',
    },
    'ahmed@gmail.com': {
      'password': '123',
      'role': UserRole.employee,
      'name': 'احمد',
    },
    'basmala@gmail.com': {
      'password': '123',
      'role': UserRole.employee,
      'name': 'بسملة',
    },
    'ali@gmail.com': {
      'password': '123',
      'role': UserRole.employee,
      'name': 'علي',
    },
    'amr@gmail.com': {
      'password': '123',
      'role': UserRole.employee,
      'name': 'عمرو',
    },
  };

  void _login() {
    FocusScope.of(context).unfocus();

    final email = (widget.emailController?.text ?? '').trim().toLowerCase();
    final password = widget.passwordController?.text ?? '';

    if (email.isEmpty || password.isEmpty) {
      setState(() => _loginErrorMessage = 'يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    final user = _users[email];

    if (user == null || user['password'] != password) {
      setState(() => _loginErrorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة');
      return;
    }

    setState(() => _loginErrorMessage = null);

    final UserRole role = user['role'];
    final String userName = user['name'];
    final String userInitial = userName.substring(0, 1);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          role: role,
          userName: userName,
          userInitial: userInitial,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.dir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loginErrorMessage != null) ...[
            SizedBox(height: 12.h),
            _buildErrorBox(context, _loginErrorMessage!),
          ],
          SizedBox(height: 16.h),
          _buildRememberAndForgotRow(context),
          SizedBox(height: 20.h),
          AppPrimaryButton(
            label: context.tr('تسجيل الدخول'),
            onPressed: _login,
          ),
          SizedBox(height: 16.h),
          _buildFooterText(context),
        ],
      ),
    );
  }

  Widget _buildErrorBox(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color errorColor = theme.colorScheme.error;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? errorColor.withOpacity(0.12) : ColorManager.errorBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: errorColor.withOpacity(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: errorColor, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('تعذر تسجيل الدخول'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: FontSize.s14.sp,
                    fontWeight: FontWeightManager.bold,
                    color: errorColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  context.tr(message),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: FontSize.s12.sp,
                    color: isDark ? errorColor : ColorManager.errorText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberAndForgotRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22.r,
                height: 22.r,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
                  activeColor: ColorManager.primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  side: BorderSide(
                    color: ColorManager.textMutedColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                context.tr('تذكرني'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeightManager.medium,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () {
            Navigator.pushNamed(context, Routes.forgetPasswordScreen);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
            child: Text(
              context.tr('نسيت كلمة المرور؟'),
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: FontSize.s14.sp,
                fontWeight: FontWeightManager.bold,
                color: ColorManager.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterText(BuildContext context) {
    return Center(
      child: Text(
        context.tr('منصة إدارة الأعمال'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: FontSize.s12.sp,
          fontWeight: FontWeightManager.medium,
        ),
      ),
    );
  }
}