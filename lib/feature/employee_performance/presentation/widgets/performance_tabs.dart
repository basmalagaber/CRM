import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/employee_performance/presentation/widgets/performance_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';

class PerformanceTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const PerformanceTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      'أداء الموظف',
      'تقييم الموظف',
      'تأخيرات المتابعة',
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.all(5.w),
      decoration: AppDecorations.card(context, radius: 20.r),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 3.w),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      ColorManager.primaryColor,
                      ColorManager.primaryDarkShade,
                    ],
                  )
                      : null,
                  borderRadius: BorderRadius.circular(15.r),

                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 11.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : PerfColors.muted(context),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}