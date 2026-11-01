import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivitySteps extends StatelessWidget {
  final int currentStep;

  const ActivitySteps({super.key, required this.currentStep});

  static const List<String> titles = [
    'البيانات الأساسية',
    'الجدولة والمتابعة',
    'تفاصيل النشاط',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyLarge?.color ?? ColorManager.textDarkColor;
    final mutedColor =
        theme.textTheme.bodyMedium?.color ?? ColorManager.textMutedColor;
    final tintColor = ColorManager.primaryColor.withOpacity(0.10);

    return Directionality(
      textDirection: context.dir,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: AppDecorations.card(context, radius: 22),
        child: Row(
          children: List.generate(titles.length, (index) {
            final isDone = index < currentStep;
            final isActive = index == currentStep;
            final filled = isDone || isActive;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32.r,
                          height: 32.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled ? ColorManager.primaryColor : tintColor,

                          ),
                          child: isDone
                              ? Icon(
                            Icons.check_rounded,
                            size: 18.sp,
                            color: ColorManager.iconColor,
                          )
                              : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: FontSize.s14.sp,
                              fontWeight: FontWeightManager.bold,
                              color: filled
                                  ? ColorManager.iconColor
                                  : ColorManager.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          context.tr(titles[index]),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: 11.sp,
                            height: 1.3,
                            fontWeight: isActive
                                ? FontWeightManager.bold
                                : FontWeightManager.medium,
                            color: isActive ? textColor : mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != titles.length - 1)
                    Expanded(
                      child: Container(
                        height: 3.h,
                        margin: EdgeInsets.only(bottom: 28.h),
                        decoration: BoxDecoration(
                          color: isDone
                              ? ColorManager.primaryColor
                              : theme.dividerColor,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}