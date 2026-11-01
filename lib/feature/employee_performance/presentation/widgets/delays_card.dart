import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import 'performance_common_widgets.dart';

class DelaysCard extends StatelessWidget {
  const DelaysCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PerformanceCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PerformanceSectionTitle(
            eyebrow: 'الالتزام بالمتابعة',
            title: 'تفاصيل تأخيرات المتابعة',
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'إجمالي التأخيرات',
                  value: '0',
                  color: ColorManager.performanceBgBlue,
                  compact: true,
                ),
              ),
              SizedBox(width: 6.w),
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'تم حلها',
                  value: '0',
                  color: ColorManager.performancePaleGreen,
                  compact: true,
                ),
              ),
              SizedBox(width: 6.w),
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'مفتوحة',
                  value: '0',
                  color: ColorManager.performancePaleYellow,
                  compact: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'متوسط (س)',
                  value: '0',
                  color: ColorManager.performanceBgBlue,
                  compact: true,
                ),
              ),
              SizedBox(width: 6.w),
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'أقصى (س)',
                  value: '0',
                  color: ColorManager.performancePaleRed,
                  compact: true,
                ),
              ),
              SizedBox(width: 6.w),
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'الالتزام',
                  value: '100%',
                  color: ColorManager.performancePaleGreen,
                  compact: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),
          Center(
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: ColorManager.performanceSuccessBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: ColorManager.performanceGreen,
                size: 26.sp,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'لا توجد تاخيرات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 11.sp,
              color: ColorManager.performanceMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }
}