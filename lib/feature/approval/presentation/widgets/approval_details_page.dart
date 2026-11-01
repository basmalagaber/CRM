import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApprovalDetailsPage extends StatelessWidget {
  final Map<String, dynamic> approval;

  const ApprovalDetailsPage({super.key, required this.approval});

  Map<String, dynamic> get _source {
    final s = approval['source'];
    return s is Map ? Map<String, dynamic>.from(s) : const {};
  }

  String _pick(List<String> keys, {String fallback = ''}) {
    for (final k in keys) {
      for (final map in [approval, _source]) {
        final v = map[k];
        if (v == null) continue;
        final t = v.toString().trim();
        if (t.isNotEmpty && t != 'null') return t;
      }
    }
    return fallback;
  }

  String _orDash(String v) => v.isEmpty ? '-' : v;

  String _yesNo(BuildContext context, String v) {
    final x = v.toLowerCase();
    if (x == 'true' || x == 'yes' || x == 'نعم') return context.tr('نعم');
    if (x == 'false' || x == 'no' || x == 'لا') return context.tr('لا');
    return _orDash(v);
  }

  String get _title => _pick(['title']);
  String get _status => _pick(['approvalStatus'], fallback: 'في الانتظار');

  bool get _isActivity => _title.contains('نشاط');
  bool get _isApproved => _status == 'معتمد';
  bool get _isRejected => _status == 'مرفوض';

  String _statusEn(String ar) {
    switch (ar) {
      case 'معتمد':
        return 'Approved';
      case 'مرفوض':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AC.of(context);

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        backgroundColor: c.scaffold,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(bottom: BorderSide(color: c.border)),

                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            ColorManager.primaryLightShade,
                            ColorManager.primaryColor,
                          ],
                        ),

                      ),
                      child: Icon(
                        Icons.fact_check_outlined,
                        size: 22.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        context.tr('تفاصيل الطلب'),
                        style: _style(context, c, 20, bold: true),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: c.scaffold.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: c.border),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22.sp,
                          color: c.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _buildTopCard(context, c),
                      SizedBox(height: 14.h),
                      _buildTimelineCard(context, c),
                      SizedBox(height: 14.h),
                      _isActivity
                          ? _buildActivityCard(context, c)
                          : _buildCustomerCard(context, c),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(BuildContext context, AC c) {
    final colors = c.status(_status);

    return _Card(
      color: c.surfaceAlt,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: c.pill,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    context.tr(_orDash(_title)),
                    style: _style(context, c, 12, color: c.primary),
                  ),
                ),
                SizedBox(height: 6.h),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    _orDash(_pick(['code'])),
                    style: _style(context, c, 22, bold: true, color: c.textStrong),
                  ),
                ),
              ],
            ),
          ),
          _Chip(text: context.tr(_status), bg: colors.$1, fg: colors.$2),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, AC c) {
    final reason = _pick(['reason', 'description', 'notes']);
    final managerNote = _pick(['managerNote']);
    final decided = _isApproved || _isRejected;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.history_rounded, title: context.tr('مسار الطلب')),
          SizedBox(height: 14.h),
          _TimelineStep(
            icon: Icons.send_rounded,
            color: ColorManager.primaryColor,
            title: context.tr('تم تقديم الطلب'),
            user: _pick(['requester']),
            date: _pick(['date', 'createdAt']),
            showLine: true,
            extras: [
              if (reason.isNotEmpty) _NoteBox(label: context.tr('السبب'), value: reason),
            ],
          ),
          if (decided)
            _TimelineStep(
              icon: _isApproved ? Icons.check_rounded : Icons.close_rounded,
              color: _isApproved
                  ? ColorManager.statusColor1
                  : ColorManager.errorTitle,
              title: _isApproved ? context.tr('تم الاعتماد') : context.tr('تم الرفض'),
              user: _pick(['approvedBy', 'reviewedBy', 'manager', 'approver']),
              date: _pick(['approvedAt', 'reviewedAt', 'decidedAt']),
              showLine: false,
              extras: [
                if (managerNote.isNotEmpty)
                  _NoteBox(label: context.tr('ملاحظة المدير'), value: managerNote),
              ],
            )
          else
            _TimelineStep(
              icon: Icons.access_time_rounded,
              color: ColorManager.performanceOrange,
              title: context.tr('بانتظار المراجعة'),
              user: '',
              date: '',
              showLine: false,
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, AC c) {
    final status = _pick(['status', 'activityStatus']);
    final approvalColors = c.status(_status);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.calendar_today_outlined,
            title: context.tr('تفاصيل النشاط'),
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _orDash(_pick(['customer', 'prospect'])),
                      style: _style(context, c, 20, bold: true, color: c.textStrong),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.tr(_orDash(_pick(['type', 'activityType']))),
                      style: _style(context, c, 15, color: c.muted),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status.isNotEmpty) ...[
                    _LabeledChip(
                      label: context.tr('الحالة'),
                      text: context.tr(status),
                      bg: c.neutralChipBg,
                      fg: c.neutralChipFg,
                    ),
                    SizedBox(width: 10.w),
                  ],
                  _LabeledChip(
                    label: context.tr('حالة الاعتماد'),
                    text: context.tr(_status),
                    bg: approvalColors.$1,
                    fg: approvalColors.$2,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: c.border),
          SizedBox(height: 14.h),
          _InfoGrid(
            wideColumns: 4,
            items: [
              _Info(context.tr('المسؤول'), _orDash(_pick(['owner', 'requester'])), ltr: true),
              _Info(context.tr('البداية'), _orDash(_pick(['startDate']))),
              _Info(context.tr('النهاية'), _orDash(_pick(['endDate']))),
              _Info(context.tr('الوصف'), _orDash(_pick(['description', 'notes', 'reason']))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, AC c) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.manage_accounts_outlined,
            title: context.tr('بيانات العميل المحتمل'),
          ),
          SizedBox(height: 14.h),
          _InfoGrid(
            wideColumns: 5,
            items: [
              _Info(context.tr('المسؤول الجديد'), _orDash(_pick(['newOwner'])), ltr: true),
              _Info(context.tr('يتطلب قرار مشاركة السجل'), _yesNo(context, _pick(['requiresShareDecision']))),
              _Info(context.tr('إجراء مسؤول العميل'), _orDash(_pick(['ownerAction']))),
              _Info(context.tr('يوجد أنشطة على العميل'), _yesNo(context, _pick(['hasActivities']))),
              _Info(context.tr('عميل جديد'), _yesNo(context, _pick(['isNewCustomer']))),
              _Info(context.tr('حالة نشاط العميل'), _orDash(_pick(['activityStatus']))),
            ],
          ),
        ],
      ),
    );
  }
}

