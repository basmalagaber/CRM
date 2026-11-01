import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';

class AddLeadSteps extends StatelessWidget {
  final int currentStep;
  const AddLeadSteps({super.key, required this.currentStep});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          _StepItem(
            number: 1,
            title: context.tr('البيانات الأساسية'),
            isActive: currentStep == 0,
          ),
          Expanded(
            child: Container(
              height: 2.h,
              color: currentStep == 1 ? theme.primaryColor : theme.dividerColor,
            ),
          ),
          _StepItem(
            number: 2,
            title: context.tr('تفاصيل البيع'),
            isActive: currentStep == 1,
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final String title;
  final bool isActive;
  const _StepItem({
    required this.number,
    required this.title,
    required this.isActive,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 34.w,
          height: 34.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? theme.primaryColor : theme.dividerColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s14.sp,
              fontWeight: FontWeightManager.bold,
              color: isActive ? ColorManager.iconColor: theme.primaryColor,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          title,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: FontSize.s12.sp,
            fontWeight:
            isActive ? FontWeightManager.bold : FontWeightManager.regular,
            color:
            isActive
                ? theme.primaryColor
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}