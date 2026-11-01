import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityImagesField extends StatelessWidget {
  const ActivityImagesField({
    super.key,
    required this.label,
    required this.controller,
    required this.images,
    required this.onAddUrl,
    required this.onPickFromDevice,
    required this.onRemove,
  });

  final String label;
  final TextEditingController controller;
  final List<String> images;
  final VoidCallback onAddUrl;
  final VoidCallback onPickFromDevice;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LeadLabeledField(
            label: label,
            child: LeadTextField(
              controller: controller,
              hintText: 'https://...',
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onAddUrl,
                icon: Icon(Icons.add_rounded, size: 18.sp),
                label: Text(
                  context.tr('إضافة'),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s14.sp,
                    fontWeight: FontWeightManager.bold,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              OutlinedButton.icon(
                onPressed: onPickFromDevice,
                icon: Icon(Icons.upload_outlined, size: 18.sp),
                label: Text(
                  context.tr('من الجهاز'),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (images.isEmpty)
            Text(context.tr('لا توجد صور'), style: theme.textTheme.bodyMedium)
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(images.length, (i) {
                return Chip(
                  label: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 200.w),
                    child: Text(
                      images[i],
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  backgroundColor: ColorManager.primaryColor.withOpacity(0.08),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  deleteIcon: Icon(Icons.close_rounded, size: 16.sp),
                  onDeleted: () => onRemove(i),
                );
              }),
            ),
        ],
      ),
    );
  }
}