import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/home/presentation/widgets/main_screen.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:erp_system/feature/notification/presentation/widgets/notification_card.dart';
import 'package:erp_system/feature/notification/presentation/widgets/notification_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _onlyUnread = false;


  void _open(BuildContext context, AppNotification n) {
    NotificationStore.markRead(n.id);

    int? tab;

    if (AppSession.isManager) {
      tab = AppNavigation.approvalsTab;
    } else if (n.targetTab != null) {
      tab = n.targetTab;
    } else {
      switch (n.type) {
        case AppNotificationType.approvalRequest:
          tab = AppNavigation.approvalsTab;
          break;
        case AppNotificationType.newLead:
          tab = AppNavigation.customersTab;
          break;
        case AppNotificationType.general:
          break;
      }
    }

    if (tab == null) return;

    final name = AppSession.userName ?? '';
    final role = AppSession.role;
    if (role == null) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainScreen(
          role: role,
          userName: name,
          userInitial: name.trim().isEmpty ? '؟' : name.trim().characters.first,
          initialIndex: tab!,
        ),
      ),
          (route) => false,
    );
  }


  String _groupOf(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;

    if (diff <= 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    return 'أقدم';
  }

  List<Object> _buildEntries(List<AppNotification> items) {
    final entries = <Object>[];
    String? lastGroup;

    for (final n in items) {
      final group = _groupOf(n.createdAt);
      if (group != lastGroup) {
        entries.add(group);
        lastGroup = group;
      }
      entries.add(n);
    }

    return entries;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = AppSession.isManager ? context.tr('إشعارات الإدارة') : context.tr('الإشعارات');

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: NotificationStore.changes,
            builder: (context, _, __) {
              final all = NotificationStore.forCurrentUser();
              final unread = all.where((n) => !n.isRead).length;
              final shown = _onlyUnread
                  ? all.where((n) => !n.isRead).toList()
                  : all;
              final entries = _buildEntries(shown);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: FontSize.s20.sp,
                                ),
                              ),
                              Text(
                                unread == 0
                                    ? context.tr('لا توجد إشعارات غير مقروءة')
                                    : context.trArgs('{count} غير مقروءة', {'count': unread}),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (unread > 0)
                          TextButton.icon(
                            onPressed:
                            NotificationStore.markAllReadForCurrentUser,
                            icon: Icon(Icons.done_all_rounded, size: 18.sp),
                            label: Text(
                              context.tr('تعليم الكل كمقروء'),
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: FontSize.s12.sp,
                                fontWeight: FontWeightManager.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: context.trArgs('الكل ({count})', {'count': all.length}),
                          selected: !_onlyUnread,
                          onTap: () => setState(() => _onlyUnread = false),
                        ),
                        SizedBox(width: 8.w),
                        _FilterChip(
                          label: context.trArgs('غير المقروءة ({count})', {'count': unread}),
                          selected: _onlyUnread,
                          onTap: () => setState(() => _onlyUnread = true),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: entries.isEmpty
                        ? _EmptyState(onlyUnread: _onlyUnread)
                        : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];

                        if (entry is String) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 0 : 8.h,
                              bottom: 10.h,
                            ),
                            child: Text(
                              context.tr(entry),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: FontSize.s12.sp,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          );
                        }

                        final n = entry as AppNotification;
                        return NotificationCard(
                          notification: n,
                          onTap: () => _open(context, n),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? ColorManager.primaryColor : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? ColorManager.primaryColor : theme.dividerColor,
          ),

        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeightManager.semiBold,
            color: selected
                ? ColorManager.iconColor
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool onlyUnread;

  const _EmptyState({required this.onlyUnread});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: ColorManager.primaryColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                onlyUnread
                    ? Icons.done_all_rounded
                    : Icons.notifications_none_rounded,
                size: 40.sp,
                color: ColorManager.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              onlyUnread ? context.tr('لا توجد إشعارات غير مقروءة') : context.tr('لا توجد إشعارات'),
              style: theme.textTheme.titleSmall,
            ),
            SizedBox(height: 6.h),
            Text(
              onlyUnread
                  ? context.tr('أنت على اطلاع بكل شيء')
                  : context.tr('ستظهر هنا الإشعارات الجديدة فور وصولها'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: FontSize.s12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}