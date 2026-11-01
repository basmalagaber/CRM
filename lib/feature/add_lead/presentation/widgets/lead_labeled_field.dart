import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/fonts_manager.dart';

class LeadLabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool requiredField;

  const LeadLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: FontSize.s14.sp,
                      fontWeight: FontWeightManager.semiBold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (requiredField)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s14.sp,
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}