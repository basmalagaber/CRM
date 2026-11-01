import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/app_decorations.dart';
import '../../../../core/resources/colors_manager.dart';

class DataItem extends StatelessWidget {
  final IconData icon;

  final Color iconBackgroundColor;
  final int num;
  final String title;
  final String recent;
  final bool isPositive;

  const DataItem({
    super.key,
    required this.icon,
    required this.num,
    required this.title,
    required this.recent,
    this.iconBackgroundColor = ColorManager.primaryColor,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color trendColor = isPositive
        ? (isDark
        ? ColorManager.statusColor1
        : ColorManager.approvalApprovedFgLight)
        : ColorManager.errorTitle;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: iconBackgroundColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: iconBackgroundColor, size: 22.sp),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14.sp,
                        color: trendColor,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          context.tr(recent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: trendColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            '$num',
            style: theme.textTheme.headlineLarge?.copyWith(height: 1.1),
          ),
          SizedBox(height: 4.h),
          Text(
            context.tr(title),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}