
import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_exporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportColors {
  ReportColors._();

  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF14B8A6);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFE11D48);
  static const Color orange = Color(0xFFF97316);
  static const Color slate = Color(0xFF64748B);
  static const Color green = Color(0xFF10B981);
  static const Color deepTeal = Color(0xFF0F766E);
}

Color reportBorder(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2C4E)
        : ColorManager.borderLight;

void showReportSoon(BuildContext context, String what) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$what — قريباً')),
  );
}

Future<void> exportReport(
    BuildContext context,
    ReportTable table,
    ReportFileFormat format,
    ) async {
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(context.trArgs('جاري تجهيز ملف {label}...', {'label': format.label})),
      ),
    );

  try {
    final path = await ReportExporter.save(table, format);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text(
            path.isEmpty
                ? context.trArgs('تم حفظ ملف {label}', {'label': format.label})
                : context.trArgs('تم حفظ ملف {label}\n{path}', {'label': format.label, 'path': path}),
          ),
        ),
      );
  } catch (_) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr('تعذر تنزيل الملف، حاولي مرة أخرى')),
        ),
      );
  }
}


class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: AppDecorations.card(context, radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: theme.textTheme.titleMedium),
                      if (subtitle != null)
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: 14.h),
          ],
          child,
        ],
      ),
    );
  }
}

