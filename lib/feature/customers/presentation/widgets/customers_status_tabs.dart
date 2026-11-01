import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomersStatusTabs extends StatelessWidget {
  const CustomersStatusTabs({
    super.key,
    required this.selected,
    required this.totalCount,
    required this.countOf,
    required this.onSelected,
  });

  final String selected;
  final int totalCount;
  final int Function(LeadStatus) countOf;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.color;

    final tabs = <({String label, int count})>[
      (label: context.tr('الكل'), count: totalCount),
      for (final s in LeadStatus.values) (label: context.tr(s.label), count: countOf(s)),
    ];

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = tab.label == selected;

          return GestureDetector(
            onTap: () => onSelected(tab.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorManager.primaryColor
                    : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? ColorManager.primaryColor
                      : theme.dividerColor,
                ),

              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeightManager.semiBold,
                      color: isSelected ? ColorManager.iconColor : muted,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.25)
                          : theme.dividerColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${tab.count}',
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: 11.sp,
                        fontWeight: FontWeightManager.bold,
                        color: isSelected ? ColorManager.iconColor : muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}