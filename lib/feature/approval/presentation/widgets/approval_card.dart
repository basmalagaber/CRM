import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_chat_dialog.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApprovalCard extends StatefulWidget {
  final Map<String, dynamic> approval;
  final bool isManager;
  final String userName;
  final VoidCallback? onTap;
  final VoidCallback? onView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ApprovalCard({
    super.key,
    required this.approval,
    required this.userName,
    this.onTap,
    this.onView,
    this.onApprove,
    this.onReject,
    this.isManager = false,
  });

  @override
  State<ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends State<ApprovalCard> {
  static const Color _blue = ColorManager.primaryColor;
  static const Color _green = ColorManager.statusColor1;
  static const Color _red = ColorManager.errorTitle;
  static const Color _orange = ColorManager.performanceOrange;

  String _s(String key) => (widget.approval[key] ?? '').toString().trim();

  String get _status =>
      _s('approvalStatus').isEmpty ? 'في الانتظار' : _s('approvalStatus');

  bool get _isPending => _status != 'معتمد' && _status != 'مرفوض';

  Color _statusColor(String status) {
    switch (status) {
      case 'معتمد':
        return _green;
      case 'مرفوض':
        return _red;
      default:
        return _orange;
    }
  }

  void _decide(String value) {
    if (value == 'approve') {
      widget.onApprove?.call();
    } else if (value == 'reject') {
      widget.onReject?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final title = _s('title');
    final statusColor = _statusColor(_status);

    final initial =
    title.isEmpty
        ? (_s('index').isEmpty ? 'ط' : _s('index'))
        : String.fromCharCode(title.runes.first);

    return Directionality(
      textDirection: context.dir,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: AppDecorations.card(context, radius: 18.r),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46.r,
                        height: 46.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _blue.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                        child: Text(
                          initial,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeightManager.bold,
                            color: _blue,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.isEmpty ? context.tr('طلب اعتماد') : title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: FontConstants.fontFamily,
                                fontWeight: FontWeightManager.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _s('code').isEmpty ? '—' : _s('code'),
                              textDirection: TextDirection.ltr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: FontSize.s12.sp,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _StatusChip(text: context.tr(_status), color: statusColor),
                      if (widget.isManager && _isPending) _buildMenu(theme),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withOpacity(0.65),
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _InfoItem(
                                icon: Icons.person_add_alt_1_outlined,
                                label: context.tr('المسؤول الجديد'),
                                value: _s('newOwner'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _InfoItem(
                                icon: Icons.badge_outlined,
                                label: context.tr('مقدم الطلب'),
                                value: _s('requester'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        _InfoItem(
                          icon: Icons.event_outlined,
                          label: context.tr('تاريخ الطلب'),
                          value: _s('date'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _CardButton(
                          icon: Icons.visibility_outlined,
                          label: context.tr('عرض التفاصيل'),
                          color: _blue,
                          filled: false,
                          onTap: widget.onView,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _CardButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: context.tr('الشات'),
                          color: _blue,
                          filled: true,
                          onTap: () => showApprovalChatDialog(
                            context,
                            approval: widget.approval,
                            userName: widget.userName,
                            onSubmit: (comment, image) async {
                              final bytes = image != null
                                  ? await image.readAsBytes()
                                  : null;

                              addApprovalMessage(
                                widget.approval,
                                sender: widget.userName,
                                text: comment,
                                imageBytes: bytes,
                              );
                            },
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
      ),
    );
  }

  Widget _buildMenu(ThemeData theme) {
    return PopupMenuButton<String>(
      tooltip: context.tr('إجراءات الطلب'),
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_vert_rounded,
        size: 22.sp,
        color: theme.iconTheme.color,
      ),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      onSelected: _decide,
      itemBuilder: (_) => [
        _menuItem(
          'approve',
          context.tr('قبول الطلب'),
          Icons.check_circle_outline_rounded,
          _green,
        ),
        const PopupMenuDivider(height: 1),
        _menuItem('reject', context.tr('رفض الطلب'), Icons.cancel_outlined, _red),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
      String value,
      String label,
      IconData icon,
      Color color,
      ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s14.sp,
              fontWeight: FontWeightManager.semiBold,
              color: color,
            ),
          ),
        ],
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
      constraints: BoxConstraints(maxWidth: 115.w),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10.r),
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 31.r,
          height: 31.r,
          decoration: BoxDecoration(
            color: ColorManager.primaryColor.withOpacity(0.09),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, size: 17.sp, color: ColorManager.primaryColor),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeightManager.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  const _CardButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : color;

    return Material(
      color: filled ? color : color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 46.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19.sp, color: foreground),
              SizedBox(width: 7.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s12.sp,
                    fontWeight: FontWeightManager.bold,
                    color: foreground,
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