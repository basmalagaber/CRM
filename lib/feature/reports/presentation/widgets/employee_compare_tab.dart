import 'dart:math' as math;
import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/reports/data/reports_models.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_download_bar.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_exporter.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeCompareTab extends StatefulWidget {
  const EmployeeCompareTab({super.key, required this.refresh});

  final ValueNotifier<int> refresh;

  @override
  State<EmployeeCompareTab> createState() => _EmployeeCompareTabState();
}

class _EmployeeCompareTabState extends State<EmployeeCompareTab>
    with AutomaticKeepAliveClientMixin {
  final List<EmployeeStats> _all = ReportsRepository.employees;

  late Set<String> _selected = {_all.first.id};
  late Set<String> _applied = {..._selected};

  @override
  bool get wantKeepAlive => true;

  static const List<String> _files = ['Excel', 'PDF'];

  String _file = 'PDF';
  bool _exporting = false;

  ReportTable _buildTable(List<EmployeeStats> shown) {
    return ReportTable(
      fileName: 'employee_comparison',
      title: context.tr('تقرير مقارنة الموظفين'),
      meta: [
        '${context.tr("عدد الموظفين")}: ${shown.length}',
        '${context.tr("الموظفون")}: ${shown.map((e) => e.name).join('، ')}',
      ],
      headers: [
        context.tr('الموظف'),
        context.tr('العملاء المحتملون'),
        context.tr('العملاء المحولون'),
        context.tr('الفرص'),
        context.tr('الناجحة'),
        context.tr('الفواتير'),
        context.tr('أوامر البيع'),
        context.tr('المكالمات'),
        context.tr('الزيارات'),
        context.tr('متابعات مكتملة'),
        context.tr('متابعات معلقة'),
        context.tr('الالتزام %'),
        context.tr('متأخرات مفتوحة'),
        context.tr('متوسط التأخير (دقيقة)'),
      ],
      rows: [
        for (final e in shown)
          [
            e.name,
            e.leads,
            e.converted,
            e.opportunities,
            e.won,
            e.invoices,
            e.salesOrders,
            e.calls,
            e.visits,
            e.followDone,
            e.followPending,
            e.compliance,
            e.overdueOpen,
            e.avgDelayMinutes,
          ],
      ],
    );
  }

  Future<void> _download() async {
    if (_exporting) return;

    final shown = _shown;
    if (shown.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('من فضلك اختاري الموظف أولاً'))),
      );
      return;
    }

    final format = _file == 'PDF' ? ReportFileFormat.pdf : ReportFileFormat.excel;

    setState(() => _exporting = true);
    await exportReport(context, _buildTable(shown), format);
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

  List<EmployeeStats> get _shown =>
      _all.where((e) => _applied.contains(e.id)).toList();

  Future<void> _pick() async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => _EmployeePickerSheet(employees: _all, selected: _selected),
    );
    if (result != null && mounted) setState(() => _selected = result);
  }

  void _remove(String id) {
    final next = {..._selected};
    next.remove(id);
    setState(() => _selected = next);
  }

  void _apply() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('من فضلك اختاري الموظف أولاً'))),
      );
      return;
    }
    setState(() => _applied = {..._selected});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final shown = _shown;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        _buildFilter(context),
        if (shown.isEmpty)
          ReportEmpty(
            icon: Icons.groups_2_outlined,
            title: context.tr('لم يتم اختيار موظفين'),
            message: context.tr('اختاري موظفًا واحدًا على الأقل ثم اضغطي «عرض المقارنة»'),
          )
        else
          ..._buildReport(context, shown),
      ],
    );
  }

  Widget _buildFilter(BuildContext context) {
    final theme = Theme.of(context);
    final chosen = _all.where((e) => _selected.contains(e.id)).toList();

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportField(
            label: context.tr('الموظفون'),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: reportBorder(context)),
              ),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final e in chosen)
                    _EmployeeChip(name: e.name, onRemove: () => _remove(e.id)),
                  _AddChip(onTap: _pick),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: ReportButton(
                  label: context.tr('عرض المقارنة'),
                  icon: Icons.show_chart_rounded,
                  onTap: _apply,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ReportDownloadBar(
            file: _file,
            files: _files,
            onFileChanged: (v) => setState(() => _file = v),
            onDownload: _download,
            loading: _exporting,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReport(BuildContext context, List<EmployeeStats> shown) {
    final leads = shown.fold<int>(0, (s, e) => s + e.leads);
    final converted = shown.fold<int>(0, (s, e) => s + e.converted);
    final overdue = shown.fold<int>(0, (s, e) => s + e.overdueOpen);
    final compliance =
        shown.fold<double>(0, (s, e) => s + e.compliance) / shown.length;
    final rate = leads == 0 ? 0.0 : converted * 100 / leads;

    final salesMetrics = <_Metric>[
      _Metric(context.tr('إجمالي العملاء المحتملين'), ReportColors.blue, (e) => e.leads),
      _Metric(context.tr('العملاء المحولون'), ReportColors.teal, (e) => e.converted),
      _Metric(context.tr('إجمالي الفواتير'), ReportColors.red, (e) => e.invoices),
      _Metric(context.tr('أوامر البيع'), ReportColors.amber, (e) => e.salesOrders),
    ];

    final activityMetrics = <_Metric>[
      _Metric(context.tr('المكالمات'), ReportColors.blue, (e) => e.calls),
      _Metric(context.tr('الزيارات'), ReportColors.teal, (e) => e.visits),
      _Metric(context.tr('متابعات مكتملة'), ReportColors.amber, (e) => e.followDone),
      _Metric(context.tr('متابعات معلقة'), ReportColors.red, (e) => e.followPending),
    ];

    final qualityMetrics = <_Metric>[
      _Metric(
        context.tr('الالتزام بالمتابعة'),
        ReportColors.deepTeal,
            (e) => e.compliance,
        suffix: '%',
        fixedMax: 100,
      ),
      _Metric(context.tr('متأخرات مفتوحة'), ReportColors.red, (e) => e.overdueOpen),
      _Metric(
        context.tr('متوسط التأخير (دقيقة)'),
        ReportColors.amber,
            (e) => e.avgDelayMinutes,
      ),
    ];

    return [
      ReportHeroCard(
        badgeIcon: Icons.compare_arrows_rounded,
        badge: context.tr('ملخص المقارنة'),
        title: context.tr('إجمالي العملاء المحتملين'),
        value: '$leads',
        caption: context.trArgs('على {count} موظف محدد · {overdue} متأخرات مفتوحة', {'count': shown.length, 'overdue': overdue}),
        stats: [
          ReportHeroStat('$converted', context.tr('عملاء محولون')),
          ReportHeroStat(fmtPercent(rate), context.tr('معدل التحويل')),
          ReportHeroStat(fmtPercent(compliance), context.tr('معدل الالتزام')),
        ],
      ),
      _MetricGroupCard(
        title: context.tr('مسار المبيعات لكل موظف'),
        subtitle: context.tr('العملاء والتحويلات والفواتير والأوامر لكل موظف محدد'),
        employees: shown,
        metrics: salesMetrics,
        sharedScale: true,
      ),
      _MetricGroupCard(
        title: context.tr('المكالمات والزيارات والمتابعات'),
        subtitle: context.tr('نشاط التواصل لكل موظف محدد'),
        employees: shown,
        metrics: activityMetrics,
        sharedScale: true,
      ),
      _MetricGroupCard(
        title: context.tr('جودة الالتزام والمتأخرات'),
        subtitle: context.tr('نسبة الالتزام والمتأخرات المفتوحة ومتوسط التأخير لكل موظف'),
        employees: shown,
        metrics: qualityMetrics,
        sharedScale: false,
      ),
      ReportCard(
        title: context.tr('تفصيل بيانات كل موظف'),
        subtitle: context.tr('كل بطاقة تمثل موظفًا محددًا'),
        child: Column(
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) SizedBox(height: 12.h),
              _EmployeeDetailTile(stats: shown[i]),
            ],
          ],
        ),
      ),
    ];
  }
}