class ReportSectionTitle extends StatelessWidget {
  const ReportSectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 6.h,
        bottom: 10.h,
        left: 2.w,
        right: 2.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (subtitle != null)
            Text(subtitle!, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class ReportEmpty extends StatelessWidget {
  const ReportEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.primaryColor.withOpacity(0.10),
              ),
              child: Icon(
                icon,
                size: 36.sp,
                color: ColorManager.primaryColor,
              ),
            ),
            SizedBox(height: 14.h),
            Text(title, style: theme.textTheme.titleSmall),
            if (message != null) ...[
              SizedBox(height: 6.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ReportHeroStat {
  const ReportHeroStat(this.value, this.label);

  final String value;
  final String label;
}

class ReportHeroCard extends StatelessWidget {
  const ReportHeroCard({
    super.key,
    required this.badgeIcon,
    required this.badge,
    required this.title,
    required this.value,
    required this.stats,
    this.caption,
    this.valueSize = 38,
  });

  final IconData badgeIcon;
  final String badge;
  final String title;
  final String value;
  final String? caption;
  final double valueSize;
  final List<ReportHeroStat> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = ColorManager.primaryColor;
    final surface = theme.cardTheme.color ?? theme.colorScheme.surface;
    final border = reportBorder(context);
    final muted = theme.textTheme.bodySmall?.color;

    final statColors = <Color>[
      ReportColors.blue,
      ReportColors.green,
      ReportColors.amber,
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: border),

      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4.h,
              width: double.infinity,
              color: primary,
            ),

            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(isDark ? 0.18 : 0.09),
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                        child: Icon(
                          badgeIcon,
                          color: primary,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 11.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeightManager.bold,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeightManager.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: border),
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: primary,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(isDark ? 0.12 : 0.055),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            value,
                            maxLines: 1,
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: primary,
                              fontSize: valueSize.sp,
                              fontWeight: FontWeightManager.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (caption != null) ...[
                          SizedBox(height: 8.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 15.sp,
                                color: muted,
                              ),
                              SizedBox(width: 5.w),
                              Expanded(
                                child: Text(
                                  caption!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11.5.sp,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        if (i > 0)
                          Container(
                            width: 1,
                            height: 58.h,
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            color: border,
                          ),
                        Expanded(
                          child: _HeroStatView(
                            stat: stats[i],
                            color: statColors[i % statColors.length],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatView extends StatelessWidget {
  const _HeroStatView({
    required this.stat,
    required this.color,
  });

  final ReportHeroStat stat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat.value,
              maxLines: 1,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 19.sp,
                height: 1.2,
                fontWeight: FontWeightManager.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            stat.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10.5.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}


class ReportField extends StatelessWidget {
  const ReportField({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}

BoxDecoration _fieldDecoration(BuildContext context) {
  final theme = Theme.of(context);

  return BoxDecoration(
    color: theme.inputDecorationTheme.fillColor ??
        theme.scaffoldBackgroundColor,
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: reportBorder(context)),
  );
}

class ReportDropdown<T> extends StatelessWidget {
  const ReportDropdown({
    super.key,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    this.hint = 'اختر...',
    this.title,
  });

  final T? value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final String hint;
  final String? title;

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => _ReportPickerSheet<T>(
        title: title ?? hint,
        values: values,
        labelOf: labelOf,
        selected: value,
      ),
    );

    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? shown = value == null ? null : labelOf(value as T);

    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: _fieldDecoration(context),
        child: Row(
          children: [
            Expanded(
              child: Text(
                shown ?? hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: shown == null
                    ? theme.textTheme.bodySmall
                    : theme.textTheme.titleSmall,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22.sp,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportPickerSheet<T> extends StatelessWidget {
  const _ReportPickerSheet({
    required this.title,
    required this.values,
    required this.labelOf,
    required this.selected,
  });

  final String title;
  final List<T> values;
  final String Function(T) labelOf;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: reportBorder(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    final v = values[index];
                    final isSelected = v == selected;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Material(
                        color: isSelected
                            ? primary.withOpacity(0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14.r),
                        child: InkWell(
                          onTap: () => Navigator.pop(context, v),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 13.h,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    labelOf(v),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: isSelected ? primary : null,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 20.sp,
                                    color: primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportSegmented<T> extends StatelessWidget {
  const ReportSegmented({
    super.key,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    return Container(
      height: 46.h,
      padding: EdgeInsets.all(3.r),
      decoration: _fieldDecoration(context),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(v),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: v == value ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(11.r),

                  ),
                  child: Text(
                    labelOf(v),
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 13.sp,
                      fontWeight: FontWeightManager.bold,
                      color: v == value
                          ? Colors.white
                          : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReportDateField extends StatelessWidget {
  const ReportDateField({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: _fieldDecoration(context),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16.sp,
              color: ColorManager.primaryColor,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  text,
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportButton extends StatelessWidget {
  const ReportButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = true,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final primary = ColorManager.primaryColor;
    final fg = filled ? Colors.white : primary;

    return Material(
      color: filled ? primary : Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: filled
              ? BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),

          )
              : BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: primary.withOpacity(0.45),
            ),
          ),
          child: Center(
            child: loading
                ? SizedBox(
              width: 20.r,
              height: 20.r,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: fg,
              ),
            )
                : FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18.sp, color: fg),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 13.sp,
                      fontWeight: FontWeightManager.bold,
                      color: fg,
                    ),
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


class HBarRow extends StatelessWidget {
  const HBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.valueLabel,
    this.inline = false,
    this.labelWidth = 92,
  });

  final String label;
  final double value;
  final double max;
  final Color color;
  final String? valueLabel;
  final bool inline;
  final double labelWidth;

  Widget _bar(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    final track = reportBorder(context).withOpacity(0.6);

    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
            Container(
              height: 12.h,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Container(
                width: c.maxWidth * v,
                height: 12.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shownValue = valueLabel ?? value.toStringAsFixed(0);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp);
    final valueStyle = theme.textTheme.titleSmall?.copyWith(fontSize: 12.sp);

    if (inline) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          children: [
            SizedBox(
              width: labelWidth.w,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(child: _bar(context)),
            SizedBox(width: 8.w),
            SizedBox(
              width: 34.w,
              child: Text(
                shownValue,
                textAlign: TextAlign.end,
                style: valueStyle,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(child: Text(label, style: labelStyle)),
              Text(shownValue, style: valueStyle),
            ],
          ),
          SizedBox(height: 5.h),
          _bar(context),
        ],
      ),
    );
  }
}

class LegendItem {
  const LegendItem(this.color, this.label);

  final Color color;
  final String label;
}

class ReportLegend extends StatelessWidget {
  const ReportLegend({super.key, required this.items});

  final List<LegendItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 16.w,
      runSpacing: 6.h,
      children: [
        for (final i in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(
                  color: i.color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                i.label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp),
              ),
            ],
          ),
      ],
    );
  }
}

class ReportStatusChip extends StatelessWidget {
  const ReportStatusChip({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: FontConstants.fontFamily,
          fontSize: 11.sp,
          fontWeight: FontWeightManager.bold,
          color: color,
        ),
      ),
    );
  }
}

class ReportKeyValue extends StatelessWidget {
  const ReportKeyValue({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 12.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
