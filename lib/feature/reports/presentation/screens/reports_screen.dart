import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/reports/presentation/widgets/delays_tab.dart';
import 'package:erp_system/feature/reports/presentation/widgets/employee_compare_tab.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:erp_system/feature/reports/presentation/widgets/top_performers_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final List<_TabInfo> _tabs = [
    _TabInfo('مقارنة الموظفين', 'مقارنة أداء الموظفين', Icons.bar_chart_rounded),
    _TabInfo('الأعلى أداء', 'ترتيب الموظفين حسب الأداء', Icons.emoji_events_outlined),
    _TabInfo('المتأخرات', 'متابعة المتأخرات وحلها', Icons.schedule_rounded),
  ];

  late final TabController _controller = TabController(length: 3, vsync: this);
  final ValueNotifier<int> _refresh = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = reportBorder(context);
    final current = _controller.index;

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                child: Row(
                  children: [
                    _SquareButton(
                      icon: Icons.arrow_back_rounded,
                      border: border,
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('التقارير'),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: FontSize.s20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            context.tr(_tabs[current].subtitle),
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Expanded(
                          child: _TabPill(
                            info: _tabs[i],
                            selected: i == current,
                            onTap: () => _controller.animateTo(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 6.h),

              Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    EmployeeCompareTab(refresh: _refresh),
                    TopPerformersTab(refresh: _refresh),
                    DelaysTab(refresh: _refresh),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  const _TabInfo(this.label, this.subtitle, this.icon);
  final String label;
  final String subtitle;
  final IconData icon;
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.info,
    required this.selected,
    required this.onTap,
  });

  final _TabInfo info;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;
    final fg = selected ? Colors.white : theme.textTheme.bodySmall?.color;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),

        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(info.icon, size: 16.sp, color: fg),
            SizedBox(width: 6.w),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  context.tr(info.label),
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 11.5.sp,
                    fontWeight: selected
                        ? FontWeightManager.bold
                        : FontWeightManager.medium,
                    color: fg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.border,
    required this.onTap,
  });

  final IconData icon;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: border),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: theme.textTheme.titleLarge?.color,
        ),
      ),
    );
  }
}