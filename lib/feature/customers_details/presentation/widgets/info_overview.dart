import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoOverview extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const InfoOverview({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 10.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: theme.textTheme.titleSmall?.fontFamily,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleSmall?.color,
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}
