import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/notification/presentation/screens/notification_screen.dart';
import 'package:erp_system/feature/notification/presentation/widgets/notification_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';

class AppBarScreen extends StatelessWidget implements PreferredSizeWidget {
  final int notificationsCount;
  final String userInitial;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;
  final String title;

  const AppBarScreen({
    super.key,
    this.notificationsCount = 0,
    this.userInitial = 'ب',
    this.onNotificationsTap,
    this.onAvatarTap,
    this.title = "",
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.isArabic ? TextDirection.ltr : TextDirection.rtl,
      child: Material(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: NotificationStore.changes,
                      builder: (context, _, __) => _CircleIconButton(
                        icon: Icons.notifications_none_rounded,
                        badgeCount:
                        NotificationStore.unreadCountForCurrentUser(),
                        onTap: () {
                          onNotificationsTap?.call();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),

                  ],
                ),
                Row(
                  children: [
                    Text(
                      context.tr(title),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: FontSize.s22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ColorManager.primaryLightShade,
                              ColorManager.primaryDarkShade,
                            ],
                          ),

                        ),
                        child: Center(
                          child: Text(
                            userInitial,
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: FontSize.s18.sp,
                              fontWeight: FontWeightManager.bold,
                              color: ColorManager.iconColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    this.badgeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2C4E)
                    : ColorManager.borderLight,
              ),

            ),
            child: Icon(
              icon,
              size: 22.sp,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                constraints: BoxConstraints(minWidth: 18.r),
                height: 18.r,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorManager.errorTitle,
                  borderRadius: BorderRadius.circular(9.r),
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 10.sp,
                    height: 1.1,
                    fontWeight: FontWeightManager.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}