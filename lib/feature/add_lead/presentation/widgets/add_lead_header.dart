import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';

class AddLeadHeader extends StatelessWidget {
  final VoidCallback onClose;

  const AddLeadHeader({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_add_alt_1_outlined,
            size: 24.sp,
            color: theme.primaryColor,
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              context.tr('إضافة عميل محتمل'),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s18.sp,
                fontWeight: FontWeightManager.bold,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),

          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(6.r),
              child: Icon(
                Icons.close,
                size: 22.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}