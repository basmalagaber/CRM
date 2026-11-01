import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_dialog_shell.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show NumberFormat;

import 'lead_dropdown.dart';
import 'lead_labeled_field.dart';
import 'lead_text_field.dart';

const List<String> kDealTypes = ['بيع', 'إيجار'];
const List<String> kInterestTypes = ['وحدة', 'مشروع'];
const List<String> kInterestLevels = ['منخفض', 'متوسط', 'عالي'];

const List<Map<String, dynamic>> kInterestUnits = [
  {'code': 'A-101', 'name': 'شقة 101 - برج النخبة', 'unitPrice': 1850000},
  {'code': 'A-204', 'name': 'شقة 204 - برج النخبة', 'unitPrice': 2100000},
  {'code': 'B-12', 'name': 'فيلا 12 - كمبوند الواحة', 'unitPrice': 6500000},
  {'code': 'C-305', 'name': 'دوبلكس 305 - ريفر سايد', 'unitPrice': 3400000},
  {'code': 'S-07', 'name': 'محل 07 - داون تاون مول', 'unitPrice': 2750000},
];

const List<Map<String, dynamic>> kInterestProjects = [
  {'code': 'P-01', 'name': 'برج النخبة', 'unitPrice': 1500000},
  {'code': 'P-02', 'name': 'كمبوند الواحة', 'unitPrice': 4200000},
  {'code': 'P-03', 'name': 'ريفر سايد', 'unitPrice': 2300000},
  {'code': 'P-04', 'name': 'داون تاون مول', 'unitPrice': 1900000},
];

String formatInterestPrice(num value) => NumberFormat('#,##0.##').format(value);

Future<Map<String, dynamic>?> showAddInterestDialog(
    BuildContext context, {
      Map<String, dynamic>? initial,
    }) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w),
        child: _AddInterestDialog(initial: initial),
      ),
    ),
  );
}

class _AddInterestDialog extends StatefulWidget {
  final Map<String, dynamic>? initial;

  const _AddInterestDialog({this.initial});

  @override
  State<_AddInterestDialog> createState() => _AddInterestDialogState();
}

class _AddInterestDialogState extends State<_AddInterestDialog> {
  final _notesController = TextEditingController();

  String _dealType = 'بيع';
  String _interestType = 'وحدة';
  String _level = 'متوسط';
  Map<String, dynamic>? _selectedItem;
  bool _showError = false;

  bool get _isEdit => widget.initial != null;

  List<Map<String, dynamic>> get _options =>
      _interestType == 'مشروع' ? kInterestProjects : kInterestUnits;

  String _pick(dynamic value, List<String> options, String fallback) {
    final s = value?.toString();
    return s != null && options.contains(s) ? s : fallback;
  }

  @override
  void initState() {
    super.initState();

    final i = widget.initial;
    if (i == null) return;

    _dealType = _pick(i['dealType'], kDealTypes, 'بيع');
    _interestType = _pick(i['interestType'], kInterestTypes, 'وحدة');
    _level = _pick(i['interestLevel'], kInterestLevels, 'متوسط');
    _notesController.text = (i['notes'] ?? '').toString();

    final name = (i['name'] ?? '').toString();
    if (name.isNotEmpty) {
      _selectedItem = {
        'code': (i['code'] ?? '').toString(),
        'name': name,
        'unitPrice': i['unitPrice'] ?? 0,
      };
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickItem() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ItemPickerSheet(
        title: context.trArgs('اختر {type}', {'type': context.tr(_interestType)}),
        items: _options,
        selectedCode: _selectedItem?['code']?.toString(),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _selectedItem = result;
      _showError = false;
    });
  }

