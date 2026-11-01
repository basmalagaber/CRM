import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import 'performance_common_widgets.dart';

const List<String> kPerformanceEmployees = [
  'أحمد جوبا',
  'بسملة جابر',
  'محمد علي',
];

String perfFormatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String perfFormatDateTime(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final period = d.hour >= 12 ? 'م' : 'ص';
  return '${d.year}/${d.month}/${d.day} في '
      '${h12.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $period';
}

class PerfRowCard extends StatelessWidget {
  final Widget child;
  const PerfRowCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: PerfColors.tile(context, ColorManager.performanceBgBlue),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: PerfColors.divider(context)),
      ),
      child: child,
    );
  }
}

class PerfInfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const PerfInfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: PerfColors.muted(context),
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '-',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 11.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                    color: PerfColors.text(context),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class PerfEmptyData extends StatelessWidget {
  final String text;
  const PerfEmptyData({super.key, this.text = 'لا توجد بيانات'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded,
              size: 34.sp, color: PerfColors.muted(context)),
          SizedBox(height: 8.h),
          Text(
            text,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: PerfColors.muted(context),
            ),
          ),
        ],
      ),
    );
  }
}

class PerfDateField extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime?> onChanged;

  const PerfDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint = 'اختر تاريخ',
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: PerfColors.divider(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 16.sp, color: PerfColors.muted(context)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value == null ? hint : perfFormatDate(value!),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: value == null
                      ? PerfColors.muted(context)
                      : PerfColors.text(context),
                ),
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.close_rounded,
                    size: 16.sp, color: PerfColors.muted(context)),
              ),
          ],
        ),
      ),
    );
  }
}

class PerfPager extends StatelessWidget {
  final int page;
  final int totalPages;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  const PerfPager({
    super.key,
    required this.page,
    required this.totalPages,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  Widget _arrow(BuildContext context, IconData icon, int target, bool enabled) {
    return InkWell(
      onTap: enabled ? () => onPageChanged(target) : null,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Icon(
          icon,
          size: 20.sp,
          color: enabled
              ? PerfColors.text(context)
              : PerfColors.muted(context).withOpacity(0.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = totalPages < 1 ? 1 : totalPages;
    final hasPrev = page > 1;
    final hasNext = page < pages;

    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PopupMenuButton<int>(
            initialValue: pageSize,
            onSelected: onPageSizeChanged,
            itemBuilder: (_) => const [5, 10, 20, 50]
                .map((e) => PopupMenuItem(value: e, child: Text('$e')))
                .toList(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: PerfColors.divider(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pageSize',
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: PerfColors.text(context),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18.sp, color: PerfColors.muted(context)),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          _arrow(context, Icons.keyboard_double_arrow_right_rounded, 1, hasPrev),
          _arrow(context, Icons.chevron_right_rounded, page - 1, hasPrev),
          Container(
            width: 32.w,
            height: 32.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorManager.primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$page',
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: ColorManager.primaryColor,
              ),
            ),
          ),
          _arrow(context, Icons.chevron_left_rounded, page + 1, hasNext),
          _arrow(context, Icons.keyboard_double_arrow_left_rounded, pages,
              hasNext),
        ],
      ),
    );
  }
}