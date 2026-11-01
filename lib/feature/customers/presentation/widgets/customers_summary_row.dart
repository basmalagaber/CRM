import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomersSummaryRow extends StatelessWidget {
  const CustomersSummaryRow({
    super.key,
    required this.total,
    required this.newCount,
    required this.qualified,
    required this.merged,
  });

  final int total;
  final int newCount;
  final int qualified;
  final int merged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            value: total,
            label: context.tr('الإجمالي'),
            color: ColorManager.primaryColor,
            icon: Icons.people_alt_rounded,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _SummaryTile(
            value: newCount,
            label: context.tr('جديد'),
            color: LeadStatus.newLead.color,
            icon: Icons.fiber_new_rounded,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _SummaryTile(
            value: qualified,
            label: context.tr('مؤهل'),
            color: ColorManager.statusColor1,
            icon: Icons.verified_rounded,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _SummaryTile(
            value: merged,
            label: context.tr('مدمج'),
            color: LeadStatus.merged.color,
            icon: Icons.merge_type_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final int value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
      decoration: AppDecorations.card(context, radius: 16.r),
      child: Column(
        children: [
          Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 17.sp, color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeightManager.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}