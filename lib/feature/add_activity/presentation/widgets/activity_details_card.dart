import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityDetailsCard extends StatelessWidget {
  const ActivityDetailsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: AppDecorations.card(context, radius: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: ColorManager.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: ColorManager.primaryColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(context.tr(title), style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            ...children,
          ],
        ),
      ),
    );
  }
}