import 'package:erp_system/core/localization/app_strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/app_decorations.dart';
import 'chart_item.dart';

class _SourceData {
  final String label;
  final int value;
  final Color color;

  const _SourceData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class ClientsBySourceChart extends StatelessWidget {
  const ClientsBySourceChart({super.key});

  static const List<_SourceData> _sources = [
    _SourceData(label: 'الموقع', value: 82, color: Color(0xFF2F6BFF)),
    _SourceData(label: 'إحالة', value: 54, color: Color(0xFF2ED47A)),
    _SourceData(label: 'معرض', value: 38, color: Color(0xFFFFA726)),
    _SourceData(label: 'لينكد إن', value: 31, color: Color(0xFF9C6BFF)),
    _SourceData(label: 'اتصال بارد', value: 27, color: Color(0xFFE84C6D)),
    _SourceData(label: 'شريك', value: 16, color: Color(0xFF29C7E0)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int total = _sources.fold(0, (sum, item) => sum + item.value);

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('العملاء حسب المصدر'),
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: _sources
                      .map(
                        (item) => ChartItem(
                      color: item.color,
                      label: item.label,
                      value: item.value,
                      total: total,
                    ),
                  )
                      .toList(),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 128.r,
                height: 128.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 40.r,
                          startDegreeOffset: -90,
                          sections: _sources.map((item) {
                            return PieChartSectionData(
                              value: item.value.toDouble(),
                              color: item.color,
                              radius: 20.r,
                              showTitle: false,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: theme.textTheme.titleLarge?.copyWith(
                            height: 1.1,
                          ),
                        ),
                        Text(
                          context.tr('عميل'),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}