import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';
import 'lead_dropdown.dart';
import 'lead_labeled_field.dart';
import 'lead_section_card.dart';

class ResponsibleEmployeeSection extends StatelessWidget {
  final String? assignMode;
  final String? responsibleEmployee;

  final ValueChanged<String?> onAssignModeChanged;
  final ValueChanged<String?> onResponsibleEmployeeChanged;

  final List<String> assignModes;
  final List<String> employees;

  const ResponsibleEmployeeSection({
    super.key,
    required this.assignMode,
    required this.responsibleEmployee,
    required this.onAssignModeChanged,
    required this.onResponsibleEmployeeChanged,
    required this.assignModes,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LeadSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('الموظف المسؤول'),
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s17.sp,
              fontWeight: FontWeightManager.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),

          SizedBox(height: 14.h),

          LeadLabeledField(
            label: context.tr('طريقة التعيين'),
            child: LeadDropdown(
              value: assignMode,
              items: assignModes,
              hint: context.tr('اختر طريقة التعيين'),
              onChanged: onAssignModeChanged,
            ),
          ),

          if (assignMode == 'تعيين يدوي') ...[
            SizedBox(height: 14.h),

            LeadLabeledField(
              label: context.tr('المسؤول'),
              child: LeadDropdown(
                value: responsibleEmployee,
                items: employees,
                hint: context.tr('اختر المسؤول'),
                onChanged: onResponsibleEmployeeChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }
}