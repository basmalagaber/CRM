import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:erp_system/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'quote_history_screen.dart';
import 'quote_pdf_export.dart';
import 'quote_view_screen.dart';

class PriceCard extends StatelessWidget {
  final Map<String, dynamic> quote;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsapp;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onStatusChange;
  final bool? canApprove;

  const PriceCard({
    super.key,
    required this.quote,
    this.onTap,
    this.onWhatsapp,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
    this.canApprove,
  });

  static const Color _blue = ColorManager.primaryColor;
  static const Color _green = ColorManager.statusColor1;
  static const Color _red = ColorManager.errorTitle;
  static const Color _orange = ColorManager.performanceOrange;
  static const Color _whatsappGreen = Color(0xFF25D366);

  static const double _radius = 20;

  String _s(String key) => (quote[key] ?? '').toString().trim();

  String _date(String key) => _s(key).replaceAll('/', '-');

  bool get _isManager {
    final role = AppSession.role;
    if (role == null) return false;
    return AppSession.roleLabel(role).contains('مدير');
  }

  bool get _canApprove => canApprove ?? _isManager;

  String _displayStatus(BuildContext context, String status, String approval) {
    if (status == context.tr('مسودة')) {
      if (approval == context.tr('معتمد')) return context.tr('معتمد');
      if (approval == context.tr('مرفوض')) return context.tr('مرفوض');
    }
    return status;
  }

  String _effectiveApproval(BuildContext context, String status, String approval) {
    if (status == context.tr('مقبول')) return context.tr('معتمد');
    if (status == context.tr('مرفوض')) return context.tr('مرفوض');
    return approval;
  }

  Color _quoteStatusColor(BuildContext context, String status) {
    if (status == context.tr('مرسل')) return _orange;
    if (status == context.tr('مقبول') || status == context.tr('معتمد')) return _green;
    if (status == context.tr('مرفوض')) return _red;
    return _blue;
  }

  Color _approvalColor(BuildContext context, String status) {
    if (status == context.tr('معتمد')) return _green;
    if (status == context.tr('مرفوض')) return _red;
    return _orange;
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final phoneValue = _s('phone');
    var phone = phoneValue.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty) {
      _showMessage(context, context.tr('لا يوجد رقم هاتف لهذا العميل'));
      return;
    }

    if (phone.startsWith('00')) {
      phone = phone.substring(2);
    } else if (phone.startsWith('0')) {
      phone = '20${phone.substring(1)}';
    }

    final message = Uri.encodeComponent(
      context.trArgs('مرحباً {customer}، بخصوص عرض السعر رقم {number}', {
        'customer': _s('customer'),
        'number': _s('quoteNumber'),
      }),
    );

