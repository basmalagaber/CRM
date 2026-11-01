import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityTypePlaceholder extends StatelessWidget {
  const ActivityTypePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
        decoration: AppDecorations.card(context, radius: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: ColorManager.primaryColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.touch_app_outlined,
                size: 30.sp,
                color: ColorManager.primaryColor,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              context.tr('تفاصيل نوع النشاط'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            SizedBox(height: 6.h),
            Text(
              context.tr('اختر نوع النشاط أولاً لعرض التفاصيل المرتبطة به.'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}