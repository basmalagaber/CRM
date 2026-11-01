import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductOverview extends StatelessWidget {
  final String name;
  final int quantity;
  final String price;
  final String currency;
  final bool showDivider;

  const ProductOverview({
    super.key,
    required this.name,
    required this.quantity,
    required this.price,
    this.currency = 'AED',
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
              vertical: 12.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency,
                      style: TextStyle(
                        fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleSmall?.color,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      price,
                      style: TextStyle(
                        fontFamily: theme.textTheme.titleSmall?.fontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleSmall?.color,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: theme.textTheme.titleSmall?.fontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleSmall?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'الكمية: ${quantity}',
                      style: TextStyle(
                        fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor.withOpacity(0.3),
              indent: 16.w,
              endIndent: 16.w,
            ),
        ],
      ),
    );
  }
}