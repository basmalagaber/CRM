import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';
import '../../../../core/widgets/app_primary_button.dart';

class ForgetPasswordForm extends StatelessWidget {
  const ForgetPasswordForm({
    super.key,
    required this.emailController,
    required this.onSendCode,
    this.onBackToLogin,
    this.isLoading = false,
  });

  final TextEditingController emailController;
  final VoidCallback onSendCode;
  final VoidCallback? onBackToLogin;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('البريد الإلكتروني'),
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: FontSize.s14.sp,
              fontWeight: FontWeightManager.semiBold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            textAlign: context.isArabic ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: FontSize.s14.sp,
              fontWeight: FontWeightManager.medium,
              color: theme.textTheme.titleLarge?.color,
              height: 1.3,
            ),
            decoration: InputDecoration(
              hintText: 'name@company.com',
              hintTextDirection: TextDirection.ltr,
              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20.sp),
            ),
            onSubmitted: (_) => onSendCode(),
          ),
          SizedBox(height: 20.h),
          AppPrimaryButton(
            label: context.tr('إرسال رمز التحقق'),
            isLoading: isLoading,
            onPressed: onSendCode,
          ),
          SizedBox(height: 16.h),
          _buildInfoBox(context),
          SizedBox(height: 8.h),
          _buildBackToLogin(context),
        ],
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorManager.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: ColorManager.primaryColor,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              context.tr(
                'سنرسل رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. '
                    'يرجى التحقق من صندوق الوارد ومجلد الرسائل غير المرغوب فيها.',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: FontSize.s12.sp,
                height: 1.6,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLogin(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        onTap: onBackToLogin,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                color: ColorManager.primaryColor,
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                context.tr('العودة لتسجيل الدخول'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeightManager.bold,
                  color: ColorManager.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}