import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/calendar/data/calendar_models.dart';
import 'package:erp_system/feature/calendar/presentation/screens/add_event_screen.dart';
import 'package:erp_system/feature/calendar/presentation/widgets/calendar_widgets.dart';
import 'package:erp_system/feature/calendar/presentation/widgets/event_history_screen.dart';
import 'package:erp_system/feature/calendar/presentation/widgets/event_summary_screen.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_download_bar.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_exporter.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const String _all = 'الكل';
  static const List<String> _files = ['Excel', 'PDF'];

  static List<String> get _statuses => [
    _all,
    for (final s in CalendarEventStatus.values) s.label,
  ];

  static List<String> get _types => [
    _all,
    for (final t in CalendarEventType.values) t.label,
  ];

  String _status = _all;
  String _type = _all;
  String _file = 'Excel';
  bool _exporting = false;

  List<CalendarEvent> _filtered(DateTime now) {
    final list = CalendarStore.events.where((e) {
      if (_status != _all && context.tr(e.statusAt(now).label) != context.tr(_status)) {
        return false;
      }
      if (_type != _all && context.tr(e.type.label) != context.tr(_type)) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      final finishedA = a.statusAt(now) == CalendarEventStatus.finished;
      final finishedB = b.statusAt(now) == CalendarEventStatus.finished;

      if (finishedA != finishedB) {
        return finishedA ? 1 : -1;
      }
      return finishedA
          ? b.start.compareTo(a.start)
          : a.start.compareTo(b.start);
    });

    return list;
  }

  ReportTable _buildTable(
      List<CalendarEvent> events,
      DateTime now,
      ) {
    return ReportTable(
      fileName: 'calendar_events',
      title: context.tr('تقرير أحداث التقويم'),
      meta: [
        '${context.tr('الحالة')}: ${context.tr(_status)}',
        '${context.tr('نوع الحدث')}: ${context.tr(_type)}',
        '${context.tr('عدد الأحداث')}: ${events.length}',
      ],
      headers: [
        context.tr('رقم الحدث'),
        context.tr('العنوان'),
        context.tr('نوع الحدث'),
        context.tr('تاريخ ووقت البداية'),
        context.tr('تاريخ ووقت النهاية'),
        context.tr('الحالة'),
        context.tr('التذكير'),
      ],
      rows: [
        for (final e in events)
          [
            e.id,
            e.displayTitle,
            context.tr(e.type.label),
            calFmtDateTime(e.start),
            calFmtDateTime(e.end),
            context.tr(e.statusAt(now).label),
            e.reminderEnabled ? calMinutesLabel(e.reminderMinutes) : context.tr('لا'),
          ],
      ],
    );
  }

  Future<void> _download(
      List<CalendarEvent> events,
      DateTime now,
      ) async {
    if (_exporting) return;

    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('لا توجد بيانات للتنزيل')),
        ),
      );
      return;
    }

    final format =
    _file == 'PDF' ? ReportFileFormat.pdf : ReportFileFormat.excel;

    setState(() => _exporting = true);

    try {
      await exportReport(
        context,
        _buildTable(events, now),
        format,
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }



  Future<void> _openForm([CalendarEvent? event]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEventScreen(initial: event),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            event == null ? context.tr('تم إضافة الحدث') : context.tr('تم تعديل الحدث'),
          ),
        ),
      );
    }
  }

  Future<void> _onAction(
      CalendarEvent e,
      CalendarEventAction action,
      ) async {
    final nav = Navigator.of(context);

    switch (action) {
      case CalendarEventAction.view:
        await nav.push(
          MaterialPageRoute(
            builder: (_) => AddEventScreen(
              initial: e,
              readOnly: true,
            ),
          ),
        );
        break;

      case CalendarEventAction.summary:
        final saved = await nav.push<bool>(
          MaterialPageRoute(
            builder: (_) => EventSummaryScreen(event: e),
          ),
        );

        if (saved == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('تم حفظ الملخص')),
            ),
          );
        }
        break;

      case CalendarEventAction.history:
        await nav.push(
          MaterialPageRoute(
            builder: (_) => EventHistoryScreen(event: e),
          ),
        );
        break;

      case CalendarEventAction.edit:
        await _openForm(e);
        break;

      case CalendarEventAction.delete:
        await _confirmDelete(e);
        break;
    }
  }

  Future<void> _confirmDelete(CalendarEvent e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: context.dir,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          title: Text(context.tr('حذف الحدث')),
          content: Text(
            context.trArgs('هل أنتِ متأكدة إنك عايزة تحذفي "{title}"؟', {'title': e.displayTitle}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('إلغاء')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                foregroundColor: ReportColors.red,
              ),
              child: Text(context.tr('حذف')),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !mounted) return;

    CalendarStore.remove(e.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('تم حذف الحدث')),
      ),
    );
  }

  Widget _buildFilters(
      List<CalendarEvent> events,
      DateTime now,
      ) {
    return ReportCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ReportField(
                  label: context.tr('الحالة'),
                  child: ReportDropdown<String>(
                    title: context.tr('الحالة'),
                    value: _status,
                    values: _statuses,
                    labelOf: (v) => context.tr(v),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _status = v);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ReportField(
                  label: context.tr('نوع الحدث'),
                  child: ReportDropdown<String>(
                    title: context.tr('نوع الحدث'),
                    value: _type,
                    values: _types,
                    labelOf: (v) => context.tr(v),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _type = v);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ReportDownloadBar(
            file: _file,
            files: _files,
            onFileChanged: (v) => setState(() => _file = v),
            onDownload: () => _download(events, now),
            loading: _exporting,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsContent(
      List<CalendarEvent> all,
      List<CalendarEvent> events,
      DateTime now,
      ) {
    final upcoming = all
        .where((e) => e.statusAt(now) == CalendarEventStatus.upcoming)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final ongoing = all
        .where((e) => e.statusAt(now) == CalendarEventStatus.ongoing)
        .length;

    final today = all.where((e) => e.isOn(now)).length;
    final next = upcoming.isEmpty ? null : upcoming.first;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 96.h),
      children: [
        ReportHeroCard(
          badgeIcon: Icons.calendar_month_rounded,
          badge: context.tr('التقويم'),
          title: context.tr('الأحداث القادمة'),
          value: '${upcoming.length}',
          caption: next == null
              ? context.tr('لا توجد أحداث قادمة')
              : context.trArgs('التالي: {title} · {time}', {
            'title': next.displayTitle,
            'time': calFmtDateTime(next.start),
          }),
          stats: [
            ReportHeroStat('${all.length}', context.tr('إجمالي الأحداث')),
            ReportHeroStat('$today', context.tr('أحداث اليوم')),
            ReportHeroStat('$ongoing', context.tr('جارية الآن')),
          ],
        ),
        SizedBox(height: 8.h),
        ReportSectionTitle(
          context.tr('الأحداث'),
          subtitle: context.trArgs('عرض {current} من {total}', {
            'current': events.length,
            'total': all.length,
          }),
        ),
        SizedBox(height: 8.h),
        if (events.isEmpty)
          ReportEmpty(
            icon: Icons.event_busy_outlined,
            title: context.tr('لا توجد أحداث'),
            message: context.tr('غيّري الفلتر أو اضغطي زر + لإنشاء حدث جديد'),
          )
        else
          for (final e in events)
            CalendarEventCard(
              event: e,
              onAction: (action) => _onAction(e, action),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'calendar_fab',
          onPressed: () => _openForm(),
          backgroundColor: ColorManager.primaryColor,
          foregroundColor: ColorManager.iconColor,
          elevation: 4,
          shape: const StadiumBorder(),
          icon: Icon(
            Icons.add_rounded,
            size: 24.sp,
          ),
          label: Text(
            context.tr('حدث جديد'),
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s14.sp,
              fontWeight: FontWeightManager.bold,
              color: ColorManager.iconColor,
            ),
          ),
        ),
        body: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: CalendarStore.changes,
            builder: (context, _, __) {
              final now = DateTime.now();
              final all = CalendarStore.events;
              final events = _filtered(now);

              return Column(
                children: [
                  CalendarHeader(
                    title: context.tr('التقويم'),
                    subtitle: '${context.tr('إجمالي الأحداث')}: ${all.length}',
                    onBack: () => Navigator.pop(context),

                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                    child: _buildFilters(events, now),
                  ),
                  Expanded(
                    child: _buildEventsContent(all, events, now),
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