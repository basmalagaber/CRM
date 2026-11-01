import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_details_card.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/lead_date_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitDetailsSection extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onChanged;

  const VisitDetailsSection({super.key, this.onChanged});

  @override
  State<VisitDetailsSection> createState() => _VisitDetailsSectionState();
}

class _VisitDetailsSectionState extends State<VisitDetailsSection> {
  final summaryController = TextEditingController();

  DateTime visitDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    summaryController.addListener(_notify);
  }

  @override
  void dispose() {
    summaryController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged?.call({
      'visitDateTime': visitDateTime.toIso8601String(),
      'summary': summaryController.text.trim(),
    });
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
          '  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: visitDateTime,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(visitDateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      visitDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.dir,
      child: ActivityDetailsCard(
        title: context.tr('تفاصيل الزيارة'),
        icon: Icons.place_outlined,
        children: [
          LeadLabeledField(
            label: context.tr('تاريخ ووقت الزيارة'),
            child: LeadDateField(text: _fmt(visitDateTime), onTap: _pickDateTime),
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: context.tr('ملخص الزيارة'),
            child: LeadTextField(
              controller: summaryController,
              hintText: context.tr('اكتب ملخص الزيارة'),
              maxLines: 6,
            ),
          ),
        ],
      ),
    );
  }
}