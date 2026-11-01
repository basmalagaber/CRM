import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/employee_performance/presentation/widgets/performance_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import 'performance_common_widgets.dart';
import 'performance_export_service.dart';

class EvaluationItem {
  final String employee;
  final String manager;
  final String type;
  final String comment;
  final double rating;
  final DateTime createdAt;

  const EvaluationItem({
    required this.employee,
    required this.manager,
    required this.type,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}

class EmployeeEvaluationTab extends StatefulWidget {
  final String? selectedEmployee;
  final ValueChanged<String?> onEmployeeChanged;

  final bool showAddButton;

  const EmployeeEvaluationTab({
    super.key,
    required this.selectedEmployee,
    required this.onEmployeeChanged,
    this.showAddButton = true,
  });

  @override
  State<EmployeeEvaluationTab> createState() => EmployeeEvaluationTabState();
}

class EmployeeEvaluationTabState extends State<EmployeeEvaluationTab> {
  static const _types = ['يومي', 'أسبوعي', 'شهري', 'سنوي'];
  static const _excelLabel = 'تحميل Excel';
  static const _pdfLabel = 'تحميل PDF';

  static const _currentManager = 'H.Wazzer';

  final List<EvaluationItem> _items = [
    EvaluationItem(
      employee: 'أحمد جوبا',
      manager: 'H.Wazzer',
      type: 'أسبوعي',
      comment: 'سيسلسى',
      rating: 4.0,
      createdAt: DateTime(2026, 10, 7, 18, 57),
    ),
  ];

  String _query = '';
  String? _typeFilter;
  String _exportChoice = _excelLabel;
  bool _downloading = false;
  int _page = 1;
  int _pageSize = 10;

  List<EvaluationItem> get _filtered {
    final emp = widget.selectedEmployee;
    final list = _items.where((e) {
      if (emp != null && e.employee != emp) return false;
      if (_typeFilter != null && e.type != _typeFilter) return false;
      if (_query.trim().isNotEmpty) {
        final q = _query.trim();
        if (!e.comment.contains(q) &&
            !e.manager.toLowerCase().contains(q.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> openEditor() => _openEditor();

  Future<void> _openEditor({EvaluationItem? existing}) async {
    final employee = existing?.employee ?? widget.selectedEmployee;
    if (employee == null) {
      _snack('من فضلك اختاري الموظف أولاً');
      return;
    }

    final result = await showModalBottomSheet<EvaluationItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _EvaluationForm(
          employee: employee,
          manager: existing?.manager ?? _currentManager,
          types: _types,
          existing: existing,
        ),
      ),
    );

    if (result == null) return;
    setState(() {
      if (existing != null) {
        final i = _items.indexOf(existing);
        if (i != -1) _items[i] = result;
      } else {
        _items.add(result);
      }
    });
  }

  Future<void> _delete(EvaluationItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف التقييم'),
          content: const Text('هل أنتِ متأكدة من حذف هذا التقييم؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      setState(() => _items.remove(item));
    }
  }

  Future<void> _download() async {
    final employee = widget.selectedEmployee;
    if (employee == null) {
      _snack('من فضلك اختاري الموظف أولاً');
      return;
    }
    final format =
    _exportChoice == _pdfLabel ? ExportFormat.pdf : ExportFormat.excel;

    setState(() => _downloading = true);
    try {
      final rows = _filtered
          .map((e) => [
        '${e.type} - ${perfFormatDate(e.createdAt)}',
        '${e.rating.toStringAsFixed(1)} / 5 - ${e.comment}',
      ])
          .toList();

      await PerformanceExportService.export(
        PerformanceReport(
          employee: employee,
          period: 'تقييم الموظف',
          sections: [ReportSection(title: 'تقييمات الموظف', rows: rows)],
        ),
        format,
      );
      if (!mounted) return;
      _snack(format == ExportFormat.pdf
          ? 'تم تحميل ملف PDF'
          : 'تم تحميل ملف Excel');
    } catch (e) {
      if (!mounted) return;
      _snack('تعذر تحميل الملف، حاولي مرة أخرى');
      debugPrint('Export error: $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _reset() => setState(() {
    _query = '';
    _typeFilter = null;
    _page = 1;
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterCard(),
        if (widget.selectedEmployee == null)
          const PerformanceCardContainer(
            child: PerfEmptyData(text: 'اختاري الموظف لعرض التقييمات'),
          )
        else
          _buildListCard(),
      ],
    );
  }

  Widget _buildFilterCard() {
    return PerformanceCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PerformanceSectionTitle(
            eyebrow: 'تقييم الموظف',
            title: 'تقييمات الموظف',
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: 'الموظف',
            child: LeadDropdown(
              value: widget.selectedEmployee,
              items: kPerformanceEmployees,
              hint: 'اختر الموظف',
              onChanged: (v) {
                if (v == null) return;
                setState(() => _page = 1);
                widget.onEmployeeChanged(v);
              },
            ),
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: 'فترة الأداء',
            child: LeadDropdown(
              value: _typeFilter,
              items: _types,
              hint: 'كل الفترات',
              onChanged: (v) => setState(() {
                _typeFilter = v;
                _page = 1;
              }),
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
                _GradientButton(
                  icon: Icons.download_rounded,
                  label: _downloading ? 'جارٍ...' : 'تحميل',
                  loading: _downloading,
                  onTap: _downloading ? null : _download,
                ),
              ],
            ),
          ),
          if (widget.showAddButton) SizedBox(height: 14.h),
          if (widget.showAddButton)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () => _openEditor(),
                backgroundColor: ColorManager.primaryColor,
                foregroundColor: ColorManager.iconColor,
                elevation: 4,
                shape: const StadiumBorder(),
                icon: Icon(Icons.add_rounded, size: 22.sp),
                label: Text(
                  'إضافة تقييم',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeightManager.bold,
                    color: ColorManager.iconColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListCard() {
    final all = _filtered;
    final totalPages = (all.length / _pageSize).ceil().clamp(1, 9999);
    final page = _page.clamp(1, totalPages);
    final start = (page - 1) * _pageSize;
    final visible = all.skip(start).take(_pageSize).toList();

    return PerformanceCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() {
                    _query = v;
                    _page = 1;
                  }),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 12.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'بحث في التعليق أو المدير',
                    prefixIcon: Icon(Icons.search_rounded, size: 20.sp),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              TextButton(
                onPressed: _reset,
                child: Text(
                  'مسح',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (visible.isEmpty)
            const PerfEmptyData()
          else
            for (final item in visible) _buildItem(item),

        ],
      ),
    );
  }

  Widget _buildItem(EvaluationItem item) {
    return PerfRowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.employee,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: PerfColors.text(context),
                  ),
                ),
              ),
              SizedBox(
                width: 32.w,
                height: 32.w,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert_rounded,
                      size: 20.sp, color: PerfColors.muted(context)),
                  onSelected: (v) {
                    if (v == 'edit') _openEditor(existing: item);
                    if (v == 'delete') _delete(item);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          PerfInfoRow(
            label: 'التقييم',
            valueWidget: Row(
              children: [
                _StarsRow(rating: item.rating, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  '${item.rating.toStringAsFixed(1)} / 5',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: PerfColors.text(context),
                  ),
                ),
              ],
            ),
          ),
          PerfInfoRow(label: 'المدير', value: item.manager),
          PerfInfoRow(label: 'فترة الأداء', value: item.type),
          PerfInfoRow(label: 'التعليق', value: item.comment),
          PerfInfoRow(
            label: 'تاريخ الإضافة',
            value: perfFormatDateTime(item.createdAt),
          ),
        ],
      ),
    );
  }
}


