import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/clients/data/client_store.dart';
import 'package:erp_system/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

extension ClientOriginUi on ClientOrigin {
  Color get color {
    switch (this) {
      case ClientOrigin.newClient:
        return const Color(0xFF16A870);
      case ClientOrigin.existingClient:
        return ColorManager.primaryColor;
      case ClientOrigin.acceptedQuote:
        return const Color(0xFF9C6BFF);
    }
  }

  IconData get icon {
    switch (this) {
      case ClientOrigin.newClient:
        return Icons.person_add_alt_1_outlined;
      case ClientOrigin.existingClient:
        return Icons.history_rounded;
      case ClientOrigin.acceptedQuote:
        return Icons.request_quote_outlined;
    }
  }
}

String fmtClientDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

class ClientCard extends StatelessWidget {
  final ClientItem client;
  final VoidCallback? onTap;

  const ClientCard({super.key, required this.client, this.onTap});

  static const Color _whatsappGreen = Color(0xFF25D366);

  Future<void> _call(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = client.phone.trim();

    if (phone.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.tr('لا يوجد رقم هاتف لهذا العميل'))),
      );
      return;
    }

    try {
      final ok = await launchUrl(Uri(scheme: 'tel', path: phone));
      if (!ok) throw Exception('launch failed');
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.tr('تعذر فتح تطبيق الاتصال'))),
      );
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    var phone = client.phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.tr('لا يوجد رقم هاتف لهذا العميل'))),
      );
      return;
    }

    if (phone.startsWith('00')) {
      phone = phone.substring(2);
    } else if (phone.startsWith('0')) {
      phone = '20${phone.substring(1)}';
    }

    final text = Uri.encodeComponent(context.trArgs('مرحباً {name}', {'name': client.name}));
    final uri = Uri.parse('https://wa.me/$phone?text=$text');

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('launch failed');
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(context.tr('تعذر فتح واتساب، تأكد أنه مثبت على الجهاز'))),
      );
    }
  }

  Widget _info(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        bool ltr = false,
      }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18.sp, color: theme.textTheme.bodyMedium?.color),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: ltr ? TextDirection.ltr : null,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeightManager.semiBold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tag(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: ColorManager.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: ColorManager.primaryColor),
          SizedBox(width: 4.w),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final origin = client.origin;
    final color = origin.color;
    final initial = client.name.trim().isEmpty
        ? '؟'
        : client.name.trim().characters.first;
    final fill =
        theme.inputDecorationTheme.fillColor ?? ColorManager.fieldBg;

    return Directionality(
      textDirection: context.dir,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: AppDecorations.card(context, radius: 22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22.r),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 46.r,
                        height: 46.r,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              ColorManager.primaryLightShade,
                              ColorManager.primaryDarkShade,
                            ],
                          ),
                        ),
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: FontSize.s18.sp,
                            fontWeight: FontWeightManager.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              client.company.isEmpty ? '-' : client.company,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(origin.icon, size: 13.sp, color: color),
                            SizedBox(width: 4.w),
                            Text(
                              context.tr(origin.label),
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: 11.sp,
                                fontWeight: FontWeightManager.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Details
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _info(
                                context,
                                icon: Icons.person_outline_rounded,
                                label: context.tr('المسؤول'),
                                value: client.managerName,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _info(
                                context,
                                icon: Icons.event_available_outlined,
                                label: context.tr('تاريخ التحويل'),
                                value: fmtClientDate(
                                  client.lastConvertedAt ?? client.createdAt,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _info(
                                context,
                                icon: Icons.phone_outlined,
                                label: context.tr('الهاتف'),
                                value: client.phone,
                                ltr: true,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _info(
                                context,
                                icon: Icons.mail_outline_rounded,
                                label: context.tr('البريد الإلكتروني'),
                                value: client.email,
                                ltr: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (client.interests.isNotEmpty ||
                      client.quoteCode != null ||
                      client.convertedLeads.length > 1) ...[
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        if (client.interests.isNotEmpty)
                          _tag(
                            context,
                            Icons.home_work_outlined,
                            context.trArgs('{count} اهتمامات', {'count': client.interests.length}),
                          ),
                        if (client.quoteCode != null)
                          _tag(
                            context,
                            Icons.request_quote_outlined,
                            context.trArgs('عرض {code}', {'code': client.quoteCode!}),
                          ),
                        if (client.convertedLeads.length > 1)
                          _tag(
                            context,
                            Icons.merge_type_rounded,
                            context.trArgs('{count} عملاء محتملين', {'count': client.convertedLeads.length}),
                          ),
                      ],
                    ),
                  ],

                  SizedBox(height: 14.h),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _openWhatsApp(context),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            height: 46.h,
                            decoration: BoxDecoration(
                              color: _whatsappGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Assets.imagesActionWhatsapp,
                                  width: 22.w,
                                  height: 22.w,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  context.tr('واتساب'),
                                  style: TextStyle(
                                    fontFamily: FontConstants.fontFamily,
                                    fontSize: FontSize.s14.sp,
                                    fontWeight: FontWeightManager.bold,
                                    color: isDark
                                        ? _whatsappGreen
                                        : const Color(0xFF128C7E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _SquareAction(
                        icon: Icons.call_outlined,
                        onTap: () => _call(context),
                      ),
                      SizedBox(width: 10.w),
                      _SquareAction(
                        icon: Icons.info_outline_rounded,
                        onTap: onTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 46.h,
        height: 46.h,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(icon, color: primary, size: 22.sp),
      ),
    );
  }
}