class _Metric {
  _Metric(
      this.label,
      this.color,
      this.pick, {
        this.suffix = '',
        this.fixedMax,
      });

  final String label;
  final Color color;
  final num Function(EmployeeStats) pick;
  final String suffix;
  final double? fixedMax;
}

class _MetricGroupCard extends StatelessWidget {
  const _MetricGroupCard({
    required this.title,
    required this.subtitle,
    required this.employees,
    required this.metrics,
    required this.sharedScale,
  });

  final String title;
  final String subtitle;
  final List<EmployeeStats> employees;
  final List<_Metric> metrics;
  final bool sharedScale;

  double _maxFor(_Metric m) {
    if (m.fixedMax != null) return m.fixedMax!;
    final list = sharedScale ? metrics : [m];
    var best = 1.0;
    for (final mm in list) {
      for (final e in employees) {
        best = math.max(best, mm.pick(e).toDouble());
      }
    }
    return best;
  }

  String _fmt(_Metric m, num v) {
    final text = v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
    return '$text${m.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = reportBorder(context);

    return ReportCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          for (var i = 0; i < employees.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Divider(height: 1, color: border),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  employees[i].name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ColorManager.primaryColor,
                  ),
                ),
              ),
            ),
            for (final m in metrics)
              HBarRow(
                label: m.label,
                value: m.pick(employees[i]).toDouble(),
                max: _maxFor(m),
                color: m.color,
                valueLabel: _fmt(m, m.pick(employees[i])),
              ),
          ],
        ],
      ),
    );
  }
}

