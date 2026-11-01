import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import 'performance_common_widgets.dart';

class OffersInvoicesCard extends StatelessWidget {
  const OffersInvoicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PerformanceCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PerformanceSectionTitle(
            eyebrow: 'أداء CRM',
            title: 'عروض الأسعار والمبيعات والفواتير',
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PerformanceLegendLine(
                      color: ColorManager.performanceGreen,
                      label: 'معتمدة ٢٢',
                    ),
                    PerformanceLegendLine(
                      color: ColorManager.performanceRed,
                      label: 'مرفوضة ٧',
                    ),
                    PerformanceLegendLine(
                      color: ColorManager.performanceOrange,
                      label: 'معلقة ١١',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              const PerformanceDonutChart(
                value: '٤٠',
                label: 'عرض سعر',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const PerformanceMetricTile(
            label: 'إجمالي عروض الأسعار',
            value: '٤٠',
            color: ColorManager.performanceBgBlue,
            compact: true,
          ),
          SizedBox(height: 8.h),
          const Row(
            children: [
              Expanded(
                child: PerformanceMetricTile(
                  label: 'إجمالي أوامر البيع المؤكدة',
                  value: '٥١',
                  color: ColorManager.performancePaleGreen,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: PerformanceMetricTile(
                  label: 'إجمالي أوامر البيع',
                  value: '٢',
                  color: ColorManager.performanceBgBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const PerformanceMetricTile(
            label: 'أوامر البيع المعلقة',
            value: '٣',
            color: ColorManager.performancePaleRed,
            compact: true,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: const Divider(
              color: ColorManager.performanceBorder,
              height: 1,
            ),
          ),
          const PerformanceProgressLine(
            label: 'الفواتير',
            firstLabel: 'مدفوعة ١٦٪',
            secondLabel: 'غير مدفوعة ٣٩٪',
          ),
        ],
      ),
    );
  }
}
