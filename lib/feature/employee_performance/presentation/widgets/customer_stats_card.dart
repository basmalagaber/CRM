import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import 'performance_common_widgets.dart';

class CustomerStatsCard extends StatelessWidget {
  const CustomerStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PerformanceCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PerformanceSectionTitle(
            eyebrow: 'أداء CRM',
            title: 'العملاء المحتملون والفرص',
          ),
          SizedBox(height: 14.h),
          const Row(
            children: [
              Expanded(
                child: PerformanceMetricTile(
                  label: 'إجمالي العملاء المحتملين',
                  value: '٨٤',
                  color: ColorManager.performanceBgBlue,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: PerformanceMetricTile(
                  label: 'العملاء المحولون إلى عميل',
                  value: '٧١',
                  color: ColorManager.performancePaleGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Row(
            children: [
              Expanded(
                child: PerformanceMetricTile(
                  label: 'إجمالي الفرص',
                  value: '٢٣',
                  color: ColorManager.performanceBgBlue,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: PerformanceMetricTile(
                  label: 'الفرص الرابحة',
                  value: '٤١',
                  color: ColorManager.performancePaleGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Row(
            children: [
              Expanded(
                child: PerformanceMetricTile(
                  label: 'الفرص الخاسرة',
                  value: '٦',
                  color: ColorManager.performancePaleRed,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: PerformanceMetricTile(
                  label: 'الفرص المعلقة',
                  value: '٢١',
                  color: ColorManager.performancePaleYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
