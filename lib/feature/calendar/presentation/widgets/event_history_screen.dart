import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/calendar/data/calendar_models.dart';
import 'package:erp_system/feature/calendar/presentation/widgets/calendar_widgets.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension _LogOpColor on CalendarLogOp {
  Color get color {
    switch (this) {
      case CalendarLogOp.add:
        return ReportColors.green;
      case CalendarLogOp.update:
        return ReportColors.blue;
      case CalendarLogOp.delete:
        return ReportColors.red;
    }
  }
}

class EventHistoryScreen extends StatelessWidget {
  const EventHistoryScreen({super.key, required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: CalendarStore.changes,
            builder: (context, _, __) {
              final logs = CalendarStore.logsFor(event.id);
              int count(CalendarLogOp op) =>
                  logs.where((l) => l.op == op).length;

              return Column(
                children: [
                  CalendarHeader(
                    title: context.tr('سجل التغييرات'),
                    subtitle: event.displayTitle,
                    onBack: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                      children: [
                        ReportHeroCard(
                          badgeIcon: Icons.history_rounded,
                          badge: context.tr('السجل'),
                          title: context.tr('إجمالي العمليات'),
                          value: '${logs.length}',
                          caption: context.tr('متابعة جميع العمليات والتعديلات'),
                          stats: [
                            ReportHeroStat('${count(CalendarLogOp.add)}', context.tr('عمليات الإضافة')),
                            ReportHeroStat('${count(CalendarLogOp.update)}', context.tr('عمليات التحديث')),
                            ReportHeroStat('${count(CalendarLogOp.delete)}', context.tr('عمليات الحذف')),
                          ],
                        ),
                        ReportSectionTitle(context.tr('العمليات')),
                        if (logs.isEmpty)
                          ReportEmpty(
                            icon: Icons.history_toggle_off_rounded,
                            title: context.tr('لا توجد عمليات مسجلة'),
                            message: context.tr('هتظهر هنا كل التعديلات اللي بتتم على الحدث'),
                          )
                        else
                          for (final l in logs) _LogCard(entry: l),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.entry});

  final CalendarLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.id,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeightManager.bold,
                    color: ColorManager.primaryColor,
                  ),
                ),
              ),
              ReportStatusChip(text: context.tr(entry.op.label), color: entry.op.color),
            ],
          ),
          SizedBox(height: 10.h),
          Text(entry.description, style: theme.textTheme.titleSmall),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  entry.user,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Text(
                calFmtDateTime(entry.at),
                textDirection: TextDirection.ltr,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}