import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/reports/data/reports_models.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_download_bar.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_exporter.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopPerformersTab extends StatefulWidget {
  const TopPerformersTab({super.key, required this.refresh});

  final ValueNotifier<int> refresh;

  @override
  State<TopPerformersTab> createState() => _TopPerformersTabState();
}

class _Rank {
  const _Rank(this.rank, this.name, this.score);
  final int rank;
  final String name;
  final int score;

  String get displayName => name.trim().isEmpty ? 'بدون اسم' : name;
}

class _TopPerformersTabState extends State<TopPerformersTab>
    with AutomaticKeepAliveClientMixin {
  static const List<String> _periods = [
    'يومي',
    'أسبوعي',
    'شهري',
    'ربع سنوي',
    'سنوي',
  ];
  static const List<String> _files = ['Excel', 'PDF'];

  static const String _metric = 'إجمالي العملاء المحتملين';

  static const List<Color> _barColors = [
    ReportColors.amber,
    ReportColors.slate,
    ReportColors.orange,
    ReportColors.blue,
    ReportColors.teal,
    ReportColors.red,
    ReportColors.amber,
    ReportColors.slate,
    ReportColors.orange,
    ReportColors.blue,
  ];

  String _period = 'أسبوعي';
  String _file = 'Excel';
  late List<_Rank> _ranking = _buildRanking();

  @override
  bool get wantKeepAlive => true;

  bool _exporting = false;

  ReportTable _buildTable() {
    return ReportTable(
      fileName: 'top_performers',
      title: context.tr('تقرير الأعلى أداء'),
      meta: [
        '${context.tr("فترة الأداء")}: ${context.tr(_period)}',
        '${context.tr("المؤشر")}: ${context.tr(_metric)}',
        '${context.tr("عدد الموظفين")}: ${_ranking.length}',
      ],
      headers: [context.tr('الترتيب'), context.tr('الموظف'), context.tr(_metric)],
      rows: [
        for (final r in _ranking) [r.rank, r.displayName, r.score],
      ],
    );
  }

  Future<void> _download() async {
    if (_exporting) return;

    if (_ranking.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('لا توجد بيانات للتنزيل'))),
      );
      return;
    }

    final format = _file == 'PDF' ? ReportFileFormat.pdf : ReportFileFormat.excel;

    setState(() => _exporting = true);
    await exportReport(context, _buildTable(), format);
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
    if (mounted) setState(() => _ranking = _buildRanking());
  }

  List<_Rank> _buildRanking() {
    final entries = ReportsRepository.employees.asMap().entries.toList()
      ..sort((a, b) {
        final c = b.value.leads.compareTo(a.value.leads);
        return c != 0 ? c : a.key.compareTo(b.key);
      });

    return [
      for (var i = 0; i < entries.length; i++)
        _Rank(i + 1, entries[i].value.name, entries[i].value.leads),
    ];
  }

  void _updateRanking() {
    setState(() => _ranking = _buildRanking());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.trArgs('تم تحديث الترتيب ({period})', {'period': context.tr(_period)}))),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final ranking = _ranking;
    final total = ranking.fold<int>(0, (s, r) => s + r.score);
    final avg = ranking.isEmpty ? 0 : (total / ranking.length).round();
    final top = ranking.isEmpty ? null : ranking.first;
    final podium = ranking.take(3).toList();
    final maxScore = ranking.isEmpty ? 1.0 : ranking.first.score.toDouble();

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        ReportCard(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ReportField(
                      label: context.tr('نوع الفترة'),
                      child: ReportFileMenu(
                        value: _period,
                        values: _periods,
                        labelOf: (v) => context.tr(v),
                        onFileChanged: (v) => setState(() => _period = v),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: ReportButton(
                      label: context.tr('تحديث الترتيب'),
                      icon: Icons.refresh_rounded,
                      onTap: _updateRanking,
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
        ),

        if (ranking.isEmpty)
          ReportEmpty(
            icon: Icons.emoji_events_outlined,
            title: context.tr('لا يوجد ترتيب بعد'),
            message: context.tr('سيظهر الترتيب هنا بعد توفر البيانات'),
          )
        else ...[
          ReportHeroCard(
            badgeIcon: Icons.emoji_events_rounded,
            badge: context.tr('لوحة الشرف'),
            title: context.tr('الأعلى أداء'),
            value: top!.displayName,
            valueSize: 30,
            caption: context.tr(_metric),
            stats: [
              ReportHeroStat('${ranking.length}', context.tr('الموظفون المرتبون')),
              ReportHeroStat('$avg', context.tr('متوسط النتيجة')),
              ReportHeroStat('${top!.score}', context.tr('أعلى نتيجة')),
            ],
          ),

          ReportSectionTitle(context.tr('المراكز الأولى')),
          for (final r in podium)
            _PodiumCard(
              entry: r,
              metric: context.tr(_metric),
              color: _barColors[(r.rank - 1) % _barColors.length],
            ),
          SizedBox(height: 2.h),

          ReportCard(
            title: context.tr('لوحة الترتيب'),
            subtitle: context.tr('أعلى النتائج حسب المؤشر'),
            child: Column(
              children: [
                for (final r in ranking.take(10))
                  HBarRow(
                    inline: true,
                    label: r.displayName,
                    value: r.score.toDouble(),
                    max: maxScore,
                    color: _barColors[(r.rank - 1) % _barColors.length],
                    valueLabel: '${r.score}',
                  ),
              ],
            ),
          ),

          ReportCard(
            title: context.tr('الترتيب الكامل'),
            subtitle: context.tr(_metric),
            child: Column(
              children: [
                for (final r in ranking) _RankRow(entry: r),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.entry,
    required this.metric,
    required this.color,
  });

  final _Rank entry;
  final String metric;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: AppDecorations.card(context, radius: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5.w, color: color),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.r),
                  child: Row(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          entry.rank == 1
                              ? Icons.emoji_events_rounded
                              : Icons.star_rounded,
                          size: 24.sp,
                          color: color,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${entry.rank}',
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeightManager.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              entry.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(metric, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${entry.score}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 28.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});
  final _Rank entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeightManager.bold,
                color: primary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.score}', style: theme.textTheme.titleMedium),
              Text(context.tr('النتيجة'), style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}