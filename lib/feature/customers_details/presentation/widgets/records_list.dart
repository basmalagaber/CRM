import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordsList extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final bool showDivider;

  const RecordsList({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '  ${date} ${time} ',
                  style: TextStyle(
                    fontFamily: theme.textTheme.bodySmall?.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.titleSmall?.color,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: theme.textTheme.bodySmall?.fontFamily,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor,
              indent: 16.w,
              endIndent: 16.w,
            ),
        ],
      ),
    );
  }
}