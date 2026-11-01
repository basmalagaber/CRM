import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';

class LeadSecondaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const LeadSecondaryButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.primaryColor,
          side: BorderSide(
            color: theme.dividerColor,
            width: 1.2.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: FontSize.s16.sp,
            fontWeight: FontWeightManager.semiBold,
          ),
        ),
      ),
    );
  }
}