import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const List<String> kEmployees = [
  'Mohammed',
  'Ahmed',
  'Basmala',
  'Ali',
  'Amr',
];

class ChangeManagerResult {
  final String newManager;
  final String? reason;

  const ChangeManagerResult({required this.newManager, this.reason});
}

Future<ChangeManagerResult?> showChangeManagerDialog(
    BuildContext context, {
      required String customerName,
      String? currentManager,
      List<String> employees = kEmployees,
    }) {
  return showDialog<ChangeManagerResult>(
    context: context,
    builder: (_) => _ChangeManagerDialog(
      customerName: customerName,
      currentManager: currentManager,
      employees: employees,
    ),
  );
}

class _ChangeManagerDialog extends StatefulWidget {
  final String customerName;
  final String? currentManager;
  final List<String> employees;

  const _ChangeManagerDialog({
    required this.customerName,
    required this.currentManager,
    required this.employees,
  });

  @override
  State<_ChangeManagerDialog> createState() => _ChangeManagerDialogState();
}

class _ChangeManagerDialogState extends State<_ChangeManagerDialog> {
  final _reasonController = TextEditingController();
  String? _selected;
  bool _showError = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selected == null) {
      setState(() => _showError = true);
      return;
    }

    final reason = _reasonController.text.trim();

    Navigator.pop(
      context,
      ChangeManagerResult(
        newManager: _selected!,
        reason: reason.isEmpty ? null : reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodyMedium?.color;
    final options =
    widget.employees.where((e) => e != widget.currentManager).toList();

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
              // ===== Header =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.manage_accounts_outlined,
                        size: 22.sp,
                        color: primary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        context.tr('تغيير مسؤول العميل المحتمل'),
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
                      context.tr('اختر المسؤول الجديد، ويمكنك إضافة سبب اختياري للتغيير.'),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s12.sp,
                        color: muted,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: primary.withOpacity(0.18)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 20.sp, color: primary),
                          SizedBox(width: 8.w),
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
                              widget.customerName,
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
                      label: context.tr('المسؤول الجديد'),
                      requiredField: true,
                      child: LeadDropdown(
                        value: _selected,
                        items: options,
                        hint: context.tr('اختر المسؤول'),
                        errorText: _showError && _selected == null
                            ? context.tr('من فضلك اختاري المسؤول الجديد')
                            : null,
                        onChanged: (v) => setState(() {
                          _selected = v;
                          _showError = false;
                        }),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    LeadLabeledField(
                      label: context.tr('السبب (اختياري)'),
                      child: LeadTextField(
                        controller: _reasonController,
                        hintText: context.tr('اكتب سبب التغيير...'),
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: theme.dividerColor),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: Icon(Icons.check_rounded, size: 20.sp),
                        label: Text(
                          context.tr('تغيير المسؤول'),
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
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorManager.primaryColor,
                          side: BorderSide(
                            color: ColorManager.primaryColor.withOpacity(0.4),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          context.tr('إلغاء'),
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: FontSize.s14.sp,
                            fontWeight: FontWeight.bold,
                          ),
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