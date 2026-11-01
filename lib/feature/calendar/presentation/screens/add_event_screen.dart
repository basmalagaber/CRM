import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/calendar/data/calendar_models.dart';
import 'package:erp_system/feature/calendar/presentation/widgets/calendar_widgets.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key, this.initial, this.readOnly = false});

  final CalendarEvent? initial;
  final bool readOnly;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  static const List<int> _baseMinutes = [5, 10, 15, 30, 60, 120, 1440];

  late final TextEditingController _title =
  TextEditingController(text: widget.initial?.title ?? '');
  late final TextEditingController _desc =
  TextEditingController(text: widget.initial?.description ?? '');

  late DateTime _start;
  late DateTime _end;
  late CalendarEventType _type;
  late bool _reminder;
  late int _minutes;
  late DateTime _month;

  bool _titleError = false;
  String? _timeError;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, now.hour, now.minute);

    _start = e?.start ?? base;
    _end = e?.end ?? base.add(const Duration(hours: 1));
    _type = e?.type ?? CalendarEventType.meeting;
    _reminder = e?.reminderEnabled ?? true;
    _minutes = e?.reminderMinutes ?? 15;
    _month = DateTime(_start.year, _start.month);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _selectDay(DateTime d) {
    final duration = _end.difference(_start);
    setState(() {
      _start = DateTime(d.year, d.month, d.day, _start.hour, _start.minute);
      _end = _start.add(duration);
      _month = DateTime(d.year, d.month);
      _timeError = null;
    });
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  Widget _rtl(BuildContext context, Widget? child) => Directionality(
    textDirection: context.dir,
    child: child ?? const SizedBox.shrink(),
  );

  Future<void> _pick(bool isStart) async {
    final current = isStart ? _start : _end;

    final firstDate = isStart ? DateTime(2020) : DateUtils.dateOnly(_start);
    var initial = DateUtils.dateOnly(current);
    if (initial.isBefore(firstDate)) initial = firstDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: _rtl,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: _rtl,
    );
    if (time == null || !mounted) return;

    final picked =
    DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        final duration = _end.difference(_start);
        _start = picked;
        _end = picked.add(
          duration > Duration.zero ? duration : const Duration(hours: 1),
        );
        _month = DateTime(_start.year, _start.month);
        _timeError = null;
      } else {
        _end = picked;
        _timeError = null;
      }
    });
  }

  void _save() {
    final titleMissing = _title.text.trim().isEmpty;
    final timeInvalid = !_end.isAfter(_start);

    if (titleMissing || timeInvalid) {
      setState(() {
        _titleError = titleMissing;
        _timeError = timeInvalid
            ? context.tr('وقت النهاية لازم يكون بعد وقت البداية')
            : null;
      });
      return;
    }

    final event = CalendarEvent(
      id: widget.initial?.id ?? CalendarStore.nextId(_start),
      title: _title.text.trim(),
      description: _desc.text.trim(),
      type: _type,
      start: _start,
      end: _end,
      reminderEnabled: _reminder,
      reminderMinutes: _minutes,
      summary: widget.initial?.summary ?? '',
      summaryAt: widget.initial?.summaryAt,
    );

    if (_isEdit) {
      CalendarStore.update(event);
    } else {
      CalendarStore.add(event);
    }
    Navigator.pop(context, true);
  }

  InputDecoration _decoration(String hint, {String? error}) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: reportBorder(context)),
    );

    return InputDecoration(
      hintText: context.tr(hint),
      hintStyle: theme.textTheme.bodySmall,
      errorText: error,
      filled: true,
      fillColor:
      theme.inputDecorationTheme.fillColor ?? theme.scaffoldBackgroundColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: ColorManager.primaryColor, width: 1.4),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: ReportColors.red),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: ReportColors.red, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;
    final minuteValues = ({..._baseMinutes, _minutes}.toList()..sort());

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CalendarHeader(
                title: widget.readOnly
                    ? context.tr('عرض حدث')
                    : (_isEdit ? context.tr('تعديل حدث') : context.tr('إضافة حدث')),
                subtitle: widget.readOnly
                    ? context.tr('تفاصيل الحدث')
                    : context.tr('حددي التاريخ والتفاصيل'),
                backIcon: Icons.close_rounded,
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                  children: [
                    ReportCard(
                      title: context.tr('اختر تاريخ الحدث'),
                      subtitle: context.tr('اختاري اليوم ثم حددي وقت البداية والنهاية بدقة'),
                      child: IgnorePointer(
                        ignoring: widget.readOnly,
                        child: Opacity(
                          opacity: widget.readOnly ? 0.6 : 1,
                          child: _MonthPicker(
                            month: _month,
                            selected: _start,
                            onSelect: _selectDay,
                            onPrev: () => _shiftMonth(-1),
                            onNext: () => _shiftMonth(1),
                          ),
                        ),
                      ),
                    ),
                    _PreviewCard(
                      type: _type,
                      title: _title.text,
                      start: _start,
                      end: _end,
                    ),
                    IgnorePointer(
                      ignoring: widget.readOnly,
                      child: Opacity(
                        opacity: widget.readOnly ? 0.65 : 1,
                        child: ReportCard(
                          title: context.tr('تفاصيل الحدث'),
                          subtitle: widget.readOnly
                              ? context.tr('عرض حدث التقويم')
                              : (_isEdit
                              ? context.tr('تعديل حدث تقويم')
                              : context.tr('إضافة حدث تقويم')),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReportField(
                                label: context.tr('العنوان'),
                                child: TextField(
                                  controller: _title,
                                  style: theme.textTheme.titleSmall,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) =>
                                      setState(() => _titleError = false),
                                  decoration: _decoration(
                                    'اكتبي عنوان الحدث',
                                    error: _titleError
                                        ? context.tr('العنوان مطلوب')
                                        : null,
                                  ),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              ReportField(
                                label: context.tr('الوصف'),
                                child: TextField(
                                  controller: _desc,
                                  minLines: 3,
                                  maxLines: 4,
                                  style: theme.textTheme.titleSmall,
                                  decoration: _decoration('اكتبي وصف الحدث (اختياري)'),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              ReportField(
                                label: context.tr('تاريخ ووقت البداية'),
                                child: ReportDateField(
                                  text: calFmtDateTime(_start),
                                  onTap: () => _pick(true),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              ReportField(
                                label: context.tr('تاريخ ووقت النهاية'),
                                child: ReportDateField(
                                  text: calFmtDateTime(_end),
                                  onTap: () => _pick(false),
                                ),
                              ),
                              if (_timeError != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: Text(
                                    _timeError!,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: ReportColors.red),
                                  ),
                                ),
                              SizedBox(height: 14.h),
                              ReportField(
                                label: context.tr('نوع الحدث'),
                                child: ReportDropdown<CalendarEventType>(
                                  title: context.tr('نوع الحدث'),
                                  value: _type,
                                  values: CalendarEventType.values,
                                  labelOf: (t) => context.tr(t.label),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _type = v);
                                  },
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                      color: primary.withOpacity(0.35)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () => setState(
                                              () => _reminder = !_reminder),
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 24.r,
                                            height: 24.r,
                                            child: Checkbox(
                                              value: _reminder,
                                              activeColor: primary,
                                              materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                              onChanged: (v) => setState(
                                                      () => _reminder = v ?? false),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(context.tr('تفعيل التذكير'),
                                              style: theme.textTheme.titleSmall),
                                        ],
                                      ),
                                    ),
                                    if (_reminder) ...[
                                      SizedBox(height: 12.h),
                                      ReportField(
                                        label: context.tr('التذكير قبل الموعد'),
                                        child: ReportDropdown<int>(
                                          title: context.tr('التذكير قبل الموعد'),
                                          value: _minutes,
                                          values: minuteValues,
                                          labelOf: (m) => context.tr(calMinutesLabel(m)),
                                          onChanged: (v) {
                                            if (v != null)
                                              setState(() => _minutes = v);
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if ((widget.initial?.summary ?? '').isNotEmpty)
                      _SummaryCard(
                        text: widget.initial!.summary,
                        at: widget.initial!.summaryAt,
                      ),
                    Row(
                      children: [
                        if (!widget.readOnly) ...[
                          Expanded(
                            child: ReportButton(
                              label: _isEdit
                                  ? context.tr('تحديث')
                                  : context.tr('حفظ'),
                              icon: Icons.save_outlined,
                              onTap: _save,
                            ),
                          ),
                          SizedBox(width: 10.w),
                        ],
                        Expanded(
                          child: ReportButton(
                            label: context.tr('إلغاء'),
                            icon: Icons.close_rounded,
                            filled: false,
                            onTap: () => Navigator.pop(context),
                          ),
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
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.type,
    required this.title,
    required this.start,
    required this.end,
  });

  final CalendarEventType type;
  final String title;
  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final shownTitle = title.trim().isEmpty ? context.tr('حدث بدون عنوان') : title.trim();

    Widget line(IconData icon, String value) {
      return Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.92),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            ColorManager.primaryLightShade,
            ColorManager.primaryColor,
            ColorManager.primaryDarkShade,
          ],
        ),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(type.icon, size: 16.sp, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  context.tr(type.label),
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            shownTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          line(Icons.play_circle_outline_rounded, calFmtDateTime(start)),
          line(Icons.stop_circle_outlined, calFmtDateTime(end)),
        ],
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const List<String> _days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    final first = DateTime(month.year, month.month, 1);
    final offset = (first.weekday + 1) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final rows = ((offset + daysInMonth) / 7).ceil();

    return Column(
      children: [
        Row(
          children: [
            _NavButton(icon: Icons.chevron_right_rounded, onTap: onPrev),
            Expanded(
              child: Center(
                child: Text(
                  '${context.tr(calMonths[month.month - 1])} ${month.year}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            _NavButton(icon: Icons.chevron_left_rounded, onTap: onNext),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            for (final d in _days)
              Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final date = DateTime(
                          month.year, month.month, 1 - offset + r * 7 + c);
                      return _DayCell(
                        date: date,
                        inMonth: date.month == month.month,
                        isSelected: calSameDay(date, selected),
                        isToday: calSameDay(date, today),
                        hasEvents: CalendarStore.hasEventOn(date),
                        onTap: () => onSelect(date),
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: reportBorder(context)),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.isSelected,
    required this.isToday,
    required this.hasEvents,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final bool isSelected;
  final bool isToday;
  final bool hasEvents;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    final Color? textColor = isSelected
        ? Colors.white
        : inMonth
        ? theme.textTheme.titleSmall?.color
        : theme.textTheme.bodySmall?.color?.withOpacity(0.45);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 42.h,
        child: Center(
          child: Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? primary : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(color: primary, width: 1.2)
                  : null,

            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: isSelected
                        ? FontWeightManager.bold
                        : FontWeightManager.medium,
                    color: textColor,
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 3.r,
                    child: Container(
                      width: 4.r,
                      height: 4.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : primary,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.text, required this.at});

  final String text;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          color: primary.withOpacity(0.06),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4.w, color: primary),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(14.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_note_rounded,
                                size: 20.sp, color: primary),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(context.tr('الملخص'),
                                  style: theme.textTheme.titleSmall),
                            ),
                            if (at != null)
                              Text(
                                calFmtDateTime(at!),
                                textDirection: TextDirection.ltr,
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(text, style: theme.textTheme.bodyMedium),
                      ],
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