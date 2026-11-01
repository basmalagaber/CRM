import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/calendar/presentation/widgets/calendar_widgets.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum QuoteLogOp { add, update, delete }

extension QuoteLogOpX on QuoteLogOp {
  String get label {
    switch (this) {
      case QuoteLogOp.add:
        return 'إضافة';
      case QuoteLogOp.update:
        return 'تحديث';
      case QuoteLogOp.delete:
        return 'حذف';
    }
  }

  Color get color {
    switch (this) {
      case QuoteLogOp.add:
        return ReportColors.green;
      case QuoteLogOp.update:
        return ReportColors.blue;
      case QuoteLogOp.delete:
        return ReportColors.red;
    }
  }
}

class QuoteLogEntry {
  const QuoteLogEntry({
    required this.id,
    required this.quoteNumber,
    required this.op,
    required this.description,
    required this.user,
    required this.at,
  });

  final String id;
  final String quoteNumber;
  final QuoteLogOp op;
  final String description;
  final String user;
  final DateTime at;
}

class QuoteLogStore {
  QuoteLogStore._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static final List<QuoteLogEntry> _logs = [];
  static int _seq = 0;

  static String _two(int n) => n.toString().padLeft(2, '0');

  static List<QuoteLogEntry> forQuote(String quoteNumber) => _logs
      .where((l) => l.quoteNumber == quoteNumber)
      .toList()
      .reversed
      .toList();

  static void log(String quoteNumber, QuoteLogOp op, String description) {
    final now = DateTime.now();
    _seq++;
    _logs.add(
      QuoteLogEntry(
        id: 'LOG-${_two(now.year % 100)}${_two(now.month)}${_two(now.day)}$_seq',
        quoteNumber: quoteNumber,
        op: op,
        description: description,
        user: AppSession.userName ?? '—',
        at: now,
      ),
    );
    changes.value++;
  }
}

String _fmt(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${d.year}/${two(d.month)}/${two(d.day)}  '
      '${two(h)}:${two(d.minute)} ${d.hour < 12 ? 'ص' : 'م'}';
}

class QuoteHistoryScreen extends StatelessWidget {
  const QuoteHistoryScreen({super.key, required this.quote});

  final Map<String, dynamic> quote;

  String get _number => (quote['quoteNumber'] ?? '').toString().trim();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: QuoteLogStore.changes,
            builder: (context, _, __) {
              final logs = QuoteLogStore.forQuote(_number);
              int count(QuoteLogOp op) => logs.where((l) => l.op == op).length;

              return Column(
                children: [
                  CalendarHeader(
                    title: 'سجل التغييرات',
                    subtitle: _number.isEmpty ? 'عرض سعر' : _number,
                    onBack: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                      children: [
                        ReportHeroCard(
                          badgeIcon: Icons.history_rounded,
                          badge: 'السجل',
                          title: 'إجمالي العمليات',
                          value: '${logs.length}',
                          caption: 'متابعة جميع العمليات والتعديلات',
                          stats: [
                            ReportHeroStat('${count(QuoteLogOp.add)}', 'عمليات الإضافة'),
                            ReportHeroStat('${count(QuoteLogOp.update)}', 'عمليات التحديث'),
                            ReportHeroStat('${count(QuoteLogOp.delete)}', 'عمليات الحذف'),
                          ],
                        ),
                        const ReportSectionTitle('العمليات'),
                        if (logs.isEmpty)
                          const ReportEmpty(
                            icon: Icons.history_toggle_off_rounded,
                            title: 'لا توجد عمليات مسجلة',
                            message: 'هتظهر هنا كل التغييرات اللي بتتم على العرض',
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

  final QuoteLogEntry entry;

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
              ReportStatusChip(text: entry.op.label, color: entry.op.color),
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
                _fmt(entry.at),
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