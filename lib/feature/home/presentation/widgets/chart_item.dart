import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChartItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  final int? total;

  const ChartItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? percent = (total == null || total == 0)
        ? null
        : '${(value / total! * 100).round()}%';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 10.r,
            height: 10.r,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.tr(label),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
            ),
          ),
          Text(
            '$value',
            style: theme.textTheme.labelLarge?.copyWith(fontSize: 13.sp),
          ),
          if (percent != null) ...[
            SizedBox(width: 6.w),
            SizedBox(
              width: 34.w,
              child: Text(
                percent,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}