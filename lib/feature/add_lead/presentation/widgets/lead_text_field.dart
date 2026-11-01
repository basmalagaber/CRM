import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/fonts_manager.dart';

class LeadTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? errorText;
  final int? maxLines;
  final TextDirection? textDirection;
  final List<TextInputFormatter>? inputFormatters;

  const LeadTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
    this.errorText,
    this.maxLines = 1,
    this.textDirection,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasError = errorText != null;
    final isMultiline = (maxLines ?? 1) != 1;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final idleColor =
    hasError ? Colors.redAccent : theme.dividerColor.withOpacity(0.5);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),

            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              readOnly: readOnly,
              onTap: onTap,
              maxLines: maxLines,
              textAlign: TextAlign.start,
              textDirection: textDirection,
              cursorColor: primary,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s14.sp,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: theme.cardTheme.color,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: isMultiline ? 14.h : 15.h,
                ),
                border: border(idleColor),
                enabledBorder: border(idleColor),
                focusedBorder: border(
                  hasError ? Colors.redAccent : primary.withOpacity(0.6),
                  1.4,
                ),
                errorBorder: border(Colors.redAccent),
                focusedErrorBorder: border(Colors.redAccent, 1.4),
              ),
            ),
          ),
          if (hasError) ...[
            SizedBox(height: 5.h),
            Text(
              errorText!,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s12.sp,
                color: Colors.redAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}