import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';

class BottomNavbarScreen extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  final String salesLabel;

  const BottomNavbarScreen({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    this.salesLabel = 'المبيعات',
  });

  List<_NavItemData> get _items => [
    const _NavItemData(
      label: 'المستخدمين',
      icon: Icons.manage_accounts_rounded,
    ),
    const _NavItemData(
      label: 'الاعتمادات',
      icon: Icons.checklist_rtl_rounded,
    ),
    _NavItemData(label: salesLabel, icon: Icons.point_of_sale_rounded),
    const _NavItemData(
      label: 'العملاء المحتملون',
      icon: Icons.people_alt_rounded,
    ),
    const _NavItemData(label: 'الرئيسية', icon: Icons.grid_view_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = _items;

    final order = List<int>.generate(items.length, (i) => i);
    if (!context.isArabic) order.setAll(0, order.reversed.toList());

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
          child: Container(
            height: 74.h,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: theme.bottomNavigationBarTheme.backgroundColor ??
                  theme.cardTheme.color,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2C4E)
                    : ColorManager.borderLight,
              ),

            ),
            child: Row(
              children: [
                for (final index in order)
                  Expanded(
                    child: _NavItem(
                      data: items[index],
                      isSelected: index == currentIndex,
                      onTap: () => onItemSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;

  const _NavItemData({required this.label, required this.icon});
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;

    final selectedColor =
        navTheme.selectedItemColor ?? theme.colorScheme.primary;
    final unselectedColor = navTheme.unselectedItemColor ??
        theme.colorScheme.onSurface.withOpacity(0.6);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),

            ),
            child: Icon(
              data.icon,
              size: 22.sp,
              color: isSelected ? Colors.white : unselectedColor,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.tr(data.label),
              maxLines: 1,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 11.sp,
                height: 1.2,
                fontWeight: isSelected
                    ? FontWeightManager.bold
                    : FontWeightManager.medium,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}