import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';

class LeadPrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const LeadPrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: FontSize.s16.sp,
            fontWeight: FontWeightManager.bold,
          ),
        ),
      ),
    );
  }
}