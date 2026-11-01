import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'customer_lead_item.dart';

enum MergeField {
  name,
  company,
  phone,
  manager,
  email,
  source,
  nextFollowUp,
}

extension MergeFieldData on MergeField {
  String get label {
    switch (this) {
      case MergeField.name:
        return 'الاسم';
      case MergeField.company:
        return 'الشركة';
      case MergeField.phone:
        return 'رقم الهاتف';
      case MergeField.manager:
        return 'المسؤول';
      case MergeField.email:
        return 'البريد الإلكتروني';
      case MergeField.source:
        return 'المصدر';
      case MergeField.nextFollowUp:
        return 'المتابعة القادمة';
    }
  }

  String valueOf(CustomerLeadItem c) {
    switch (this) {
      case MergeField.name:
        return c.name;
      case MergeField.company:
        return c.company;
      case MergeField.phone:
        return c.phoneNum ?? '';
      case MergeField.manager:
        return c.managerName ?? '';
      case MergeField.email:
        return c.email ?? '';
      case MergeField.source:
        return c.source ?? '';
      case MergeField.nextFollowUp:
        return c.nextFollowUp ?? '';
    }
  }
}

class MergeResult {
  final CustomerLeadItem duplicate;
  final Set<MergeField> takeFromDuplicate;

  const MergeResult({
    required this.duplicate,
    required this.takeFromDuplicate,
  });
}

Future<MergeResult?> showMergeCustomerDialog(
    BuildContext context, {
      required CustomerLeadItem current,
      required List<CustomerLeadItem> candidates,
    }) {
  return showDialog<MergeResult>(
    context: context,
    builder: (_) => _MergeDialog(current: current, candidates: candidates),
  );
}

class _MergeDialog extends StatefulWidget {
  final CustomerLeadItem current;
  final List<CustomerLeadItem> candidates;

  const _MergeDialog({required this.current, required this.candidates});

  @override
  State<_MergeDialog> createState() => _MergeDialogState();
}

class _MergeDialogState extends State<_MergeDialog> {
  late final Map<String, CustomerLeadItem> _byLabel;
  String? _selected;
  bool _showError = false;

  final Set<MergeField> _takeFromDuplicate = {};

  CustomerLeadItem? get _duplicate =>
      _selected == null ? null : _byLabel[_selected];

  List<MergeField> get _conflicts {
    final dup = _duplicate;
    if (dup == null) return const [];

    return MergeField.values.where((f) {
      final a = f.valueOf(widget.current).trim();
      final b = f.valueOf(dup).trim();
      return a.isNotEmpty && b.isNotEmpty && a != b;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    final currentPhone = widget.current.phoneNum?.trim() ?? '';
    final currentName = widget.current.name.trim();

    int score(CustomerLeadItem c) {
      var s = 0;
      final phone = c.phoneNum?.trim() ?? '';
      if (phone.isNotEmpty && phone == currentPhone) s += 2;
      if (c.name.trim() == currentName) s += 1;
      return s;
    }

    final sorted = [...widget.candidates]
      ..sort((a, b) => score(b).compareTo(score(a)));

    _byLabel = {};
    for (final c in sorted) {
      var label = c.phoneNum?.trim().isNotEmpty == true
          ? '${c.name} - ${c.phoneNum}'
          : c.name;
      while (_byLabel.containsKey(label)) {
        label = '$label ';
      }
      _byLabel[label] = c;
    }
  }

  void _submit() {
    final dup = _duplicate;
    if (dup == null) {
      setState(() => _showError = true);
      return;
    }

    Navigator.pop(
      context,
      MergeResult(
        duplicate: dup,
        takeFromDuplicate: Set.of(_takeFromDuplicate),
      ),
    );
  }

  Widget _buildConflicts(ThemeData theme, Color? muted) {
    final conflicts = _conflicts;
    final dup = _duplicate!;

    if (conflicts.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Text(
          context.tr('لا يوجد تعارض في البيانات. سيتم ملء البيانات الناقصة تلقائيًا وجمع المنتجات والسجلات والأنشطة.'),
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: FontSize.s12.sp,
            color: muted,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('بيانات مختلفة، اختر القيمة التي تريد الاحتفاظ بها:'),
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s14.sp,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            context.tr('باقي البيانات الناقصة سيتم ملؤها تلقائيًا.'),
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s12.sp,
              color: muted,
            ),
          ),
          SizedBox(height: 10.h),
          for (final field in conflicts) ...[
            Text(
              context.tr(field.label),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s12.sp,
                fontWeight: FontWeight.w700,
                color: muted,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: _ChoiceTile(
                    caption: context.tr('الحالي'),
                    value: field.valueOf(widget.current),
                    selected: !_takeFromDuplicate.contains(field),
                    onTap: () =>
                        setState(() => _takeFromDuplicate.remove(field)),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _ChoiceTile(
                    caption: context.tr('المكرر'),
                    value: field.valueOf(dup),
                    selected: _takeFromDuplicate.contains(field),
                    onTap: () =>
                        setState(() => _takeFromDuplicate.add(field)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodyMedium?.color;

    return Directionality(
      textDirection: context.dir,
      child: Dialog(
        backgroundColor: theme.cardTheme.color ?? theme.cardColor,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('دمج عميل محتمل'),
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s16.sp,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(Icons.close_rounded, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('اختر العميل المحتمل الذي تريد دمج هذا السجل معه.'),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s12.sp,
                        color: muted,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: primary.withOpacity(0.18)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            context.tr('العميل الحالي'),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: FontSize.s12.sp,
                              color: muted,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              widget.current.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: FontSize.s14.sp,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    LeadLabeledField(
                      label: context.tr('الدمج مع عميل محتمل'),
                      requiredField: true,
                      child: LeadDropdown(
                        value: _selected,
                        items: _byLabel.keys.toList(),
                        hint: context.tr('اختر...'),
                        errorText: _showError && _selected == null
                            ? context.tr('يرجى اختيار عميل محتمل للدمج معه.')
                            : null,
                        onChanged: (v) => setState(() {
                          _selected = v;
                          _showError = false;
                          _takeFromDuplicate.clear();
                        }),
                      ),
                    ),

                    if (_duplicate != null) _buildConflicts(theme, muted),
                  ],
                ),
              ),

              Divider(height: 1, color: theme.dividerColor),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(Icons.link_rounded, size: 20.sp),
                      label: Text(
                        context.tr('دمج مع'),
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primaryColor,
                        foregroundColor: ColorManager.iconColor,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, size: 18.sp),
                      label: Text(
                        context.tr('إلغاء'),
                        style: TextStyle(
                          fontFamily: FontConstants.fontFamily,
                          fontSize: FontSize.s14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorManager.primaryColor,
                        side: BorderSide(
                          color: ColorManager.primaryColor.withOpacity(0.4),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
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

class _ChoiceTile extends StatelessWidget {
  final String caption;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.caption,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodyMedium?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? primary : theme.dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20.sp,
              color: selected ? primary : muted,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caption,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: FontSize.s12.sp,
                      color: muted,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: FontSize.s14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
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