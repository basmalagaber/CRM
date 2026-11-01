import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'notification_store.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});


  String _formatDateTime(BuildContext context, DateTime d) {
    final isAm = d.hour < 12;
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = isAm ? context.tr('ص') : context.tr('م');
    return '${d.year}/${d.month}/${d.day} ${context.tr("في")} $hour12:$minute $period';
  }

  String _plural(BuildContext context, int n, String one, String two, String few, String many) {
    if (n == 1) return context.tr(one);
    if (n == 2) return context.tr(two);
    if (n >= 3 && n <= 10) return '$n ${context.tr(few)}';
    return '$n ${context.tr(many)}';
  }

  String _timeText(BuildContext context, DateTime d) {
    final diff = DateTime.now().difference(d);

    if (diff.inSeconds < 60) return context.tr('الآن');

    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return context.trArgs('منذ {time}', {'time': _plural(context, m, 'دقيقة', 'دقيقتين', 'دقائق', 'دقيقة')});
    }

    if (diff.inHours < 24) {
      final h = diff.inHours;
      return context.trArgs('منذ {time}', {'time': _plural(context, h, 'ساعة', 'ساعتين', 'ساعات', 'ساعة')});
    }

    return _formatDateTime(context, d);
  }

  (IconData, Color) _visual(AppNotification n) {
    final text = '${n.title} ${n.body}';

    if (text.contains('عرض سعر')) {
      return (Icons.request_quote_outlined, const Color(0xFF9C6BFF));
    }
    if (text.contains('نشاط')) {
      return (Icons.event_note_outlined, ColorManager.primaryColor);
    }
    if (text.contains('عميل')) {
      return (Icons.person_add_alt_1_outlined, const Color(0xFF16A870));
    }

    switch (n.type) {
      case AppNotificationType.approvalRequest:
        return (Icons.fact_check_outlined, const Color(0xFFF59E0B));
      case AppNotificationType.newLead:
        return (Icons.person_add_alt_1_outlined, const Color(0xFF16A870));
      case AppNotificationType.general:
        return (Icons.notifications_none_rounded, ColorManager.primaryColor);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unread = !notification.isRead;
    final primary = ColorManager.primaryColor;
    final (icon, accent) = _visual(notification);

    final baseColor = theme.cardTheme.color ?? theme.cardColor;
    final cardColor = unread
        ? Color.alphaBlend(primary.withOpacity(isDark ? 0.12 : 0.05), baseColor)
        : baseColor;

    return Directionality(
      textDirection: context.dir,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: AppDecorations.card(context, radius: 20, color: cardColor),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4.w,
                  color: unread ? primary : Colors.transparent,
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      child: Padding(
                        padding: EdgeInsets.all(14.r),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type icon
                            Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(isDark ? 0.20 : 0.12),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(icon, size: 22.sp, color: accent),
                            ),
                            SizedBox(width: 12.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontSize: FontSize.s14.sp,
                                          ),
                                        ),
                                      ),
                                      if (unread)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(
                                              isDark ? 0.22 : 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          child: Text(
                                            context.tr('جديد'),
                                            style: TextStyle(
                                              fontFamily:
                                              FontConstants.fontFamily,
                                              fontSize: 11.sp,
                                              fontWeight:
                                              FontWeightManager.bold,
                                              color: isDark
                                                  ? ColorManager
                                                  .approvalPrimaryDark
                                                  : primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    notification.body,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13.sp,
                                      height: 1.6,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 14.sp,
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        _timeText(context, notification.createdAt),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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