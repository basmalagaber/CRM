import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/employee_performance/presentation/screens/employee_performance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';
import '../widgets/activity_item.dart';
import '../widgets/app_bar_screen.dart';
import '../widgets/clients_by_source_chart.dart';
import '../widgets/conversion_funnel_chart.dart';
import '../widgets/data_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.userName,
    required this.userInitial,
  });

  final String userName;
  final String userInitial;

  void _openEmployeePerformance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmployeePerformanceScreen()),
    );
  }

  String _greeting(BuildContext context) =>
      context.tr(DateTime.now().hour < 12 ? 'صباح الخير' : 'مساء الخير');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedDate = DateFormat(
      context.isArabic ? 'EEEE، d MMMM yyyy' : 'EEEE, d MMMM yyyy',
      context.isArabic ? 'ar' : 'en',
    ).format(DateTime.now());

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openEmployeePerformance(context),
        backgroundColor: ColorManager.primaryColor,
        foregroundColor: ColorManager.iconColor,
        elevation: 4,
        shape: const StadiumBorder(),
        icon: Icon(Icons.analytics_outlined, size: 22.sp),
        label: Text(
          context.tr('أداة الموظف'),
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeightManager.bold,
            color: ColorManager.iconColor,
          ),
        ),
      ),
      appBar: AppBarScreen(
        title: context.tr('الرئيسية'),
        userInitial: userInitial,
        onNotificationsTap: () {},
        onAvatarTap: () {},
      ),
      body: Directionality(
        textDirection: context.dir,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 96.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeightManager.medium,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${_greeting(context)}${context.isArabic ? '،' : ','} $userName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: FontSize.s24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text('👋', style: TextStyle(fontSize: 22.sp)),
                ],
              ),
              SizedBox(height: 16.h),

              // Hero
              SizedBox(height: 16.h),

              // Stats
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DataItem(
                        icon: Icons.people_alt_rounded,
                        num: 248,
                        title: 'إجمالي العملاء',
                        recent: '14+',
                        isPositive: true,
                        iconBackgroundColor: ColorManager.statusColor3,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DataItem(
                        icon: Icons.track_changes,
                        num: 97,
                        title: 'عملاء مؤهلون',
                        recent: '39%',
                        isPositive: true,
                        iconBackgroundColor: ColorManager.statusColor3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DataItem(
                        icon: Icons.trending_up_rounded,
                        num: 18,
                        title: 'صفقات رابحة',
                        recent: '1.2م AED',
                        isPositive: true,
                        iconBackgroundColor: ColorManager.statusColor1,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DataItem(
                        icon: Icons.warning_amber_rounded,
                        num: 9,
                        title: 'أنشطة متأخرة',
                        recent: '3 حرجة',
                        isPositive: false,
                        iconBackgroundColor: ColorManager.errorTitle,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Charts
              const ConversionFunnelChart(),
              SizedBox(height: 16.h),
              const ClientsBySourceChart(),
              SizedBox(height: 24.h),

              // Today's activities
              Row(
                children: [
                  Text(
                    context.tr('أنشطة اليوم'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 4.h,
                      ),
                      child: Text(
                        context.tr('عرض الكل'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: ColorManager.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              const ActivityItem(
                name: 'محمد الراشدي',
                description: 'متابعة العرض المُرسل الأسبوع الماضي',
                date: '2025-07-03',
                statusLabel: 'متأخر',
                statusColor: ColorManager.errorTitle,
                icon: Icons.call_rounded,
                iconColor: ColorManager.statusColor1,
              ),
              const ActivityItem(
                name: 'فاطمة الزهراوي',
                description: 'زيارة موقع برج نجمة الخليج',
                date: '2025-07-08',
                statusLabel: 'مخطط',
                statusColor: ColorManager.statusColor2,
                icon: Icons.calendar_today_rounded,
                iconColor: ColorManager.statusColor3,
              ),
              const ActivityItem(
                name: 'يوسف الحمدان',
                description: 'مناقشة شروط الدفع لعقد الربع الثالث',
                date: '2025-07-02',
                statusLabel: 'متأخر',
                statusColor: ColorManager.errorTitle,
                icon: Icons.call_rounded,
                iconColor: ColorManager.statusColor1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

