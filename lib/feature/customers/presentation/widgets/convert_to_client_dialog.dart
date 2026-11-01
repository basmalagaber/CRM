import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/clients/data/client_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const List<String> kClients = <String>[];



Future<String?> showConvertToClientDialog(
    BuildContext context, {
      required String customerName,
      List<String>? clients,
    }) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ConvertToClientDialog(
      customerName: customerName,
      clients: clients ?? ClientStore.names,
    ),
  );
}

class _ConvertToClientDialog extends StatefulWidget {
  final String customerName;
  final List<String> clients;

  const _ConvertToClientDialog({
    required this.customerName,
    required this.clients,
  });

  @override
  State<_ConvertToClientDialog> createState() => _ConvertToClientDialogState();
}

class _ConvertToClientDialogState extends State<_ConvertToClientDialog> {
  bool _isNew = true;
  String? _selected;
  bool _showError = false;

  void _submit() {
    if (_isNew) {
      Navigator.pop(context, kConvertToNewClient);
      return;
    }

    if (_selected == null) {
      setState(() => _showError = true);
      return;
    }

    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodyMedium?.color;
    final hasClients = widget.clients.isNotEmpty;

    return Directionality(
      textDirection: context.dir,
      child: Dialog(
        backgroundColor: theme.cardTheme.color ?? theme.cardColor,
        surfaceTintColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
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
                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 22.sp,
                        color: primary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        context.tr('تحويل العميل المحتمل إلى عميل'),
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
                      context.tr('اختر طريقة التحويل.'),
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
                            context.tr('العميل المحتمل'),
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
                    SizedBox(height: 14.h),

                    _ChoiceTile(
                      icon: Icons.person_add_alt_1_outlined,
                      title: context.tr('عميل جديد'),
                      subtitle: context.tr('تحويل مباشر بنفس بياناته'),
                      selected: _isNew,
                      onTap: () => setState(() {
                        _isNew = true;
                        _showError = false;
                      }),
                    ),
                    SizedBox(height: 10.h),
                    _ChoiceTile(
                      icon: Icons.history_rounded,
                      title: context.tr('عميل سابق'),
                      subtitle: hasClients
                          ? context.tr('ربطه بعميل موجود في النظام')
                          : context.tr('لا يوجد عملاء سابقون حاليًا'),
                      selected: !_isNew && hasClients,
                      enabled: hasClients,
                      onTap: () => setState(() => _isNew = false),
                    ),

                    if (!_isNew && hasClients) ...[
                      SizedBox(height: 16.h),
                      LeadLabeledField(
                        label: context.tr('العميل'),
                        requiredField: true,
                        child: LeadDropdown(
                          value: _selected,
                          items: widget.clients,
                          hint: context.tr('اختر العميل'),
                          errorText: _showError && _selected == null
                              ? context.tr('من فضلك اختر العميل')
                              : null,
                          onChanged: (v) => setState(() {
                            _selected = v;
                            _showError = false;
                          }),
                        ),
                      ),
                    ],
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
                          context.tr('تحويل إلى عميل'),
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

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: selected ? primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected ? primary : theme.dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 20.sp, color: primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: FontSize.s14.sp,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: FontSize.s12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22.sp,
                color: selected ? primary : theme.dividerColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}