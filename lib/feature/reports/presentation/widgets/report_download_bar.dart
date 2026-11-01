import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportDownloadBar extends StatelessWidget {
  const ReportDownloadBar({
    super.key,
    required this.file,
    required this.files,
    required this.onFileChanged,
    required this.onDownload,
    this.loading = false,
  });

  final String file;
  final List<String> files;
  final ValueChanged<String> onFileChanged;
  final VoidCallback onDownload;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ReportFileMenu(
            value: file,
            values: files,
            onFileChanged: onFileChanged,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 2,
          child: ReportButton(
            label: context.tr('تحميل'),
            icon: Icons.download_rounded,
            loading: loading,
            onTap: onDownload,
          ),
        ),
      ],
    );
  }
}

class ReportFileMenu extends StatefulWidget {
  const ReportFileMenu({
    super.key,
    required this.value,
    required this.values,
    required this.onFileChanged,
    this.labelOf,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onFileChanged;
  final String Function(String)? labelOf;

  @override
  State<ReportFileMenu> createState() => _ReportFileMenuState();
}

class _ReportFileMenuState extends State<ReportFileMenu> {
  bool _open = false;

  String _label(BuildContext context, String v) =>
      widget.labelOf?.call(v) ?? context.trArgs('تحميل {value}', {'value': v});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;
    final fill =
        theme.inputDecorationTheme.fillColor ?? theme.scaffoldBackgroundColor;

    return LayoutBuilder(
      builder: (context, c) {
        return PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          offset: Offset(0, 6.h),
          tooltip: '',
          padding: EdgeInsets.zero,
          elevation: 8,
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints.tightFor(width: c.maxWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: reportBorder(context)),
          ),
          onOpened: () => setState(() => _open = true),
          onCanceled: () => setState(() => _open = false),
          onSelected: (v) {
            setState(() => _open = false);
            widget.onFileChanged(v);
          },
          itemBuilder: (ctx) => [
            for (final v in widget.values)
              PopupMenuItem<String>(
                value: v,
                padding: EdgeInsets.zero,
                height: 46.h,
                child: _MenuItem(
                  text: _label(context, v),
                  selected: v == widget.value,
                ),
              ),
          ],
          child: Container(
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _open ? primary : reportBorder(context),
                width: _open ? 1.2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _label(context, widget.value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 22.sp,
                  color: _open ? primary : theme.textTheme.bodySmall?.color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.text, required this.selected});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    return Directionality(
      textDirection: context.dir,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        color: selected ? primary.withOpacity(0.10) : Colors.transparent,
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: selected ? primary : null,
                  fontWeight: selected ? FontWeight.w700 : null,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 20.sp, color: primary),
          ],
        ),
      ),
    );
  }
}