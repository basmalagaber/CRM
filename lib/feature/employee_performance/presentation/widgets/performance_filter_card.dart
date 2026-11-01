import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/reports/presentation/widgets/report_download_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import 'performance_common_widgets.dart';
import 'performance_export_service.dart';

class PerformanceFilterCard extends StatefulWidget {
  final String? selectedEmployee;

  final ValueChanged<String?> onEmployeeChanged;

  const PerformanceFilterCard({
    super.key,
    required this.selectedEmployee,
    required this.onEmployeeChanged,
  });

  @override
  State<PerformanceFilterCard> createState() => _PerformanceFilterCardState();
}

class _PerformanceFilterCardState extends State<PerformanceFilterCard> {
  static const List<String> _employees = [
    'أحمد جوبا',
    'بسملة جابر',
    'محمد علي',
  ];

  static const List<String> _periods = ['يومي', 'أسبوعي', 'شهري', 'سنوي'];

  static const String _excelLabel = 'تحميل Excel';
  static const String _pdfLabel = 'تحميل PDF';

  String period = 'يومي';
  String _exportChoice = _excelLabel;
  bool _downloading = false;

  Future<void> _download() async {
    final employee = widget.selectedEmployee;
    final messenger = ScaffoldMessenger.of(context);

    if (employee == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('من فضلك اختاري الموظف أولاً')),
      );
      return;
    }

    final format =
    _exportChoice == _pdfLabel ? ExportFormat.pdf : ExportFormat.excel;

    setState(() => _downloading = true);

    try {
      final report = PerformanceReport.sample(
        employee: employee,
        period: period,
      );

      await PerformanceExportService.export(report, format);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            format == ExportFormat.pdf
                ? 'تم تحميل ملف PDF'
                : 'تم تحميل ملف Excel',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('تعذر تحميل الملف، حاولي مرة أخرى')),
      );
      debugPrint('Export error: $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PerformanceSectionTitle(
            eyebrow: 'أداء CRM',
            title: 'فترة أداء CRM',
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: 'الموظف',
            child: LeadDropdown(
              value: widget.selectedEmployee,
              items: _employees,
              hint: 'اختر الموظف',
              onChanged: (v) {
                if (v == null) return;
                widget.onEmployeeChanged(v);
              },
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: 'فترة الأداء',
            child: ReportFileMenu(
              value: period,
              values: _periods,
              labelOf: (v) => v,
              onFileChanged: (v) => setState(() => period = v),
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: 'تصدير التقرير',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LeadDropdown(
                    value: _exportChoice,
                    items: const [_excelLabel, _pdfLabel],
                    hint: 'اختر الصيغة',
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _exportChoice = v);
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: _downloading ? null : _download,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 15.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          ColorManager.primaryColor,
                          ColorManager.primaryDarkShade,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),

                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_downloading)
                          SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        SizedBox(width: 6.w),
                        Text(
                          _downloading ? 'جارٍ...' : 'تحميل',
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
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