class _EmployeeChip extends StatelessWidget {
  const _EmployeeChip({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 6.w,
        end: 12.w,
        top: 5.h,
        bottom: 5.h,
      ),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Icon(Icons.cancel_rounded, size: 18.sp, color: primary),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            name,
            style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.5.sp),
          ),
        ],
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = ColorManager.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: primary.withOpacity(0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16.sp, color: primary),
            SizedBox(width: 4.w),
            Text(
              context.tr('إضافة موظف'),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeightManager.bold,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeDetailTile extends StatelessWidget {
  const _EmployeeDetailTile({required this.stats});
  final EmployeeStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;
    final name = stats.name.trim();
    final initial = name.isEmpty ? '؟' : name.characters.first.toUpperCase();

    final items = <_MiniData>[
      _MiniData(context.tr('العملاء'), stats.leads),
      _MiniData(context.tr('المحولون'), stats.converted),
      _MiniData(context.tr('الفرص'), stats.opportunities),
      _MiniData(context.tr('الناجحة'), stats.won),
      _MiniData(context.tr('المكالمات'), stats.calls),
      _MiniData(context.tr('الزيارات'), stats.visits),
      _MiniData(context.tr('متابعات مكتملة'), stats.followDone),
      _MiniData(context.tr('متابعات معلقة'), stats.followPending),
      _MiniData(context.tr('متأخرات مفتوحة'), stats.overdueOpen, danger: stats.overdueOpen > 0),
    ];

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: reportBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeightManager.bold,
                    color: primary,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Text(stats.name, style: theme.textTheme.titleSmall)),
            ],
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, c) {
              final gap = 8.w;
              final w = ((c.maxWidth - gap * 2) / 3).floorToDouble();
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final it in items) _MiniMetric(width: w, data: it),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniData {
  const _MiniData(this.label, this.value, {this.danger = false});
  final String label;
  final int value;
  final bool danger;
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.width, required this.data});

  final double width;
  final _MiniData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = data.danger ? ReportColors.red : ColorManager.primaryColor;

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${data.value}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: data.danger ? color : null,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            data.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5.sp),
          ),
        ],
      ),
    );
  }
}

class _EmployeePickerSheet extends StatefulWidget {
  const _EmployeePickerSheet({required this.employees, required this.selected});

  final List<EmployeeStats> employees;
  final Set<String> selected;

  @override
  State<_EmployeePickerSheet> createState() => _EmployeePickerSheetState();
}

class _EmployeePickerSheetState extends State<_EmployeePickerSheet> {
  late final Set<String> _local = {...widget.selected};

  bool get _allSelected => _local.length == widget.employees.length;

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _local.clear();
      } else {
        _local
          ..clear()
          ..addAll(widget.employees.map((e) => e.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Directionality(
      textDirection: context.dir,
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: reportBorder(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: Text(context.tr('اختيار الموظفين'), style: theme.textTheme.titleMedium),
                  ),
                  TextButton(
                    onPressed: _toggleAll,
                    child: Text(
                      _allSelected ? context.tr('إلغاء الكل') : context.tr('تحديد الكل'),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeightManager.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final e in widget.employees)
                      CheckboxListTile(
                        value: _local.contains(e.id),
                        activeColor: primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(e.name, style: theme.textTheme.titleSmall),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _local.add(e.id);
                            } else {
                              _local.remove(e.id);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ReportButton(
                      label: context.tr('تم'),
                      icon: Icons.check_rounded,
                      onTap: () {
                        if (_local.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('من فضلك اختاري موظفًا واحدًا على الأقل')),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context, _local);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}