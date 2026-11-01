import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';

class LoginForm extends StatefulWidget {
  LoginForm({
    super.key,
    TextEditingController? emailController,
    TextEditingController? passwordController,
  })  : emailController = emailController ?? TextEditingController(),
        passwordController = passwordController ?? TextEditingController();

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final TextAlign inputAlign =
    context.isArabic ? TextAlign.right : TextAlign.left;

    final TextStyle? inputStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: FontSize.s14.sp,
      fontWeight: FontWeightManager.medium,
      color: theme.textTheme.titleLarge?.color,
      height: 1.3,
    );

    return Directionality(
      textDirection: context.dir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel(context, 'البريد الإلكتروني'),
          SizedBox(height: 8.h),
          TextField(
            controller: widget.emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.ltr,
            textAlign: inputAlign,
            style: inputStyle,
            decoration: InputDecoration(
              hintText: 'name@company.com',
              hintTextDirection: TextDirection.ltr,
              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20.sp),
            ),
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          SizedBox(height: 16.h),
          _buildLabel(context, 'كلمة المرور'),
          SizedBox(height: 8.h),
          TextField(
            controller: widget.passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            textAlign: inputAlign,
            style: inputStyle,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintTextDirection: TextDirection.ltr,
              prefixIcon: Icon(Icons.lock_outline_rounded, size: 20.sp),
              suffixIcon: IconButton(
                splashRadius: 20,
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Text(
      context.tr(text),
      style: theme.textTheme.labelLarge?.copyWith(
        fontSize: FontSize.s14.sp,
        fontWeight: FontWeightManager.semiBold,
        color: theme.textTheme.titleLarge?.color,
      ),
    );
  }
}