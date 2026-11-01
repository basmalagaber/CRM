import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/lead_date_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_section_card.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityScheduleSection extends StatelessWidget {
  final TextEditingController durationController;
  final DateTime? nextFollowUp;
  final ValueChanged<DateTime> onNextFollowUpChanged;

  final Future<void> Function({
  required DateTime? current,
  required ValueChanged<DateTime> onPicked,
  bool withTime,
  }) onPickDate;

  const ActivityScheduleSection({
    super.key,
    required this.durationController,
    required this.nextFollowUp,
    required this.onNextFollowUpChanged,
    required this.onPickDate,
  });

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.dir,
      child: LeadSectionCard(
        child: Column(
          children: [
            LeadLabeledField(
              label: context.tr('المدة بالدقائق'),
              child: LeadTextField(
                controller: durationController,
                hintText: context.tr('أدخل مدة النشاط'),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 16.h),
            LeadLabeledField(
              label: context.tr('موعد المتابعة القادم'),
              child: LeadDateField(
                text: nextFollowUp == null ? null : formatDate(nextFollowUp!),
                onTap: () => onPickDate(
                  current: nextFollowUp,
                  onPicked: onNextFollowUpChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}