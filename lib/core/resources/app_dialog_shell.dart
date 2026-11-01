import 'package:erp_system/core/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/colors_manager.dart';
import '../resources/fonts_manager.dart';

class AppDialogShell extends StatelessWidget {
  const AppDialogShell({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    required this.confirmLabel,
    required this.onConfirm,
    this.description,
    this.confirmIcon = Icons.check_rounded,
    this.cancelLabel = 'إلغاء',
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget child;
  final String confirmLabel;
  final IconData confirmIcon;
  final String cancelLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.color;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: theme.cardTheme.color ?? theme.cardColor,
        surfaceTintColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 14.w, 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: ColorManager.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        icon,
                        size: 22.sp,
                        color: ColorManager.primaryColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: FontSize.s16.sp,
                          fontWeight: FontWeightManager.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(6.r),
                        child: Icon(Icons.close_rounded, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),

              // Body
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (description != null) ...[
                      Text(
                        description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: FontSize.s12.sp,
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    child,
                  ],
                ),
              ),

              // Buttons
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppPrimaryButton(
                        label: confirmLabel,
                        icon: confirmIcon,
                        onPressed: onConfirm,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: SizedBox(
                        height: 52.h,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            cancelLabel,
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: FontSize.s14.sp,
                              fontWeight: FontWeightManager.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small tinted tile used inside dialogs ("current customer: ...").
class AppInfoTile extends StatelessWidget {
  const AppInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: ColorManager.primaryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorManager.primaryColor.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: ColorManager.primaryColor),
          SizedBox(width: 8.w),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: FontSize.s12.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: FontSize.s14.sp,
                fontWeight: FontWeightManager.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}