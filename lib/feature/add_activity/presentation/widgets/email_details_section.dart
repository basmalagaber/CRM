import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_details_card.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/lead_date_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailDetailsSection extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onChanged;

  const EmailDetailsSection({super.key, this.onChanged});

  @override
  State<EmailDetailsSection> createState() => _EmailDetailsSectionState();
}

class _EmailDetailsSectionState extends State<EmailDetailsSection> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final subjectController = TextEditingController();
  final contentController = TextEditingController();

  DateTime sendDate = DateTime.now();
  DateTime receiveDate = DateTime.now();

  String? direction;
  String? status;
  bool _isInitialized = false;

  List<String> get directions => [context.tr('وارد'), context.tr('صادر')];
  List<String> get statuses => [
    context.tr('مرسل'),
    context.tr('مستلم'),
    context.tr('تم الرد عليه'),
    context.tr('فشل'),
  ];

  @override
  void initState() {
    super.initState();
    for (final c in [
      fromController,
      toController,
      subjectController,
      contentController,
    ]) {
      c.addListener(_notify);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      direction = context.tr('وارد');
      status = context.tr('مرسل');
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    subjectController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged?.call({
      'from': fromController.text.trim(),
      'to': toController.text.trim(),
      'subject': subjectController.text.trim(),
      'content': contentController.text.trim(),
      'sendDate': sendDate.toIso8601String(),
      'receiveDate': receiveDate.toIso8601String(),
      'direction': direction,
      'status': status,
    });
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(
      DateTime current,
      ValueChanged<DateTime> onPicked, {
        DateTime? firstDate,
      }) async {
    final first = DateUtils.dateOnly(
      firstDate ?? DateTime(DateTime.now().year - 5),
    );
    var initial = DateUtils.dateOnly(current);
    if (initial.isBefore(first)) initial = first;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (date == null || !mounted) return;
    setState(() => onPicked(date));
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.dir,
      child: ActivityDetailsCard(
        title: context.tr('تفاصيل البريد الإلكتروني'),
        icon: Icons.mail_outline_rounded,
        children: [
          LeadLabeledField(
            label: context.tr('من البريد الإلكتروني'),
            child: LeadTextField(
              controller: fromController,
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
            ),
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: context.tr('إلى البريد الإلكتروني'),
            child: LeadTextField(
              controller: toController,
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
            ),
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: context.tr('موضوع البريد الإلكتروني'),
            child: LeadTextField(
              controller: subjectController,
              hintText: context.tr('اكتب موضوع البريد'),
              maxLines: 2,
            ),
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: context.tr('محتوى البريد الإلكتروني'),
            child: LeadTextField(
              controller: contentController,
              hintText: context.tr('اكتب محتوى البريد'),
              maxLines: 6,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LeadLabeledField(
                  label: context.tr('تاريخ الإرسال'),
                  child: LeadDateField(
                    text: _fmt(sendDate),
                    onTap: () => _pickDate(sendDate, (d) {
                      sendDate = d;
                      if (DateUtils.dateOnly(receiveDate).isBefore(d)) {
                        receiveDate = d;
                      }
                    }),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: LeadLabeledField(
                  label: context.tr('تاريخ الاستلام'),
                  child: LeadDateField(
                    text: _fmt(receiveDate),
                    onTap: () => _pickDate(
                      receiveDate,
                          (d) => receiveDate = d,
                      firstDate: sendDate,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LeadLabeledField(
                  label: context.tr('الاتجاه'),
                  child: LeadDropdown(
                    value: direction,
                    items: directions,
                    hint: context.tr('اختر...'),
                    onChanged: (v) {
                      setState(() => direction = v);
                      _notify();
                    },
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: LeadLabeledField(
                  label: context.tr('حالة البريد'),
                  child: LeadDropdown(
                    value: status,
                    items: statuses,
                    hint: context.tr('اختر...'),
                    onChanged: (v) {
                      setState(() => status = v);
                      _notify();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}