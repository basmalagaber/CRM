import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/colors_manager.dart';
import 'lead_dropdown.dart';
import 'lead_labeled_field.dart';
import 'lead_section_card.dart';
import 'lead_text_field.dart';

class SalesPipelineSection extends StatelessWidget {
  final String? sector;
  final String? priority;

  final TextEditingController descriptionController;

  final ValueChanged<String?>? onSectorChanged;
  final ValueChanged<String?> onPriorityChanged;

  final List<String>? sectors;
  final List<String> priorities;

  const SalesPipelineSection({
    super.key,
    this.sector,
    required this.priority,
    required this.descriptionController,
    this.onSectorChanged,
    required this.onPriorityChanged,
    this.sectors,
    required this.priorities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showSector = sectors != null && sectors!.isNotEmpty;

    return LeadSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  size: 20.sp,
                  color: ColorManager.primaryColor,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(context.tr('الخط البيعي'), style: theme.textTheme.titleSmall),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          if (showSector) ...[
            LeadLabeledField(
              label: context.tr('القطاع'),
              child: LeadDropdown(
                value: sector,
                items: sectors!,
                hint: context.tr('اختر القطاع'),
                onChanged: onSectorChanged ?? (_) {},
              ),
            ),
            SizedBox(height: 16.h),
          ],

          LeadLabeledField(
            label: context.tr('الأولوية'),
            child: LeadDropdown(
              value: priority,
              items: priorities,
              hint: context.tr('اختر الأولوية'),
              onChanged: onPriorityChanged,
            ),
          ),

          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('الوصف'),
            child: LeadTextField(
              controller: descriptionController,
              hintText: context.tr('أدخل وصف العميل المحتمل'),
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }
}