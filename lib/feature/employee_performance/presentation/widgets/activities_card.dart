import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import 'performance_common_widgets.dart';

class ActivitiesCard extends StatelessWidget {
  const ActivitiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const bars = [4.0, 8.0, 6.0, 14.0, 9.0, 12.0, 7.0];
    const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

    return PerformanceCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PerformanceSectionTitle(
            eyebrow: 'أداء CRM',
            title: 'الأنشطة والمكالمات والزيارات',
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'إجمالي الأنشطة',
                  value: '٤٦',
                  color: ColorManager.performanceBgBlue,
                ),
              ),
              SizedBox(width: 8.w),
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'الأنشطة المكتملة',
                  value: '٩٤',
                  color: ColorManager.performancePaleGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'الأنشطة المعلقة',
                  value: '٥١',
                  color: ColorManager.performancePaleYellow,
                ),
              ),
              SizedBox(width: 8.w),
              const Expanded(
                child: PerformanceMetricTile(
                  label: 'إجمالي المكالمات',
                  value: '٧٣',
                  color: ColorManager.performanceBgBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Text(
            'الأنشطة خلال الأسبوع',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 12.sp,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 118.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                bars.length,
                    (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${bars[index].toInt()}',
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: 10.sp,
                            color: PerfColors.muted(context),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          height: bars[index] * 5.h,
                          decoration: BoxDecoration(
                            color: index == 3
                                ? null
                                : PerfColors.chartBar(context),
                            gradient: index == 3
                                ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                ColorManager.primaryLightShade,
                                ColorManager.primaryDarkShade,
                              ],
                            )
                                : null,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          days[index],
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: 10.sp,
                            color: PerfColors.muted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}