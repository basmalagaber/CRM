import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_primary_button.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddLeadFooter extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const AddLeadFooter({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onNext,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: LeadSecondaryButton(title: context.tr('السابق'), onPressed: onBack),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: LeadPrimaryButton(
              title: context.tr(currentStep == 1 ? 'حفظ العميل' : 'التالي'),
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}