TextStyle _style(BuildContext context, AC c, double size, {bool bold = false, Color? color}) {
  return TextStyle(
    fontFamily: FontConstants.fontFamily,
    fontSize: size.sp,
    fontWeight: bold ? FontWeightManager.bold : FontWeight.normal,
    color: color ?? c.text,
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;

  const _Card({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    final c = AC.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: AppDecorations.card(
        context,
        radius: 22.r,
        color: color ?? c.surface,
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final c = AC.of(context);

    return Row(
      children: [
        Container(
          width: 34.r,
          height: 34.r,
          decoration: BoxDecoration(
            color: ColorManager.primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 19.sp, color: c.primary),
        ),
        SizedBox(width: 10.w),
        Text(title, style: _style(context, c, 15, bold: true)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Chip({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    final c = AC.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(text, style: _style(context, c, 12, bold: true, color: fg)),
    );
  }
}

class _LabeledChip extends StatelessWidget {
  final String label;
  final String text;
  final Color bg;
  final Color fg;

  const _LabeledChip({
    required this.label,
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final c = AC.of(context);

    return Column(
      children: [
        Text(label, style: _style(context, c, 11, color: c.muted)),
        SizedBox(height: 4.h),
        _Chip(text: text, bg: bg, fg: fg),
      ],
    );
  }
}

class _Info {
  final String label;
  final String value;
  final bool ltr;

  const _Info(this.label, this.value, {this.ltr = false});
}

class _InfoGrid extends StatelessWidget {
  final List<_Info> items;
  final int wideColumns;

  const _InfoGrid({required this.items, required this.wideColumns});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 600 ? wideColumns : 2;
        final spacing = 12.w;
        final itemWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols - 0.5;

        return Wrap(
          spacing: spacing,
          runSpacing: 14.h,
          children: items
              .map((i) => SizedBox(width: itemWidth, child: _InfoItem(info: i)))
              .toList(),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final _Info info;

  const _InfoItem({required this.info});

  @override
  Widget build(BuildContext context) {
    final c = AC.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(info.label, style: _style(context, c, 12, color: c.muted)),
        SizedBox(height: 4.h),
        Directionality(
          textDirection: info.ltr ? TextDirection.ltr : TextDirection.rtl,
          child: Text(
            info.value,
            style: _style(context, c, 15, bold: true, color: c.textStrong),
          ),
        ),
      ],
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String label;
  final String value;

  const _NoteBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = AC.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorManager.primaryLightShade,
                      ColorManager.primaryDarkShade,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: c.noteBg,
                  padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: _style(context, c, 11, color: c.muted)),
                      SizedBox(height: 4.h),
                      Text(value, style: _style(context, c, 15, color: c.textStrong)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String user;
  final String date;
  final bool showLine;
  final List<Widget> extras;

  const _TimelineStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.user,
    required this.date,
    required this.showLine,
    this.extras = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = AC.of(context);
    final hasMeta = user.isNotEmpty || date.isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36.w,
            child: Column(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,

                  ),
                  child: Icon(icon, color: Colors.white, size: 18.sp),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: c.line,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 16.h : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: _style(context, c, 16, bold: true)),
                  if (hasMeta) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        if (user.isNotEmpty) ...[
                          Icon(Icons.person_outline_rounded,
                              size: 16.sp, color: c.muted),
                          SizedBox(width: 4.w),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              user,
                              style: _style(context, c, 12, color: c.muted),
                            ),
                          ),
                        ],
                        if (user.isNotEmpty && date.isNotEmpty) ...[
                          SizedBox(width: 6.w),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              color: c.dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                        ],
                        if (date.isNotEmpty)
                          Flexible(
                            child: Text(
                              date,
                              style: _style(context, c, 12, color: c.muted),
                            ),
                          ),
                      ],
                    ),
                  ],
                  ...extras,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}