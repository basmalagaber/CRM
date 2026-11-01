import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';

class PerformanceHeader extends StatelessWidget {
  const PerformanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyLarge?.color ?? ColorManager.textDarkColor;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.r),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ColorManager.primaryLightShade,
                  ColorManager.primaryColor,
                ],
              ),

            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 22.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'أداء الموظف',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 21.sp,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(Icons.close_rounded, size: 20.sp, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}