import 'package:erp_system/core/resources/app_dialog_shell.dart';
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
    final hasClients = widget.clients.isNotEmpty;

    return AppDialogShell(
      icon: Icons.swap_horiz_rounded,
      title: 'تحويل العميل المحتمل إلى عميل',
      description: 'اختر طريقة التحويل.',
      confirmLabel: 'تحويل إلى عميل',
      onConfirm: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInfoTile(
            icon: Icons.person_outline_rounded,
            label: 'العميل المحتمل',
            value: widget.customerName,
          ),
          SizedBox(height: 14.h),

          _ChoiceTile(
            icon: Icons.person_add_alt_1_outlined,
            title: 'عميل جديد',
            subtitle: 'تحويل مباشر بنفس بياناته',
            selected: _isNew,
            onTap: () => setState(() {
              _isNew = true;
              _showError = false;
            }),
          ),
          SizedBox(height: 10.h),
          _ChoiceTile(
            icon: Icons.history_rounded,
            title: 'عميل سابق',
            subtitle: hasClients
                ? 'ربطه بعميل موجود في النظام'
                : 'لا يوجد عملاء سابقون حاليًا',
            selected: !_isNew && hasClients,
            enabled: hasClients,
            onTap: () => setState(() => _isNew = false),
          ),

          if (!_isNew && hasClients) ...[
            SizedBox(height: 16.h),
            LeadLabeledField(
              label: 'العميل',
              requiredField: true,
              child: LeadDropdown(
                value: _selected,
                items: widget.clients,
                hint: 'اختر العميل',
                errorText: _showError && _selected == null
                    ? 'من فضلك اختر العميل'
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