import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/app_decorations.dart';

class _FunnelStage {
  final String label;
  final int value;
  final Color color;
  final double widthFactor;

  const _FunnelStage({
    required this.label,
    required this.value,
    required this.color,
    required this.widthFactor,
  });
}

class ConversionFunnelChart extends StatefulWidget {
  const ConversionFunnelChart({super.key});

  @override
  State<ConversionFunnelChart> createState() => _ConversionFunnelChartState();
}

class _ConversionFunnelChartState extends State<ConversionFunnelChart> {
  int? _selectedIndex = 0;

  static const List<_FunnelStage> _stages = [
    _FunnelStage(
      label: 'عملاء محتملون',
      value: 248,
      color: Color(0xFF2F6BFF),
      widthFactor: 1.0,
    ),
    _FunnelStage(
      label: 'تم التواصل',
      value: 184,
      color: Color(0xFF4D84FF),
      widthFactor: 0.78,
    ),
    _FunnelStage(
      label: 'مؤهلون',
      value: 94,
      color: Color(0xFF7B7FF5),
      widthFactor: 0.55,
    ),
    _FunnelStage(
      label: 'عروض أسعار',
      value: 41,
      color: Color(0xFFA48BFF),
      widthFactor: 0.32,
    ),
    _FunnelStage(
      label: 'صفقات رابحة',
      value: 18,
      color: Color(0xFF2ED47A),
      widthFactor: 0.14,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int firstValue = _stages.first.value;
    final selected = _selectedIndex == null ? null : _stages[_selectedIndex!];

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('مسار التحويل'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  context.tr('الربع الثاني 2025'),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          ...List.generate(_stages.length, (index) {
            final stage = _stages[index];
            final bool isSelected = _selectedIndex == index;
            final bool dimmed = _selectedIndex != null && !isSelected;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _stages.length - 1 ? 0 : 12.h,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => _selectedIndex = isSelected ? null : index);
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 88.w,
                      child: Text(
                        context.tr(stage.label),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? theme.textTheme.titleLarge?.color
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          Container(
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: stage.widthFactor,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: stage.color.withOpacity(
                                  dimmed ? 0.45 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 34.w,
                      child: Text(
                        '${stage.value}',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (selected != null) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: selected.color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    size: 18.sp,
                    color: selected.color,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      context.trArgs(
                        '{label}: {value} عميل ({pct}% من العملاء المحتملين)',
                        {
                          'label': context.tr(selected.label),
                          'value': selected.value,
                          'pct': (selected.value / firstValue * 100).round(),
                        },
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}