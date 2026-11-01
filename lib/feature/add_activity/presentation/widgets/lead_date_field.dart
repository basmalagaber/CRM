import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';

class LeadDateField extends StatelessWidget {
  final String? text;
  final String hint;
  final VoidCallback onTap;
  final String? errorText;

  const LeadDateField({
    super.key,
    required this.text,
    required this.onTap,
    this.hint = 'اختر التاريخ',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasValue = text != null && text!.isNotEmpty;
    final hasError = errorText != null;
    final errorColor = theme.colorScheme.error;

    return Directionality(
      textDirection: context.dir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor ??
                    theme.cardTheme.color,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: hasError ? errorColor : theme.dividerColor,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: primary,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      hasValue ? text! : context.tr(hint),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s14.sp,
                        fontWeight: hasValue
                            ? FontWeightManager.medium
                            : FontWeightManager.regular,
                        color: hasValue
                            ? theme.textTheme.bodyLarge?.color
                            : theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: 5.h),
            Text(
              errorText!,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s12.sp,
                color: errorColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}