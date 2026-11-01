import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/feature/calendar/data/calendar_models.dart';
import 'package:erp_system/feature/calendar/presentation/widgets/calendar_widgets.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventSummaryScreen extends StatefulWidget {
  const EventSummaryScreen({super.key, required this.event});

  final CalendarEvent event;

  @override
  State<EventSummaryScreen> createState() => _EventSummaryScreenState();
}

class _EventSummaryScreenState extends State<EventSummaryScreen> {
  late final TextEditingController _text =
  TextEditingController(text: widget.event.summary);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    if (_text.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('اكتبي الملخص أولاً'))),
      );
      return;
    }

    CalendarStore.setSummary(widget.event.id, _text.text);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSummary = widget.event.summary.isNotEmpty;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: reportBorder(context)),
    );

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CalendarHeader(
                title: hasSummary
                    ? context.tr('تعديل ملخص الحدث')
                    : context.tr('إضافة ملخص للحدث'),
                subtitle: context.tr('اكتبي ملخص ما تم في الحدث'),
                backIcon: Icons.close_rounded,
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                  children: [
                    ReportCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(context.tr('الحدث: '),
                                  style: theme.textTheme.bodySmall),
                              Expanded(
                                child: Text(
                                  widget.event.displayTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          ReportField(
                            label: context.tr('الملخص'),
                            child: TextField(
                              controller: _text,
                              minLines: 6,
                              maxLines: 10,
                              style: theme.textTheme.titleSmall,
                              decoration: InputDecoration(
                                hintText: context.tr('اكتبي ملخص الحدث...'),
                                hintStyle: theme.textTheme.bodySmall,
                                filled: true,
                                fillColor:
                                theme.inputDecorationTheme.fillColor ??
                                    theme.scaffoldBackgroundColor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 13.h,
                                ),
                                border: border,
                                enabledBorder: border,
                                focusedBorder: border.copyWith(
                                  borderSide: BorderSide(
                                    color: ColorManager.primaryColor,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ReportButton(
                            label: context.tr('حفظ الملخص'),
                            icon: Icons.save_outlined,
                            onTap: _save,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ReportButton(
                            label: context.tr('إلغاء'),
                            icon: Icons.close_rounded,
                            filled: false,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                      ],
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