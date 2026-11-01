import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';

class PerfColors {
  PerfColors._();

  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  static Color text(BuildContext c) =>
      Theme.of(c).textTheme.bodyLarge?.color ?? ColorManager.performanceNavy;

  static Color muted(BuildContext c) => isDark(c)
      ? (Theme.of(c).textTheme.bodyMedium?.color ??
      ColorManager.performanceMuted)
      : ColorManager.performanceMuted;

  static Color label(BuildContext c) =>
      isDark(c) ? muted(c) : ColorManager.performanceLabel;

  static Color divider(BuildContext c) => isDark(c)
      ? Theme.of(c).dividerColor
      : ColorManager.performanceBorder;

  static Color tile(BuildContext c, Color base) {
    if (!isDark(c)) return base;
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness(0.20)
        .withSaturation(hsl.saturation < 0.35 ? 0.35 : hsl.saturation)
        .toColor();
  }

  static Color chartBar(BuildContext c) => isDark(c)
      ? Theme.of(c).colorScheme.primary.withOpacity(0.35)
      : ColorManager.performanceChartBlue;

  static Color successBg(BuildContext c) => isDark(c)
      ? ColorManager.performanceGreen.withOpacity(0.18)
      : ColorManager.performanceSuccessBg;
}

class PerformanceSectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;

  const PerformanceSectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 36.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorManager.primaryLightShade,
                ColorManager.primaryDarkShade,
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: ColorManager.primaryColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  color: PerfColors.text(context),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PerformanceSmallLabel extends StatelessWidget {
  final String text;

  const PerformanceSmallLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: PerfColors.muted(context),
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class PerformanceMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool compact;

  const PerformanceMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 52.h : 70.h),
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: compact ? 8.h : 10.h,
      ),
      decoration: BoxDecoration(
        color: PerfColors.tile(context, color),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: compact ? 10.sp : 11.sp,
              color: PerfColors.label(context),
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: compact ? 18.sp : 23.sp,
              color: PerfColors.text(context),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceCardContainer extends StatelessWidget {
  final Widget child;

  const PerformanceCardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      padding: EdgeInsets.all(16.w),
      decoration: AppDecorations.card(context, radius: 22.r),
      child: child,
    );
  }
}

class PerformanceLegendLine extends StatelessWidget {
  final Color color;
  final String label;

  const PerformanceLegendLine({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 7.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 11.sp,
              color: PerfColors.muted(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceProgressLine extends StatelessWidget {
  final String label;
  final String firstLabel;
  final String secondLabel;

  const PerformanceProgressLine({
    super.key,
    required this.label,
    required this.firstLabel,
    required this.secondLabel,
  });

  @override
  Widget build(BuildContext context) {
    final muted = PerfColors.muted(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: 12.sp,
            color: PerfColors.text(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Row(
            children: [
              Expanded(
                flex: 58,
                child: SizedBox(
                  height: 8.h,
                  child: const ColoredBox(color: ColorManager.performanceGreen),
                ),
              ),
              Expanded(
                flex: 42,
                child: SizedBox(
                  height: 8.h,
                  child:
                  const ColoredBox(color: ColorManager.performanceOrange),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 7.h),
        Row(
          children: [
            Expanded(
              child: Text(
                firstLabel,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 9.sp,
                  color: muted,
                ),
              ),
            ),
            Expanded(
              child: Text(
                secondLabel,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 9.sp,
                  color: muted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PerformanceDonutChart extends StatelessWidget {
  final String value;
  final String label;

  const PerformanceDonutChart({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112.w,
      height: 112.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 106.w,
            height: 106.w,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 9.w,
              valueColor: AlwaysStoppedAnimation<Color>(
                PerfColors.tile(context, ColorManager.performancePaleOrange),
              ),
            ),
          ),
          SizedBox(
            width: 106.w,
            height: 106.w,
            child: CircularProgressIndicator(
              value: .68,
              strokeWidth: 9.w,
              strokeCap: StrokeCap.butt,
              valueColor: const AlwaysStoppedAnimation<Color>(
                ColorManager.performanceGreen,
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
          SizedBox(
            width: 106.w,
            height: 106.w,
            child: CircularProgressIndicator(
              value: .23,
              strokeWidth: 9.w,
              strokeCap: StrokeCap.butt,
              valueColor: const AlwaysStoppedAnimation<Color>(
                ColorManager.performanceRed,
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: PerfColors.text(context),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 9.sp,
                  color: PerfColors.muted(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}