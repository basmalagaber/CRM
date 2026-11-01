import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback? onWhatsapp;
  final VoidCallback? onMenu;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onWhatsapp,
    this.onMenu,
    this.onTap,
  });

  static const Color _blue = ColorManager.primaryColor;
  static const Color _green = ColorManager.statusColor1;
  static const Color _red = ColorManager.errorTitle;
  static const Color _orange = ColorManager.performanceOrange;
  static const Color _whatsappGreen = Color(0xFF25D366);

  static const double _radius = 20;

  String _s(String key) => (activity[key] ?? '').toString().trim();

  String _date(String key) => _s(key).replaceAll('/', '-');

  Color _approvalColor(String status) {
    switch (status) {
      case 'معتمد':
        return _green;
      case 'مرفوض':
        return _red;
      case 'في الانتظار':
      default:
        return _orange;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'مكالمة':
        return Icons.call_outlined;
      case 'بريد الكتروني':
      case 'بريد إلكتروني':
        return Icons.mail_outline_rounded;
      case 'رسالة نصية':
        return Icons.sms_outlined;
      case 'زيارة':
        return Icons.place_outlined;
      default:
        return Icons.event_note_outlined;
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    var phone = _s('phone').replaceAll(RegExp(r'[^0-9]'), '');

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

    final text = Uri.encodeComponent(
      context.trArgs('مرحباً {customer}، بخصوص النشاط رقم {code}', {
        'customer': _s('customer'),
        'code': _s('code'),
      }),
    );

    final uri = Uri.parse('https://wa.me/$phone?text=$text');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open WhatsApp');
      }

      onWhatsapp?.call();
    } catch (_) {
      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content:
          Text(context.tr('تعذر فتح واتساب، تأكدي أنه مثبت على الجهاز')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final approvalStatus =
    _s('approvalStatus').isEmpty ? 'في الانتظار' : _s('approvalStatus');

    return Directionality(
      textDirection: context.dir,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: AppDecorations.card(context, radius: _radius.r),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(_radius.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, theme, approvalStatus),
                  SizedBox(height: 14.h),

                  _buildSummary(context, theme),
                  SizedBox(height: 12.h),

                  _buildDetails(context, theme),
                  SizedBox(height: 14.h),

                  _buildActions(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, String approval) {
    final name =
    _s('customer').isEmpty ? context.tr('عميل غير محدد') : _s('customer');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42.r,
          height: 42.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _blue.withOpacity(0.09),
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Icon(_typeIcon(_s('type')), size: 22.sp, color: _blue),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s16.sp,
                  fontWeight: FontWeightManager.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              if (_s('code').isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  _s('code'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s12.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _StatusChip(
          text: context.tr(approval),
          color: _approvalColor(approval),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, ThemeData theme) {
    Widget block({
      required String label,
      required String value,
      required CrossAxisAlignment align,
      Color? color,
      double? size,
      TextDirection? direction,
    }) {
      return Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s12.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: direction,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: size ?? FontSize.s14.sp,
              fontWeight: FontWeightManager.bold,
              color: color ?? theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      );
    }

    final type = _s('type');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _blue.withOpacity(0.15)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: block(
                label: context.tr('نوع النشاط'),
                value: type.isEmpty ? '' : context.tr(type),
                align: CrossAxisAlignment.start,
                color: _blue,
                size: FontSize.s16.sp,
              ),
            ),
            VerticalDivider(
              width: 24.w,
              thickness: 1,
              color: _blue.withOpacity(0.18),
            ),
            Expanded(
              child: block(
                label: context.tr('المتابعة'),
                value: _s('followUp'),
                align: CrossAxisAlignment.end,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDetails(BuildContext context, ThemeData theme) {
    final lineColor = theme.dividerColor.withOpacity(0.5);

    Widget row(Widget a, Widget b) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: a),
            VerticalDivider(width: 1, thickness: 1, color: lineColor),
            Expanded(child: b),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: lineColor),
      ),
      child: Column(
        children: [
          row(
            _InfoCell(
              icon: Icons.badge_outlined,
              label: context.tr('المسؤول'),
              value: _s('owner'),
              ltr: false,
            ),
            _InfoCell(
              icon: Icons.confirmation_number_outlined,
              label: context.tr('كود الطلب'),
              value: _s('code'),
            ),
          ),
          Divider(height: 1, thickness: 1, color: lineColor),
          row(
            _InfoCell(
              icon: Icons.event_outlined,
              label: context.tr('من تاريخ'),
              value: _date('startDate'),
            ),
            _InfoCell(
              icon: Icons.event_available_outlined,
              label: context.tr('إلى تاريخ'),
              value: _date('endDate'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: _whatsappGreen.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13.r),
            child: InkWell(
              onTap: () => _openWhatsApp(context),
              borderRadius: BorderRadius.circular(13.r),
              child: Container(
                height: 46.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(color: _whatsappGreen.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.imagesActionWhatsapp,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        context.tr('تواصل عبر واتساب'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s12.sp,
                          fontWeight: FontWeightManager.bold,
                          color: _whatsappGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        _buildMenuButton(context, theme),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, ThemeData theme) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        onTap: onMenu,
        borderRadius: BorderRadius.circular(13.r),
        child: Container(
          height: 46.h,
          width: 46.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Icon(
            Icons.more_horiz_rounded,
            size: 23.sp,
            color: theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s12.sp,
                fontWeight: FontWeightManager.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool ltr;
  final Color? valueColor;

  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
    this.ltr = true,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              color: ColorManager.primaryColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.sp, color: ColorManager.primaryColor),
          ),
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
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 11.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value.isEmpty ? '—' : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: FontSize.s14.sp,
                      fontWeight: FontWeightManager.semiBold,
                      color: valueColor ?? theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}