class _StarsRow extends StatelessWidget {
  final double rating;
  final double size;
  final ValueChanged<int>? onTap;
  const _StarsRow({required this.rating, required this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating >= i + 0.5;
        final icon = filled
            ? Icons.star_rounded
            : half
            ? Icons.star_half_rounded
            : Icons.star_outline_rounded;
        return GestureDetector(
          onTap: onTap == null ? null : () => onTap!(i + 1),
          child: Icon(icon, size: size, color: ColorManager.performanceOrange),
        );
      }),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _GradientButton({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [ColorManager.primaryColor, ColorManager.primaryDarkShade],
          ),
          borderRadius: BorderRadius.circular(16.r),

        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 16.r,
                height: 16.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
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
    );
  }
}


class _EvaluationForm extends StatefulWidget {
  final String employee;
  final String manager;
  final List<String> types;
  final EvaluationItem? existing;

  const _EvaluationForm({
    required this.employee,
    required this.manager,
    required this.types,
    this.existing,
  });

  @override
  State<_EvaluationForm> createState() => _EvaluationFormState();
}

class _EvaluationFormState extends State<_EvaluationForm> {
  late String _type = widget.existing?.type ?? widget.types.first;
  late double _rating = widget.existing?.rating ?? 0;
  late final TextEditingController _comment =
  TextEditingController(text: widget.existing?.comment ?? '');
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _save() {
    if (_rating == 0) {
      setState(() => _error = 'من فضلك اختاري التقييم');
      return;
    }
    Navigator.pop(
      context,
      EvaluationItem(
        employee: widget.employee,
        manager: widget.manager,
        type: _type,
        comment: _comment.text.trim(),
        rating: _rating,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PerformanceSectionTitle(
                eyebrow: widget.employee,
                title: widget.existing == null ? 'إضافة تقييم' : 'تعديل التقييم',
              ),
              SizedBox(height: 16.h),
              LeadLabeledField(
                label: 'فترة الأداء',
                child: LeadDropdown(
                  value: _type,
                  items: widget.types,
                  hint: 'اختر الفترة',
                  onChanged: (v) {
                    if (v != null) setState(() => _type = v);
                  },
                ),
              ),
              SizedBox(height: 16.h),
              LeadLabeledField(
                label: 'التقييم',
                child: Row(
                  children: [
                    _StarsRow(
                      rating: _rating,
                      size: 32.sp,
                      onTap: (v) => setState(() {
                        _rating = v.toDouble();
                        _error = null;
                      }),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '${_rating.toStringAsFixed(1)} / 5',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: PerfColors.text(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: 10.sp,
                      color: ColorManager.performanceRed,
                    ),
                  ),
                ),
              SizedBox(height: 16.h),
              LeadLabeledField(
                label: 'التعليق',
                child: TextField(
                  controller: _comment,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 12.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب تعليقك',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'حفظ',
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
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