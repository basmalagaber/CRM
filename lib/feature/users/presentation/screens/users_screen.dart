import 'dart:io';
import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/core/routes_manager/routes.dart';
import 'package:erp_system/core/theme/theme_provider.dart';
import 'package:erp_system/feature/calendar/presentation/screens/calendar_screen.dart';
import 'package:erp_system/feature/clients/presentation/screens/client_screen.dart';
import 'package:erp_system/feature/home/presentation/widgets/app_bar_screen.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:erp_system/feature/notification/presentation/widgets/notification_store.dart';
import 'package:erp_system/feature/reports/presentation/screens/reports_screen.dart';
import 'package:erp_system/feature/users/presentation/widgets/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserProfile {
  UserProfile._();

  static String email = 'ahmed.mahmoud@company.com';
  static String phone = '+20 100 123 4567';
  static String employeeId = 'EMP-00231';
  static String department = 'المبيعات';
  static String branch = 'القاهرة – المقر الرئيسي';
  static String joinDate = '15 مارس 2023';

  static int customersCount = 0;
  static int activitiesCount = 0;
  static int quotesCount = 0;

  static final ValueNotifier<String?> avatarPath =
  ValueNotifier<String?>(null);
}

class UsersScreen extends StatelessWidget {
  final String userInitial;

  const UsersScreen({super.key,
    required this.userInitial,

  });


  void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.tr(what)} — ${context.tr('قريباً')}'),
      ),
    );
  }


  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ctx.dir,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          title: Text(ctx.tr('تسجيل الخروج')),
          content: Text(
            ctx.tr('هل أنتِ متأكدة إنك عايزة تسجلي الخروج؟'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.tr('إلغاء')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5484D),
              ),
              child: Text(ctx.tr('خروج')),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !context.mounted) return;

    AppSession.clear();
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.loginScreen,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = AppSession.userName ?? '';
    final role = AppSession.role;

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        appBar: AppBarScreen(
          title: context.tr('الملف الشخصي'),
          userInitial: userInitial,
          onNotificationsTap: () {},
          onAvatarTap: () {},
        ),

        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            children: [
              // Header

              _ProfileHeroCard(
                name: name.isEmpty ? '—' : name,
                roleLabel: role == null
                    ? ''
                    : AppSession.roleLabel(role),
                email: UserProfile.email,
                onChangePhoto: () => _pickAvatar(context),
              ),

              _SectionHeader(
                title: 'المعلومات الشخصية',
                onAction: () => _soon(context, 'تعديل البيانات'),
              ),

              _InfoCard(
                rows: [
                  _InfoRowData(
                    Icons.person_outline_rounded,
                    'الاسم الكامل',
                    name.isEmpty ? '—' : name,
                  ),
                  _InfoRowData(
                    Icons.mail_outline_rounded,
                    'البريد الإلكتروني',
                    UserProfile.email,
                    ltr: true,
                  ),
                  _InfoRowData(
                    Icons.phone_outlined,
                    'رقم الهاتف',
                    UserProfile.phone,
                    ltr: true,
                  ),
                  _InfoRowData(
                    Icons.tag_rounded,
                    'الرقم الوظيفي',
                    UserProfile.employeeId,
                    ltr: true,
                  ),
                  _InfoRowData(
                    Icons.work_outline_rounded,
                    'القسم / الدور',
                    '${context.tr(UserProfile.department)} · '
                        '${role == null ? '' : context.tr(AppSession.roleLabel(role))}',
                    badge: 'نشط',
                  ),
                  _InfoRowData(
                    Icons.location_on_outlined,
                    'الفرع',
                    UserProfile.branch,
                  ),
                  _InfoRowData(
                    Icons.calendar_today_outlined,
                    'تاريخ الانضمام',
                    UserProfile.joinDate,
                  ),
                ],
              ),

              const _SectionHeader(title: 'الوصول السريع'),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.groups_rounded,
                        title: 'العملاء',
                        subtitle: 'بيانات العملاء',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ClientsScreen()),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.bar_chart_rounded,
                        title: 'التقارير',
                        subtitle: 'الأداء والمبيعات',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReportsScreen(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.calendar_month_outlined,
                        title: 'التقويم',
                        subtitle: 'المواعيد والأحداث',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CalendarScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const _SectionHeader(title: 'الإعدادات'),

              _CardShell(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return _SwitchRow(
                        icon: themeProvider.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        title:  themeProvider.isDarkMode
                            ? 'الوضع الداكن'
                            : 'الوضع الفاتح',
                        subtitle: themeProvider.isDarkMode
                            ? 'الوضع الداكن مفعّل'
                            : 'الوضع الفاتح مفعّل',
                        value: themeProvider.isDarkMode,
                        onChanged: themeProvider.setDarkMode,
                      );
                    },
                  ),
                  ValueListenableBuilder<Locale>(
                    valueListenable: AppSettings.locale,
                    builder: (_, locale, __) => _LanguageRow(
                      isArabic: locale.languageCode == 'ar',
                      onChanged: AppSettings.setArabic,
                    ),
                  ),
                  const _NotificationsSwitchRow(),
                ],
              ),

              SizedBox(height: 20.h),

              _LogoutButton(
                onTap: () => _confirmLogout(context),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Directionality(
          textDirection: ctx.dir,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(ctx.tr('اختيار من المعرض')),
                onTap: () => Navigator.pop(
                  ctx,
                  ImageSource.gallery,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(ctx.tr('التقاط صورة')),
                onTap: () => Navigator.pop(
                  ctx,
                  ImageSource.camera,
                ),
              ),
              if (UserProfile.avatarPath.value != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE5484D),
                  ),
                  title: Text(ctx.tr('حذف الصورة')),
                  onTap: () {
                    UserProfile.avatarPath.value = null;
                    Navigator.pop(ctx);
                  },
                ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (file != null) {
        UserProfile.avatarPath.value = file.path;
      }
    } catch (_) {
      if (context.mounted) {
        _soon(context, 'تعذر اختيار الصورة، تأكدي من الصلاحيات');
      }
    }
  }
}


