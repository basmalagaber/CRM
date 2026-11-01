import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/feature/reports/data/reports_models.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_download_bar.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_exporter.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DelaysTab extends StatefulWidget {
  const DelaysTab({super.key, required this.refresh});

  final ValueNotifier<int> refresh;

  @override
  State<DelaysTab> createState() => _DelaysTabState();
}

class _DelaysTabState extends State<DelaysTab>
    with AutomaticKeepAliveClientMixin {
  static const String _allEmployees = 'كل الموظفين';
  static const String _statusAll = 'الكل';
  static const String _statusOpen = 'مفتوحة';
  static const String _statusResolved = 'تم الحل';
  static const List<String> _statuses = [_statusAll, _statusOpen, _statusResolved];
  static const List<String> _files = ['Excel', 'PDF'];

  String _employee = _allEmployees;
  DateTime _from = DateTime.now().subtract(const Duration(days: 127));
  DateTime _to = DateTime.now();
  String _status = _statusAll;
  String _file = 'Excel';

  String _aEmployee = _allEmployees;
  DateTime _aFrom = DateTime.now().subtract(const Duration(days: 127));
  DateTime _aTo = DateTime.now();
  String _aStatus = _statusAll;

  late final List<String> _employeeNames = [
    _allEmployees,
    ...ReportsRepository.employees.map((e) => e.name),
  ];

  @override
  bool get wantKeepAlive => true;

  bool _exporting = false;

  ReportTable _buildTable(List<DelayRecord> list) {
    return ReportTable(
      fileName: 'delays_report',
      title: context.tr('تقرير المتأخرات'),
      meta: [
        '${context.tr("الموظف")}: $_aEmployee',
        '${context.tr("من")}: ${fmtDate(_aFrom)} — ${context.tr("إلى")}: ${fmtDate(_aTo)}',
        '${context.tr("الحالة")}: ${context.tr(_aStatus)}',
        '${context.tr("إجمالي المتأخرات")}: ${list.length}',
      ],
      headers: [
        context.tr('العميل المحتمل'),
        context.tr('المسؤول'),
        context.tr('موعد المتابعة'),
        context.tr('وقت الاكتشاف'),
        context.tr('التأخير (دقيقة)'),
        context.tr('الحالة'),
        context.tr('وقت الحل'),
        context.tr('تم الحل بواسطة'),
      ],
      rows: [
        for (final d in list)
          [
            d.leadName,
            d.responsible,
            fmtDateTime(d.followUpAt),
            fmtDateTime(d.discoveredAt),
            d.delayMinutes,
            d.resolved ? context.tr('تم الحل') : context.tr('مفتوحة'),
            d.resolvedAt == null ? '-' : fmtDateTime(d.resolvedAt!),
            d.resolvedBy ?? '-',
          ],
      ],
    );
  }

  Future<void> _download() async {
    if (_exporting) return;

    final list = _filtered();
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('لا توجد بيانات للتنزيل'))),
      );
      return;
    }

    final format = _file == 'PDF' ? ReportFileFormat.pdf : ReportFileFormat.excel;

    setState(() => _exporting = true);
    await exportReport(context, _buildTable(list), format);
    if (mounted) setState(() => _exporting = false);
  }

  @override
  void initState() {
    super.initState();
    widget.refresh.addListener(_onRefresh);
  }

  @override
  void dispose() {
    widget.refresh.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    if (mounted) setState(() {});
  }

  List<DelayRecord> _filtered() {
    final start = DateTime(_aFrom.year, _aFrom.month, _aFrom.day);
    final end = DateTime(_aTo.year, _aTo.month, _aTo.day).add(const Duration(days: 1));

    return ReportsRepository.delays.where((d) {
      if (_aEmployee != _allEmployees && d.responsible != _aEmployee) {
        return false;
      }
      if (d.followUpAt.isBefore(start) || !d.followUpAt.isBefore(end)) {
        return false;
      }
      if (_aStatus == _statusOpen && d.resolved) return false;
      if (_aStatus == _statusResolved && !d.resolved) return false;
      return true;
    }).toList();
  }

  void _apply() {
    setState(() {
      _aEmployee = _employee;
      _aFrom = _from;
      _aTo = _to;
      _aStatus = _status;
    });
  }

  void _reset() {
    setState(() {
      _employee = _allEmployees;
      _to = DateTime.now();
      _from = _to.subtract(const Duration(days: 127));
      _status = _statusAll;
    });
    _apply();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Directionality(
        textDirection: context.dir,
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isFrom) {
        _from = picked;
        if (_from.isAfter(_to)) _to = picked;
      } else {
        _to = picked;
        if (_to.isBefore(_from)) _from = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final list = _filtered();
    final open = list.where((d) => !d.resolved).length;
    final resolved = list.length - open;

    final maxDelay = list.fold<int>(0, (m, d) => d.delayMinutes > m ? d.delayMinutes : m);
    final avgDelay = list.isEmpty
        ? 0
        : (list.fold<int>(0, (s, d) => s + d.delayMinutes) / list.length).round();

    final biggest = [...list]..sort((a, b) => b.delayMinutes.compareTo(a.delayMinutes));

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        _buildFilter(context),
        if (list.isEmpty)
          ReportEmpty(
            icon: Icons.task_alt_rounded,
            title: context.tr('لا توجد متأخرات'),
            message: context.tr('مفيش نتائج مطابقة للفلتر الحالي'),
          )
        else ...[
          ReportHeroCard(
            badgeIcon: Icons.schedule_rounded,
            badge: context.tr('ملخص المتأخرات'),
            title: context.tr('إجمالي المتأخرات'),
            value: '${list.length}',
            caption: context.trArgs('نتائج الفلترة · أقصى تأخير: {max} دقيقة', {'max': maxDelay}),
            stats: [
              ReportHeroStat('$open', context.tr('مفتوحة')),
              ReportHeroStat('$resolved', context.tr('تم حلها')),
              ReportHeroStat('$avgDelay د', context.tr('متوسط التأخير')),
            ],
          ),

          ReportCard(
            title: context.tr('حالة المتأخرات'),
            subtitle: context.tr('المحلولة مقابل المفتوحة'),
            child: Column(
              children: [
                SizedBox(
                  height: 190.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 58.r,
                          startDegreeOffset: -90,
                          sections: [
                            if (resolved > 0)
                              PieChartSectionData(
                                value: resolved.toDouble(),
                                color: ReportColors.green,
                                radius: 26.r,
                                showTitle: false,
                              ),
                            if (open > 0)
                              PieChartSectionData(
                                value: open.toDouble(),
                                color: ReportColors.red,
                                radius: 26.r,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${list.length}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 28.sp,
                            ),
                          ),
                          Text(
                            context.tr('إجمالي'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                ReportLegend(
                  items: [
                    LegendItem(ReportColors.green, '${context.tr("تم الحل")} ($resolved)'),
                    LegendItem(ReportColors.red, '${context.tr("مفتوحة")} ($open)'),
                  ],
                ),
              ],
            ),
          ),

          ReportCard(
            title: context.tr('أكبر المتأخرات'),
            subtitle: context.tr('دقائق التأخير حسب العميل المحتمل'),
            child: Column(
              children: [
                for (final d in biggest.take(5))
                  HBarRow(
                    inline: true,
                    labelWidth: 96,
                    label: d.leadName,
                    value: d.delayMinutes.toDouble(),
                    max: maxDelay.toDouble(),
                    color: d.resolved ? ReportColors.green : ReportColors.red,
                    valueLabel: '${d.delayMinutes}',
                  ),
              ],
            ),
          ),

          ReportSectionTitle(
            context.tr('تفاصيل المتأخرات'),
            subtitle: context.tr('كل بطاقة تمثل متابعة متأخرة'),
          ),
          for (final d in list) _DelayCard(record: d),
        ],
      ],
    );
  }
  Widget _buildFilter(BuildContext context) {
    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('فلتر المتأخرات'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_employee != _allEmployees || _status != _statusAll)
                TextButton.icon(
                  onPressed: _reset,
                  icon: Icon(Icons.refresh_rounded, size: 16.sp),
                  label: Text(context.tr('إعادة ضبط'), style: TextStyle(fontSize: 11.sp)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),

          Row(
            children: [
              Expanded(
                child: ReportField(
                  label: context.tr('الموظف'),
                  child: ReportDropdown<String>(
                    title: context.tr('الموظف'),
                    value: _employee,
                    values: _employeeNames,
                    labelOf: (v) => v == _allEmployees ? context.tr(_allEmployees) : v,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _employee = v);
                        _apply();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ReportField(
                  label: context.tr('الحالة'),
                  child: ReportFileMenu(
                    value: _status,
                    values: _statuses,
                    labelOf: (v) => context.tr(v),
                    onFileChanged: (v) {
                      setState(() => _status = v);
                      _apply();
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          Row(
            children: [
              Expanded(
                child: ReportField(
                  label: context.tr('من'),
                  child: ReportDateField(
                    text: fmtDate(_from),
                    onTap: () async {
                      await _pickDate(isFrom: true);
                      _apply();
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ReportField(
                  label: context.tr('إلى'),
                  child: ReportDateField(
                    text: fmtDate(_to),
                    onTap: () async {
                      await _pickDate(isFrom: false);
                      _apply();
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          Container(
            padding: EdgeInsets.only(top: 10.h),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: reportBorder(context), width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ReportFileMenu(
                    value: _file,
                    values: _files,
                    onFileChanged: (v) => setState(() => _file = v),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 2,
                  child: ReportButton(
                    label: context.tr('تحميل'),
                    icon: Icons.download_rounded,
                    loading: _exporting,
                    onTap: _download,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DelayCard extends StatelessWidget {
  const _DelayCard({required this.record});
  final DelayRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = record;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: AppDecorations.card(context, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(d.leadName, style: theme.textTheme.titleSmall),
              ),
              ReportStatusChip(
                text: d.resolved ? context.tr('تم الحل') : context.tr('مفتوحة'),
                color: d.resolved ? ReportColors.green : ReportColors.red,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, color: reportBorder(context)),
          SizedBox(height: 6.h),
          ReportKeyValue(label: context.tr('المسؤول'), value: d.responsible),
          ReportKeyValue(label: context.tr('موعد المتابعة'), value: fmtDateTime(d.followUpAt)),
          ReportKeyValue(label: context.tr('وقت الاكتشاف'), value: fmtDateTime(d.discoveredAt)),
          ReportKeyValue(label: context.tr('التأخير'), value: '${d.delayMinutes} ${context.tr("دقيقة")}'),
          ReportKeyValue(
            label: context.tr('وقت الحل'),
            value: d.resolvedAt == null ? '—' : fmtDateTime(d.resolvedAt!),
          ),
          ReportKeyValue(label: context.tr('تم الحل بواسطة'), value: d.resolvedBy ?? '—'),
        ],
      ),
    );
  }
}