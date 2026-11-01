import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/activities/presentation/screens/activities_screen.dart';
import 'package:erp_system/feature/approval/presentation/screens/approval_screen.dart';
import 'package:erp_system/feature/customers/presentation/screens/customers_screen.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:erp_system/feature/sales/presentation/screens/sales_screen.dart';
import 'package:erp_system/feature/users/presentation/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/home_screen.dart';
import '../widgets/bottom_navbar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.role,
    required this.userName,
    required this.userInitial,
    this.initialIndex = 4,
  });

  final UserRole role;
  final String userName;
  final String userInitial;
  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int currentIndex = widget.initialIndex;

  int? _salesView;
  final ValueNotifier<int> _salesPage = ValueNotifier<int>(0);

  late final List<Widget> _pages = [
    UsersScreen(
      userInitial: widget.userInitial,

    ),
    ApproveScreen(role: widget.role, userName: widget.userName),
    ValueListenableBuilder<int>(
      valueListenable: _salesPage,
      builder: (_, view, __) => IndexedStack(
        index: view,
        children: [
          ActivitiesScreen(role: widget.role, userName: widget.userName),
          SalesScreen(
            userInitial: widget.userInitial,
            userName: widget.userName,
            role: widget.role,
          ),
        ],
      ),
    ),
    CustomersScreen(
      role: widget.role,
      userInitial: widget.userInitial,
      userName: widget.userName,
    ),
    HomeScreen(userName: widget.userName, userInitial: widget.userInitial),
  ];

  @override
  void initState() {
    super.initState();
    AppSession.start(userName: widget.userName, role: widget.role);
    AppNavigation.requestedTab.addListener(_onTabRequested);
  }

  void _onTabRequested() {
    final tab = AppNavigation.requestedTab.value;
    if (tab == null) return;

    AppNavigation.requestedTab.value = null;
    if (mounted) setState(() => currentIndex = tab);
  }

  @override
  void dispose() {
    AppNavigation.requestedTab.removeListener(_onTabRequested);
    _salesPage.dispose();
    super.dispose();
  }


  Future<void> _onItemSelected(int index) async {
    if (index != AppNavigation.salesTab) {
      setState(() => currentIndex = index);
      return;
    }

    final choice = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: _SalesChooserSheet(selected: _salesView),
      ),
    );
    if (choice == null || !mounted) return;

    _salesPage.value = choice;
    setState(() {
      _salesView = choice;
      currentIndex = AppNavigation.salesTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: BottomNavbarScreen(
        currentIndex: currentIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}

class _SalesChooserSheet extends StatelessWidget {
  const _SalesChooserSheet({required this.selected});

  final int? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: context.dir,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2A2C4E)
                  : ColorManager.borderLight,
            ),

          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                context.tr('المبيعات'),
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: 4.h),
              Text(
                context.tr('اختار القسم اللي عايزة تفتحيه'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: FontSize.s12.sp,
                ),
              ),
              SizedBox(height: 18.h),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _SalesOptionCard(
                        icon: Icons.event_note_rounded,
                        title: 'الأنشطة',
                        subtitle: 'مكالمات واجتماعات ومتابعات',
                        isSelected: selected == 0,
                        onTap: () => Navigator.pop(context, 0),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _SalesOptionCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'عرض السعر',
                        subtitle: 'إنشاء ومتابعة العروض',
                        isSelected: selected == 1,
                        onTap: () => Navigator.pop(context, 1),
                      ),
                    ),
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

class _SalesOptionCard extends StatelessWidget {
  const _SalesOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = ColorManager.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 16.h),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              width: isSelected ? 1.6 : 1,
              color: isSelected
                  ? primary
                  : (isDark
                  ? const Color(0xFF2A2C4E)
                  : ColorManager.borderLight),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // علامة الاختيار
              PositionedDirectional(
                top: -8.h,
                start: -4.w,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1 : 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 20.sp,
                    color: primary,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58.r,
                    height: 58.r,
                    decoration: BoxDecoration(
                      color: isSelected ? primary : primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18.r),

                    ),
                    child: Icon(
                      icon,
                      size: 28.sp,
                      color: isSelected ? Colors.white : primary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    context.tr(title),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isSelected ? primary : null,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    context.tr(subtitle),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: FontSize.s12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}