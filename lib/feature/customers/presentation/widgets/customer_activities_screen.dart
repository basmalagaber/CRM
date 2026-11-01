import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/customers/presentation/widgets/activity_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerActivitiesScreen extends StatelessWidget {
  final String customerName;
  final String customerKey;

  const CustomerActivitiesScreen({
    super.key,
    required this.customerName,
    required this.customerKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const blue = Color(0xFF2F6BFF);

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Text(
                      context.tr('أنشطة وفرص العميل'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),

              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: ActivityStore.instance.changes,
                  builder: (context, _, __) {
                    final activities = ActivityStore.instance.of(customerKey);

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer card
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: blue.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52.w,
                                  height: 52.w,
                                  decoration: BoxDecoration(
                                    color: blue,
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('العميل المحتمل'),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(fontSize: 13.sp),
                                      ),
                                      Text(
                                        customerName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.cardTheme.color,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border:
                                    Border.all(color: theme.dividerColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        color: blue,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12.w),

                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr('الأنشطة'),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(fontSize: 12.sp),
                                          ),
                                          Text(
                                            '${activities.length}',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 18.h),

                          // Section title
                          Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: blue.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: const Icon(
                                  Icons.event_available_outlined,
                                  color: blue,
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('الأنشطة'),
                                      style:
                                      theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                    Text(
                                      context.tr('سجل التواصل والمتابعة للعميل'),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${activities.length}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 14.h),

                          if (activities.isEmpty)
                            _buildEmpty(context, theme, blue)
                          else
                            ...activities.map((a) => _buildActivity(theme, a)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme, Color blue) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: blue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, color: blue, size: 40.sp),
          SizedBox(height: 10.h),
          Text(
            context.tr('لا توجد أنشطة لهذا العميل'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.tr('لا توجد أنشطة مسجلة لهذا العميل حتى الآن.'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildActivity(ThemeData theme, Map<String, dynamic> a) {
    final icon = a['icon'] is IconData ? a['icon'] as IconData : Icons.event;
    final iconColor = a['iconColor'] is Color
        ? a['iconColor'] as Color
        : const Color(0xFF2F6BFF);
    final statusColor = a['statusColor'] is Color
        ? a['statusColor'] as Color
        : const Color(0xFF2ED47A);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (a['description'] ?? '').toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  (a['date'] ?? '').toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              (a['statusLabel'] ?? '').toString(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}