  void _submit() {
    final item = _selectedItem;

    if (item == null) {
      setState(() => _showError = true);
      return;
    }

    Navigator.pop(context, <String, dynamic>{
      ...?widget.initial,
      'code': item['code'],
      'name': item['name'],
      'unitPrice': item['unitPrice'] ?? 0,
      'quantity': widget.initial?['quantity'] ?? 1,
      'unit': _interestType,
      'dealType': _dealType,
      'interestType': _interestType,
      'interestLevel': _level,
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _selectedItem;
    final String? itemTitle = item == null
        ? null
        : ((item['code'] ?? '').toString().isEmpty
        ? item['name'].toString()
        : '${item['code']} - ${item['name']}');

    return AppDialogShell(
      icon: Icons.home_work_outlined,
      title: context.tr(_isEdit ? 'تعديل اهتمام' : 'إضافة اهتمام'),
      description: context.tr('اختر نوع الصفقة ثم حدد الوحدة أو المشروع.'),
      confirmLabel: context.tr('حفظ'),
      confirmIcon: Icons.save_outlined,
      onConfirm: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LeadLabeledField(
                  label: context.tr('نوع الصفقة'),
                  child: LeadDropdown(
                    value: _dealType,
                    items: kDealTypes,
                    hint: context.tr('اختر...'),
                    onChanged: (v) {
                      if (v != null) setState(() => _dealType = v);
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: LeadLabeledField(
                  label: context.tr('مهتم بـ'),
                  child: LeadDropdown(
                    value: _interestType,
                    items: kInterestTypes,
                    hint: context.tr('اختر...'),
                    onChanged: (v) {
                      if (v == null || v == _interestType) return;
                      setState(() {
                        _interestType = v;
                        _selectedItem = null;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          LeadLabeledField(
            label: context.tr(_interestType),
            requiredField: true,
            child: _ItemField(
              title: itemTitle,
              hint: context.trArgs('ابحث عن {type}', {'type': context.tr(_interestType == 'مشروع' ? 'مشروع' : 'وحدة')}),
              errorText: _showError && _selectedItem == null
                  ? context.trArgs('يرجى اختيار {type}', {'type': context.tr(_interestType)})
                  : null,
              onTap: _pickItem,
            ),
          ),
          SizedBox(height: 10.h),

          LeadLabeledField(
            label: context.tr('مستوى الاهتمام'),
            child: LeadDropdown(
              value: _level,
              items: kInterestLevels,
              hint: context.tr('اختر...'),
              onChanged: (v) {
                if (v != null) setState(() => _level = v);
              },
            ),
          ),
          SizedBox(height: 10.h),

          LeadLabeledField(
            label: context.tr('ملاحظات'),
            child: LeadTextField(
              controller: _notesController,
              hintText: context.tr('أضف ملاحظات (اختياري)'),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemField extends StatelessWidget {
  final String? title;
  final String hint;
  final String? errorText;
  final VoidCallback onTap;

  const _ItemField({
    required this.title,
    required this.hint,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = title != null;
    final hasError = errorText != null;
    final errorColor = theme.colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor ?? theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: hasError ? errorColor : theme.dividerColor,
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18.sp,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    hasValue ? title! : hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: FontSize.s14.sp,
                      fontWeight: hasValue
                          ? FontWeightManager.medium
                          : FontWeightManager.regular,
                      color: hasValue
                          ? theme.textTheme.titleLarge?.color
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 3.h),
          Text(
            errorText!,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s12.sp,
              color: errorColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _ItemPickerSheet extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String? selectedCode;

  const _ItemPickerSheet({
    required this.title,
    required this.items,
    required this.selectedCode,
  });

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _query.trim().toLowerCase();

    final filtered = widget.items.where((item) {
      if (q.isEmpty) return true;
      return item['name'].toString().toLowerCase().contains(q) ||
          item['code'].toString().toLowerCase().contains(q);
    }).toList();

    return Directionality(
      textDirection: context.dir,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 10.h, bottom: 12.h),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Text(widget.title, style: theme.textTheme.titleMedium),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 13.sp,
                      height: 1.2,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr('بحث بالاسم أو الكود...'),
                      prefixIcon: Icon(Icons.search_rounded, size: 20.sp),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                    child: Text(
                      context.tr('لا توجد نتائج'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                      : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: theme.dividerColor),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected =
                          item['code'].toString() == widget.selectedCode;

                      return ListTile(
                        onTap: () => Navigator.pop(context, item),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        title: Text(
                          item['name'].toString(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: FontSize.s14.sp,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          '${item['code']} - ${formatInterestPrice(item['unitPrice'] as num)}',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp),
                        ),
                        trailing: isSelected
                            ? const Icon(
                          Icons.check_circle_rounded,
                          color: ColorManager.primaryColor,
                        )
                            : null,
                      );
                    },
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