class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.name,
    required this.roleLabel,
    required this.email,
    required this.onChangePhoto,
  });

  final String name;
  final String roleLabel;
  final String email;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ??
        theme.colorScheme.surface;

    final borderColor = isDark
        ? const Color(0xFF30384A)
        : const Color(0xFFE5EAF1);

    final secondaryColor = isDark
        ? const Color(0xFFAFB9C9)
        : const Color(0xFF778397);

    final initial = name.trim().isEmpty || name == '—'
        ? '؟'
        : name.trim().characters.first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: borderColor),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(
                initial: initial,
                onChangePhoto: onChangePhoto,
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('الملف الوظيفي'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 7.h),

                    Row(
                      children: [
                        Icon(
                          Icons.mail_outline_rounded,
                          size: 14.sp,
                          color: secondaryColor,
                        ),

                        SizedBox(width: 5.w),

                        Expanded(
                          child: Text(
                            email,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (roleLabel.isNotEmpty) ...[
                      SizedBox(height: 9.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.primaryColor
                              .withOpacity(isDark ? 0.20 : 0.09),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 14.sp,
                              color: isDark
                                  ? const Color(0xFF9AB8FF)
                                  : ColorManager.primaryColor,
                            ),

                            SizedBox(width: 5.w),

                            Text(
                              context.tr(roleLabel),
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: 11.sp,
                                fontWeight: FontWeightManager.bold,
                                color: isDark
                                    ? const Color(0xFF9AB8FF)
                                    : ColorManager.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Divider(
            height: 1,
            thickness: 1,
            color: borderColor,
          ),

          SizedBox(height: 16.h),

          Text(
            context.tr('ملخص العمل'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  icon: Icons.groups_outlined,
                  value: '${UserProfile.customersCount}',
                  label: 'العملاء',
                  color: const Color(0xFF3975E8),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: _HeroStat(
                  icon: Icons.task_alt_rounded,
                  value: '${UserProfile.activitiesCount}',
                  label: 'الأنشطة',
                  color: const Color(0xFF159A78),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: _HeroStat(
                  icon: Icons.request_quote_outlined,
                  value: '${UserProfile.quotesCount}',
                  label: 'عروض الأسعار',
                  color: const Color(0xFFAA75D5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initial,
    required this.onChangePhoto,
  });

  final String initial;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onChangePhoto,
      child: SizedBox(
        width: 78.r,
        height: 78.r,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: UserProfile.avatarPath,
              builder: (_, path, __) {
                final hasPhoto =
                    path != null && File(path).existsSync();

                return Container(
                  width: 72.r,
                  height: 72.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF27334A)
                        : const Color(0xFFEDF3FF),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF43516A)
                          : const Color(0xFFDCE7FC),
                      width: 2,
                    ),
                    image: hasPhoto
                        ? DecorationImage(
                      image: FileImage(File(path)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: hasPhoto
                      ? null
                      : Text(
                    initial,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 30.sp,
                      fontWeight: FontWeightManager.bold,
                      color: ColorManager.primaryColor,
                    ),
                  ),
                );
              },
            ),

            PositionedDirectional(
              bottom: 0,
              start: 0,
              child: Container(
                width: 27.r,
                height: 27.r,
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).cardTheme.color ??
                        Theme.of(context).colorScheme.surface,
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 13.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.24 : 0.13),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: color,
          ),

          SizedBox(height: 7.h),

          Text(
            value,
            maxLines: 1,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 19.sp,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            context.tr(label),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
              color: theme.textTheme.bodySmall?.color
                  ?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 22.h,
        bottom: 10.h,
        left: 2.w,
        right: 2.w,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.tr(title),
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(10.r),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actionIcon != null)
                      Icon(
                        actionIcon,
                        size: 15.sp,
                        color: ColorManager.primaryColor,
                      ),
                    SizedBox(width: 4.w),
                    Text(
                      context.tr(actionLabel!),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s12.sp,
                        fontWeight: FontWeightManager.bold,
                        color: ColorManager.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final divider = isDark
        ? const Color(0xFF30384A)
        : const Color(0xFFE5EAF1);

    final items = <Widget>[];

    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(
          Divider(
            height: 1,
            thickness: 1,
            color: divider,
          ),
        );
      }

      items.add(children[i]);
    }

    return Container(
      decoration: AppDecorations.card(context, radius: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(children: items),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    this.size = 40,
    this.danger = false,
  });

  final IconData icon;
  final double size;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? const Color(0xFFE5484D)
        : ColorManager.primaryColor;

    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Icon(
        icon,
        size: (size * 0.5).sp,
        color: color,
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData(
      this.icon,
      this.label,
      this.value, {
        this.ltr = false,
        this.badge,
      });

  final IconData icon;
  final String label;
  final String value;
  final bool ltr;
  final String? badge;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CardShell(
      children: [
        for (final r in rows)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            child: Row(
              children: [
                _IconBox(icon: r.icon),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(r.label),
                        style: theme.textTheme.bodySmall,
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        context.tr(r.value),
                        textDirection: r.ltr
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),

                if (r.badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FB67C)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      context.tr(r.badge!),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: 11.sp,
                        fontWeight: FontWeightManager.bold,
                        color: const Color(0xFF2FB67C),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: AppDecorations.card(context, radius: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBox(icon: icon, size: 40),

                SizedBox(height: 12.h),

                Text(
                  context.tr(title),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 3.h),

                Text(
                  context.tr(subtitle),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('فتح الصفحة'),
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s12.sp,
                          fontWeight: FontWeightManager.bold,
                          color: ColorManager.primaryColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18.sp,
                      color: ColorManager.primaryColor,
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 10.h,
        ),
        child: Row(
          children: [
            _IconBox(icon: icon),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(title),
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    context.tr(subtitle),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: ColorManager.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSwitchRow extends StatefulWidget {
  const _NotificationsSwitchRow();

  @override
  State<_NotificationsSwitchRow> createState() =>
      _NotificationsSwitchRowState();
}

class _NotificationsSwitchRowState
    extends State<_NotificationsSwitchRow> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return _SwitchRow(
      icon: Icons.notifications_none_rounded,
      title: 'الإشعارات',
      subtitle: 'تنبيهات الاعتمادات والعملاء',
      value: _enabled,
      onChanged: (v) => setState(() => _enabled = v),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.isArabic,
    required this.onChanged,
  });

  final bool isArabic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final border = isDark
        ? const Color(0xFF30384A)
        : const Color(0xFFE5EAF1);

    Widget chip(
        String label,
        bool selected,
        VoidCallback onTap,
        ) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: selected
                ? ColorManager.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s12.sp,
              fontWeight: FontWeightManager.bold,
              color: selected
                  ? Colors.white
                  : theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          const _IconBox(icon: Icons.language_rounded),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('اللغة'),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  context.tr('لغة التطبيق'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                chip(
                  'عربي',
                  isArabic,
                      () => onChanged(true),
                ),
                chip(
                  'English',
                  !isArabic,
                      () => onChanged(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE5484D);

    return Material(
      color: red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: red.withOpacity(0.30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 20.sp,
                color: red,
              ),

              SizedBox(width: 10.w),

              Text(
                context.tr('تسجيل الخروج'),
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 15.sp,
                  fontWeight: FontWeightManager.bold,
                  color: red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
