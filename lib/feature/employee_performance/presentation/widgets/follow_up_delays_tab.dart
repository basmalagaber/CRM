import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/lead_date_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/employee_performance/presentation/widgets/performance_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/colors_manager.dart';
import 'performance_common_widgets.dart';

class DelayItem {
  final String employee;
  final String lead;
  final DateTime followUpAt;
  final DateTime detectedAt;
  final int delayMinutes;
  final DateTime? resolvedAt;

  const DelayItem({
    required this.employee,
    required this.lead,
    required this.followUpAt,
    required this.detectedAt,
    required this.delayMinutes,
    this.resolvedAt,
  });

  bool get resolved => resolvedAt != null;
}

class FollowUpDelaysTab extends StatefulWidget {
  final String? selectedEmployee;
  final ValueChanged<String?> onEmployeeChanged;

  const FollowUpDelaysTab({
    super.key,
    required this.selectedEmployee,
    required this.onEmployeeChanged,
  });

  @override
  State<FollowUpDelaysTab> createState() => _FollowUpDelaysTabState();
}

class _FollowUpDelaysTabState extends State<FollowUpDelaysTab> {
  static const _statuses = ['الكل', 'مفتوحة', 'تم حلها'];

  final List<DelayItem> _items = [
    DelayItem(
      employee: 'أحمد جوبا',
      lead: 'شركة النور للتجارة',
      followUpAt: DateTime(2026, 10, 18, 10, 0),
      detectedAt: DateTime(2026, 10, 18, 16, 0),
      delayMinutes: 360,
    ),
    DelayItem(
      employee: 'أحمد جوبا',
      lead: 'مؤسسة الأفق',
      followUpAt: DateTime(2026, 10, 15, 12, 30),
      detectedAt: DateTime(2026, 10, 15, 15, 30),
      delayMinutes: 180,
      resolvedAt: DateTime(2026, 10, 15, 17, 10),
    ),
  ];

  DateTime? _from;
  DateTime? _to;
  String _status = 'الكل';
  DateTime? _appliedFrom;
  DateTime? _appliedTo;
  String _appliedStatus = 'الكل';
  int _page = 1;
  int _pageSize = 10;

  String _fmtDate(DateTime? d) {
    if (d == null) return 'اختر التاريخ';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate({required bool isTo}) async {
    final firstDate =
    isTo && _from != null ? DateUtils.dateOnly(_from!) : DateTime(2020);
    var initial = DateUtils.dateOnly((isTo ? _to : _from) ?? DateTime.now());
    if (initial.isBefore(firstDate)) initial = firstDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isTo) {
        _to = picked;
      } else {
        _from = picked;
        if (_to != null && DateUtils.dateOnly(_to!).isBefore(picked)) {
          _to = null;
        }
      }
    });
  }

  void _search() {
    setState(() {
      _appliedFrom = _from;
      _appliedTo = _to;
      _appliedStatus = _status;
      _page = 1;
    });
  }

  void _clear() {
    setState(() {
      _from = _to = _appliedFrom = _appliedTo = null;
      _status = _appliedStatus = 'الكل';
      _page = 1;
    });
  }

  List<DelayItem> get _filtered {
    final emp = widget.selectedEmployee;
    return _items.where((e) {
      if (emp != null && e.employee != emp) return false;
      if (_appliedStatus == 'مفتوحة' && e.resolved) return false;
      if (_appliedStatus == 'تم حلها' && !e.resolved) return false;
      if (_appliedFrom != null && e.detectedAt.isBefore(_appliedFrom!)) {
        return false;
      }
      if (_appliedTo != null &&
          e.detectedAt.isAfter(_appliedTo!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterCard(),
        if (widget.selectedEmployee == null)
          const PerformanceCardContainer(
            child: PerfEmptyData(text: 'اختاري الموظف لعرض التأخيرات'),
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
            eyebrow: 'الالتزام بالمتابعة',
            title: 'تأخيرات المتابعة',
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LeadLabeledField(
                  label: 'من تاريخ',
                  child: LeadDateField(
                    text: _fmtDate(_from),
                    onTap: () => _pickDate(isTo: false),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: LeadLabeledField(
                  label: 'إلى تاريخ',
                  child: LeadDateField(
                    text: _fmtDate(_to),
                    onTap: () => _pickDate(isTo: true),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LeadLabeledField(
            label: 'حالة التأخير',
            child: LeadDropdown(
              value: _status,
              items: _statuses,
              hint: 'الكل',
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46.h,
                  child: ElevatedButton.icon(
                    onPressed: _search,
                    icon: Icon(Icons.search_rounded, size: 20.sp),
                    label: Text(
                      'بحث',
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 46.h,
                child: OutlinedButton(
                  onPressed: _clear,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'مسح',
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ],
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
          if (visible.isEmpty)
            const PerfEmptyData()
          else
            for (final item in visible) _buildItem(item),
        ],
      ),
    );
  }

  Widget _buildItem(DelayItem item) {
    final color = item.resolved
        ? ColorManager.performanceGreen
        : ColorManager.performanceOrange;

    return PerfRowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.lead,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: PerfColors.text(context),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  item.resolved ? 'تم حلها' : 'مفتوحة',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          PerfInfoRow(
            label: 'موعد المتابعة',
            value: perfFormatDateTime(item.followUpAt),
          ),
          PerfInfoRow(
            label: 'وقت اكتشاف التأخير',
            value: perfFormatDateTime(item.detectedAt),
          ),
          PerfInfoRow(
            label: 'مدة التأخير',
            value: '${item.delayMinutes} دقيقة',
          ),
          PerfInfoRow(
            label: 'وقت الحل',
            value:
            item.resolvedAt == null ? '-' : perfFormatDateTime(item.resolvedAt!),
          ),
        ],
      ),
    );
  }
}