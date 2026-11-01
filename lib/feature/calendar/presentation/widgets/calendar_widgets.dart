import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/calendar/data/calendar_models.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension CalendarEventTypeUi on CalendarEventType {
  Color get color {
    switch (this) {
      case CalendarEventType.meeting:
        return ReportColors.blue;
      case CalendarEventType.travel:
        return ReportColors.deepTeal;
      case CalendarEventType.task:
        return ReportColors.green;
      case CalendarEventType.call:
        return ReportColors.teal;
      case CalendarEventType.other:
        return ReportColors.amber;
    }
  }

  IconData get icon {
    switch (this) {
      case CalendarEventType.meeting:
        return Icons.groups_rounded;
      case CalendarEventType.travel:
        return Icons.flight_takeoff_rounded;
      case CalendarEventType.task:
        return Icons.task_alt_rounded;
      case CalendarEventType.call:
        return Icons.call_rounded;
      case CalendarEventType.other:
        return Icons.event_rounded;
    }
  }
}

extension CalendarEventStatusUi on CalendarEventStatus {
  Color get color {
    switch (this) {
      case CalendarEventStatus.upcoming:
        return ReportColors.blue;
      case CalendarEventStatus.ongoing:
        return ReportColors.orange;
      case CalendarEventStatus.finished:
        return ReportColors.slate;
      case CalendarEventStatus.cancelled:
        return ReportColors.red;
    }
  }
}


class CalendarSquareButton extends StatelessWidget {
  const CalendarSquareButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: reportBorder(context)),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: theme.textTheme.titleLarge?.color,
        ),
      ),
    );
  }
}

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.backIcon = Icons.arrow_back_rounded,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final IconData backIcon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          CalendarSquareButton(icon: backIcon, onTap: onBack),
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
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          for (final a in actions) ...[
            SizedBox(width: 8.w),
            a,
          ],
        ],
      ),
    );
  }
}


class CalendarEventCard extends StatelessWidget {
  const CalendarEventCard({
    super.key,
    required this.event,
    required this.onAction,
  });

  final CalendarEvent event;
  final ValueChanged<CalendarEventAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = event.type.color;
    final status = event.status;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: AppDecorations.card(context, radius: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5.w, color: color),
              Expanded(
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
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(event.type.icon, size: 22.sp, color: color),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.id,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                    fontFamily: FontConstants.fontFamily,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeightManager.bold,
                                    color: color,
                                  ),
                                ),
                                Text(
                                  event.displayTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                          _ActionsMenu(onSelected: onAction),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: [
                          ReportStatusChip(text: event.type.label, color: color),
                          ReportStatusChip(text: status.label, color: status.color),
                          if (event.reminderEnabled)
                            ReportStatusChip(
                              text: 'تذكير قبل ${calMinutesLabel(event.reminderMinutes)}',
                              color: ReportColors.slate,
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _TimeLine(
                        icon: Icons.play_circle_outline_rounded,
                        label: 'البداية',
                        value: calFmtDateTime(event.start),
                      ),
                      SizedBox(height: 6.h),
                      _TimeLine(
                        icon: Icons.stop_circle_outlined,
                        label: 'النهاية',
                        value: calFmtDateTime(event.end),
                      ),
                      if (event.description.trim().isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(
                          event.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
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

class _TimeLine extends StatelessWidget {
  const _TimeLine({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 22.sp, color: theme.textTheme.bodySmall?.color),
        SizedBox(width: 6.w),
        Text(label, style: theme.textTheme.bodyLarge),
        SizedBox(width: 10.w),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.sp),
            ),
          ),
        ),
      ],
    );
  }
}

enum CalendarEventAction { view, summary, history, edit, delete }

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({required this.onSelected});

  final ValueChanged<CalendarEventAction> onSelected;

  PopupMenuItem<CalendarEventAction> _item(
      BuildContext context,
      CalendarEventAction value,
      IconData icon,
      String label, {
        bool danger = false,
      }) {
    final theme = Theme.of(context);
    final textColor = danger ? ReportColors.red : theme.textTheme.titleSmall?.color;
    final iconColor = danger ? ReportColors.red : theme.textTheme.bodySmall?.color;

    return PopupMenuItem<CalendarEventAction>(
      value: value,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            SizedBox(width: 12.w),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<CalendarEventAction>(
      onSelected: onSelected,
      padding: EdgeInsets.zero,
      tooltip: '',
      offset: Offset(0, 40.h),
      elevation: 6,
      color: theme.cardTheme.color,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: reportBorder(context)),
      ),
      itemBuilder: (ctx) => [
        _item(ctx, CalendarEventAction.view, Icons.visibility_outlined, 'عرض'),
        _item(ctx, CalendarEventAction.summary, Icons.edit_note_rounded,
            'إضافة ملخص'),
        _item(ctx, CalendarEventAction.history, Icons.history_rounded, 'السجل'),
        _item(ctx, CalendarEventAction.edit, Icons.edit_outlined, 'تعديل'),
        _item(ctx, CalendarEventAction.delete, Icons.delete_outline_rounded,
            'حذف',
            danger: true),
      ],
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: ReportColors.slate.withOpacity(0.10),
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 20.sp,
          color: theme.textTheme.titleLarge?.color,
        ),
      ),
    );
  }
}