    final uri = Uri.parse('https://wa.me/$phone?text=$message');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showMessage(context, context.tr('تعذر فتح واتساب، تأكدي أنه مثبت على الجهاز'));
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, context.tr('تعذر فتح واتساب، حاولي مرة أخرى'));
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _changeStatus(BuildContext context, String newStatus) {
    QuoteLogStore.log(
      _s('quoteNumber'),
      QuoteLogOp.update,
      context.trArgs('تم تغيير حالة عرض السعر إلى {status}', {'status': newStatus}),
    );
    onStatusChange?.call(newStatus);
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => QuoteViewScreen(quote: quote)),
        );
        break;
      case 'history':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => QuoteHistoryScreen(quote: quote)),
        );
        break;
      case 'pdf':
        downloadQuotePdf(context, quote);
        break;
      case 'accept':
        if (_canApprove) _changeStatus(context, context.tr('مقبول'));
        break;
      case 'reject':
        if (_canApprove) _changeStatus(context, context.tr('مرفوض'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawStatus = _s('status').isEmpty ? context.tr('مسودة') : _s('status');
    final approval = _effectiveApproval(context, rawStatus, _s('approvalStatus'));
    final status = _displayStatus(context, rawStatus, approval);

    return Directionality(
      textDirection: TextDirection.rtl,
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
                  _buildHeader(context, theme, status),
                  SizedBox(height: 14.h),

                  _buildSummary(context, theme),
                  SizedBox(height: 12.h),

                  _buildDetails(context, theme, approval),

                  if (quote['convertedToClient'] == true) ...[
                    SizedBox(height: 10.h),
                    _buildConvertedNote(context),
                  ],
                  SizedBox(height: 14.h),

                  _buildActions(context, theme, rawStatus),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, String status) {
    final name = _s('customer').isEmpty ? context.tr('عميل غير محدد') : _s('customer');

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
          child: Icon(Icons.request_quote_outlined, size: 22.sp, color: _blue),
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
        _StatusChip(text: status, color: _quoteStatusColor(context, status)),
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
            textDirection: TextDirection.ltr,
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
                label: context.tr('رقم عرض السعر'),
                value: _s('quoteNumber'),
                align: CrossAxisAlignment.start,
              ),
            ),
            VerticalDivider(
              width: 24.w,
              thickness: 1,
              color: _blue.withOpacity(0.18),
            ),
            Expanded(
              child: block(
                label: context.tr('الإجمالي'),
                value: _s('total'),
                align: CrossAxisAlignment.end,
                color: _blue,
                size: FontSize.s18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ThemeData theme, String approval) {
    final lineColor = theme.dividerColor.withOpacity(0.5);
    final hasApproval = approval.isNotEmpty;

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
              icon: Icons.event_outlined,
              label: context.tr('تاريخ العرض'),
              value: _date('quoteDate'),
            ),
          ),
          Divider(height: 1, thickness: 1, color: lineColor),
          row(
            _InfoCell(
              icon: Icons.verified_outlined,
              label: context.tr('تاريخ الاعتماد'),
              value: _date('approvalDate'),
            ),
            _InfoCell(
              icon: Icons.fact_check_outlined,
              label: context.tr('حالة الاعتماد'),
              value: approval,
              ltr: false,
              valueColor: hasApproval ? _approvalColor(context, approval) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConvertedNote(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: _green.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18.sp, color: _green),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.tr('تم تحويل العميل المحتمل إلى عميل'),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s12.sp,
                fontWeight: FontWeightManager.semiBold,
                color: _green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme, String status) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: _whatsappGreen.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13.r),
            child: InkWell(
              onTap: () {
                onWhatsapp?.call();
                _openWhatsApp(context);
              },
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
        _buildMenu(context, theme, status),
      ],
    );
  }

  Widget _buildMenu(BuildContext context, ThemeData theme, String status) {
    final isOpen = (status == context.tr('مسودة') || status == context.tr('مرسل')) &&
        _s('approvalStatus') != context.tr('مرفوض');
    final canDecide = _canApprove && isOpen;

    return Container(
      height: 46.h,
      width: 46.w,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: PopupMenuButton<String>(
        tooltip: context.tr('المزيد من الإجراءات'),
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_horiz_rounded,
          size: 23.sp,
          color: theme.iconTheme.color,
        ),
        color: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        constraints: BoxConstraints(minWidth: 200.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.6)),
        ),
        onSelected: (value) => _onMenuSelected(context, value),
        itemBuilder: (_) => <PopupMenuEntry<String>>[
          _menuItem(context, 'view', context.tr('عرض'), Icons.visibility_outlined),
          _menuItem(context, 'history', context.tr('السجلات'), Icons.history_rounded),
          _menuItem(
            context,
            'pdf',
            context.tr('تحميل العرض PDF'),
            Icons.download_rounded,
          ),
          if (canDecide) ...[
            _menuItem(
              context,
              'accept',
              context.tr('قبول'),
              Icons.check_circle_outline_rounded,
            ),
            _menuItem(
              context,
              'reject',
              context.tr('رفض'),
              Icons.cancel_outlined,
              danger: true,
            ),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      BuildContext context,
      String value,
      String label,
      IconData icon, {
        bool danger = false,
      }) {
    final textColor = danger ? _red : Theme.of(context).textTheme.bodyLarge?.color;
    final iconColor = danger ? _red : Theme.of(context).textTheme.bodyMedium?.color;

    return PopupMenuItem<String>(
      value: value,
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeightManager.medium,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Icon(icon, size: 20.sp, color: iconColor),
          ],
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