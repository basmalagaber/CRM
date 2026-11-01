import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivitiesFilterSection extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onFilterSelected;

  final int totalActivities;
  final int pendingActivities;
  final int approvedActivities;
  final int rejectedActivities;

  const ActivitiesFilterSection({
    super.key,
    this.onSearchChanged,
    this.onFilterSelected,
    required this.totalActivities,
    required this.pendingActivities,
    required this.approvedActivities,
    required this.rejectedActivities,
  });

  @override
  State<ActivitiesFilterSection> createState() =>
      _ActivitiesFilterSectionState();
}

class _ActivitiesFilterSectionState extends State<ActivitiesFilterSection> {
  static const String _allFilter = 'الكل';

  List<String> get _filters => [
    _allFilter,
    context.tr('في الانتظار'),
    context.tr('معتمد'),
    context.tr('مرفوض'),
  ];

  String _selectedFilter = _allFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: context.dir,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: widget.onSearchChanged,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14.sp,
                height: 1.3,
                color: theme.textTheme.titleLarge?.color,
              ),
              decoration: InputDecoration(
                fillColor: theme.cardTheme.color,
                hintText: context.tr('بحث بحالة النشاط...'),
                prefixIcon: Icon(Icons.search_rounded, size: 22.sp),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      widget.onFilterSelected?.call(filter);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                      child: Text(
                        filter == _allFilter ? context.tr(_allFilter) : filter,
                        style: TextStyle(
                          fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? ColorManager.iconColor
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    value: widget.totalActivities.toString(),
                    label: context.tr('الإجمالي'),
                    color: theme.textTheme.titleLarge?.color ??
                        ColorManager.textDarkColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatBox(
                    value: widget.pendingActivities.toString(),
                    label: context.tr('في الانتظار'),
                    color: isDark
                        ? ColorManager.approvalPendingFgDark
                        : ColorManager.approvalPendingFgLight,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatBox(
                    value: widget.approvedActivities.toString(),
                    label: context.tr('المعتمدة'),
                    color: isDark
                        ? ColorManager.approvalApprovedFgDark
                        : ColorManager.approvalApprovedFgLight,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatBox(
                    value: widget.rejectedActivities.toString(),
                    label: context.tr('المرفوضة'),
                    color: isDark
                        ? ColorManager.approvalRejectedFgDark
                        : ColorManager.approvalRejectedFgLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
      decoration: AppDecorations.card(context, radius: 18),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: theme.textTheme.titleSmall?.fontFamily,
              fontSize: 22.sp,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}