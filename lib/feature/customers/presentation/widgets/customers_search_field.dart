import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomersSearchField extends StatelessWidget {
  const CustomersSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.showClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontFamily: FontConstants.fontFamily,
          fontSize: 14.sp,
          height: 1.3,
          color: theme.textTheme.titleLarge?.color,
        ),
        decoration: InputDecoration(
          fillColor: theme.cardTheme.color,
          hintText: context.tr('بحث بالاسم أو الشركة...'),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22.sp,
            color: theme.textTheme.bodyMedium?.color,
          ),
          suffixIcon:
          showClear
              ? IconButton(
            onPressed: onClear,
            tooltip: context.tr('مسح البحث'),
            icon: Icon(
              Icons.close_rounded,
              size: 20.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          )
              : null,
        ),
      ),
    );
  }
}