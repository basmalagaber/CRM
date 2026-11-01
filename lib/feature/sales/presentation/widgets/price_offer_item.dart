import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/resources/app_dialog_shell.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';

class PriceOfferItem {
  const PriceOfferItem({
    required this.kind,
    required this.unitName,
    required this.dealType,
    required this.interestLevel,
    required this.unitPrice,
    this.notes = '',
  });

  final String kind;
  final String unitName;
  final String dealType;
  final String interestLevel;
  final double unitPrice;
  final String notes;

  Map<String, dynamic> toMap() => {
    'kind': kind,
    'unitName': unitName,
    'dealType': dealType,
    'interestLevel': interestLevel,
    'unitPrice': unitPrice,
    'notes': notes,
  };
}

class PriceOfferItemOptions {
  static List<String> kinds(BuildContext context) => [context.tr('وحدة'), context.tr('مشروع')];
  static List<String> dealTypes(BuildContext context) => [context.tr('بيع'), context.tr('إيجار')];
  static List<String> levels(BuildContext context) => [context.tr('منخفض'), context.tr('متوسط'), context.tr('عالي')];

  static const List<String> units = ['89431', '89432', '89433', '90120', '90121'];
  static const List<String> projects = ['مشروع النخيل', 'مشروع الواحة', 'مشروع الياسمين'];

  static List<String> namesFor(BuildContext context, String? kind) =>
      kind == context.tr('مشروع') ? projects : units;
}

String fmtMoney(double v) {
  final fixed = v.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
  );
  return '$intPart.${parts[1]}';
}

Color _levelColor(BuildContext context, String level) {
  if (level == context.tr('عالي')) return const Color(0xFF16A34A);
  if (level == context.tr('منخفض')) return const Color(0xFF64748B);
  return const Color(0xFFF59E0B);
}

class PriceOfferItemsSection extends StatelessWidget {
  const PriceOfferItemsSection({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.showError = false,
  });

  final List<PriceOfferItem> items;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;
  final bool showError;

  (Color, Color) _levelColors(BuildContext context, String level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (level == context.tr('عالي')) {
      return isDark
          ? (ColorManager.approvalApprovedBgDark, ColorManager.approvalApprovedFgDark)
          : (ColorManager.approvalApprovedBgLight, ColorManager.approvalApprovedFgLight);
    }
    if (level == context.tr('متوسط')) {
      return isDark
          ? (ColorManager.approvalPendingBgDark, ColorManager.approvalPendingFgDark)
          : (ColorManager.approvalPendingBgLight, ColorManager.approvalPendingFgLight);
    }
    return isDark
        ? (ColorManager.approvalNeutralChipBgDark, ColorManager.approvalNeutralChipFgDark)
        : (ColorManager.approvalNeutralChipBgLight, ColorManager.approvalNeutralChipFgLight);
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 17.sp, color: color),
      ),
    );
  }

  Widget _infoCell({
    required IconData icon,
    required String label,
    required String value,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 13.sp, color: fg.withOpacity(0.85)),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 10.sp,
                    fontWeight: FontWeightManager.regular,
                    color: fg.withOpacity(0.85),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeightManager.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LeadSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  size: 20.sp,
                  color: ColorManager.primaryColor,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  context.tr('الاهتمامات العقارية'),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: Icon(Icons.add_rounded, size: 18.sp),
                label: Text(
                  context.tr('إضافة بند'),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s12.sp,
                    fontWeight: FontWeightManager.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 38.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            context.tr('الوحدات والمشاريع التي يهتم بها هذا العميل المحتمل.'),
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            _EmptyItems(showError: showError)
          else
            Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isDark = theme.brightness == Brightness.dark;
                final (levelBg, levelFg) = _levelColors(context, item.interestLevel);
                final neutralBg = isDark
                    ? ColorManager.approvalNeutralChipBgDark
                    : ColorManager.approvalNeutralChipBgLight;
                final neutralFg = isDark
                    ? ColorManager.approvalNeutralChipFgDark
                    : ColorManager.approvalNeutralChipFgLight;
                final title = item.unitName;
                final code = title.contains(' - ') ? title.split(' - ').first : '';
                final name = code.isNotEmpty ? title.substring(code.length + 3) : title;

                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28.r,
                            height: 28.r,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorManager.primaryColor,
                              borderRadius: BorderRadius.circular(9.r),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeightManager.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontSize: FontSize.s14.sp,
                                  ),
                                ),
                                if (code.isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    code,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11.sp),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _actionButton(
                            icon: Icons.edit_outlined,
                            color: ColorManager.primaryColor,
                            onTap: () => onEdit(index),
                          ),
                          SizedBox(width: 6.w),
                          _actionButton(
                            icon: Icons.delete_outline_rounded,
                            color: theme.colorScheme.error,
                            onTap: () => onDelete(index),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Divider(height: 1, color: theme.dividerColor),
                      SizedBox(height: 10.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _infoCell(
                              icon: item.kind == context.tr('مشروع')
                                  ? Icons.domain_rounded
                                  : Icons.apartment_rounded,
                              label: context.tr('مهتم بـ'),
                              value: item.kind,
                              bg: neutralBg,
                              fg: neutralFg,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _infoCell(
                              icon: Icons.sell_outlined,
                              label: context.tr('نوع الصفقة'),
                              value: item.dealType,
                              bg: neutralBg,
                              fg: neutralFg,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _infoCell(
                              icon: Icons.local_fire_department_outlined,
                              label: context.tr('مستوى الاهتمام'),
                              value: item.interestLevel,
                              bg: levelBg,
                              fg: levelFg,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: ColorManager.primaryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.tr(item.kind == context.tr('مشروع')
                                    ? 'السعر المبدئي'
                                    : 'سعر الوحدة'),
                                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                              ),
                            ),
                            Text(
                              fmtMoney(item.unitPrice),
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontFamily: FontConstants.fontFamily,
                                fontSize: FontSize.s16.sp,
                                fontWeight: FontWeightManager.bold,
                                color: ColorManager.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.notes.trim().isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.sticky_note_2_outlined,
                                size: 15.sp,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  item.notes,
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _EmptyItems extends StatelessWidget {
  const _EmptyItems({required this.showError});
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = showError
        ? ColorManager.errorBorder
        : theme.textTheme.bodySmall?.color;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: showError ? ColorManager.errorBorder : theme.dividerColor,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 30.sp, color: color),
          SizedBox(height: 8.h),
          Text(
            showError ? context.tr('لازم تضيفي بند واحد على الأقل') : context.tr('لم تتم إضافة أي بند بعد'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}




class PriceOfferTotalsSection extends StatelessWidget {
  const PriceOfferTotalsSection({
    super.key,
    required this.subtotal,
    required this.discountPercent,
    required this.total,
  });

  final double subtotal;
  final double discountPercent;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discountAmount = subtotal - total;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: AppDecorations.card(context, radius: 22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.calculate_outlined,
                  size: 19.sp,
                  color: ColorManager.primaryColor,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                context.tr('الإجماليات'),
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s16.sp,
                  fontWeight: FontWeightManager.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _ReadOnlyRow(label: context.tr('الإجمالي الفرعي'), value: fmtMoney(subtotal)),
          if (discountPercent > 0) ...[
            SizedBox(height: 10.h),
            _ReadOnlyRow(
              label: '${context.tr('الخصم')} (${discountPercent.toStringAsFixed(discountPercent % 1 == 0 ? 0 : 2)}%)',
              value: '- ${fmtMoney(discountAmount)}',
            ),
          ],
          SizedBox(height: 10.h),
          _ReadOnlyRow(label: context.tr('الإجمالي'), value: fmtMoney(total), highlight: true),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = ColorManager.primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: highlight
            ? primary.withOpacity(0.10)
            : theme.scaffoldBackgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: highlight ? primary.withOpacity(0.35) : theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: (highlight ? theme.textTheme.titleMedium : theme.textTheme.titleSmall)
                ?.copyWith(color: highlight ? primary : null),
          ),
        ],
      ),
    );
  }
}

const List<Map<String, dynamic>> _kOfferUnits = [
  {'code': 'A-101', 'name': 'شقة 101 - برج النخبة', 'unitPrice': 1850000},
  {'code': 'A-204', 'name': 'شقة 204 - برج النخبة', 'unitPrice': 2100000},
  {'code': 'B-12', 'name': 'فيلا 12 - كمبوند الواحة', 'unitPrice': 6500000},
  {'code': 'C-305', 'name': 'دوبلكس 305 - ريفر سايد', 'unitPrice': 3400000},
  {'code': 'S-07', 'name': 'محل 07 - داون تاون مول', 'unitPrice': 2750000},
];

const List<Map<String, dynamic>> _kOfferProjects = [
  {'code': 'P-01', 'name': 'برج النخبة', 'unitPrice': 1500000},
  {'code': 'P-02', 'name': 'كمبوند الواحة', 'unitPrice': 4200000},
  {'code': 'P-03', 'name': 'ريفر سايد', 'unitPrice': 2300000},
  {'code': 'P-04', 'name': 'داون تاون مول', 'unitPrice': 1900000},
];

Future<PriceOfferItem?> showPriceOfferItemSheet(
    BuildContext context, {
      PriceOfferItem? initial,
    }) {
  return showDialog<PriceOfferItem>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w),
        child: _ItemSheet(initial: initial),
      ),
    ),
  );
}

class _ItemSheet extends StatefulWidget {
  const _ItemSheet({this.initial});
  final PriceOfferItem? initial;

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  late String _kind =
      widget.initial?.kind ?? PriceOfferItemOptions.kinds(context).first;
  late String _dealType = widget.initial?.dealType ??
      PriceOfferItemOptions.dealTypes(context).first;
  late String _level =
      widget.initial?.interestLevel ?? PriceOfferItemOptions.levels(context)[1];

  Map<String, dynamic>? _selectedItem;

  late final TextEditingController _price = TextEditingController(
    text: widget.initial == null
        ? ''
        : widget.initial!.unitPrice.toStringAsFixed(
      widget.initial!.unitPrice % 1 == 0 ? 0 : 2,
    ),
  );
  late final TextEditingController _notes =
  TextEditingController(text: widget.initial?.notes ?? '');

  bool _submitted = false;

  bool get _isEdit => widget.initial != null;

  bool get _isProject => _kind == context.tr('مشروع');

  List<Map<String, dynamic>> get _options =>
      _isProject ? _kOfferProjects : _kOfferUnits;

  @override
  void initState() {
    super.initState();
    final name = widget.initial?.unitName ?? '';
    if (name.isNotEmpty) {
      _selectedItem = {'code': '', 'name': name, 'unitPrice': 0};
    }
  }

  @override
  void dispose() {
    _price.dispose();
    _notes.dispose();
    super.dispose();
  }

  double? get _priceValue => double.tryParse(_price.text.trim());

  String? get _itemTitle {
    final item = _selectedItem;
    if (item == null) return null;
    final code = (item['code'] ?? '').toString();
    final name = (item['name'] ?? '').toString();
    return code.isEmpty ? name : '$code - $name';
  }

  Future<void> _pickItem() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OfferItemPickerSheet(
        title: context.trArgs('اختر {type}', {'type': _kind}),
        items: _options,
        selectedCode: _selectedItem?['code']?.toString(),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _selectedItem = result;
      final p = (result['unitPrice'] as num?) ?? 0;
      if (p > 0) {
        _price.text = p.toStringAsFixed(p % 1 == 0 ? 0 : 2);
      }
    });
  }

  void _confirm() {
    setState(() => _submitted = true);
    final price = _priceValue;
    final title = _itemTitle;
    if (title == null || price == null || price <= 0) return;

    Navigator.pop(
      context,
      PriceOfferItem(
        kind: _kind,
        unitName: title,
        dealType: _dealType,
        interestLevel: _level,
        unitPrice: price,
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: AppDialogShell(
        icon: Icons.home_work_outlined,
        title: context.tr(_isEdit ? 'تعديل بند' : 'إضافة بند'),
        description: context.tr('اختر نوع الصفقة ثم حدد الوحدة أو المشروع.'),
        confirmLabel: context.tr('حفظ'),
        confirmIcon: Icons.save_outlined,
        onConfirm: _confirm,
        child: SingleChildScrollView(
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
                        items: PriceOfferItemOptions.dealTypes(context),
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
                        value: _kind,
                        items: PriceOfferItemOptions.kinds(context),
                        hint: context.tr('اختر...'),
                        onChanged: (v) {
                          if (v == null || v == _kind) return;
                          setState(() {
                            _kind = v;
                            _selectedItem = null;
                            _price.clear();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              LeadLabeledField(
                label: context.tr(_isProject ? 'المشروع' : 'الوحدة'),
                requiredField: true,
                child: _OfferItemField(
                  title: _itemTitle,
                  hint: context.trArgs('ابحث عن {type}', {'type': _kind}),
                  errorText: _submitted && _selectedItem == null
                      ? context.tr(
                    _isProject ? 'المشروع مطلوب' : 'الوحدة مطلوبة',
                  )
                      : null,
                  onTap: _pickItem,
                ),
              ),
              SizedBox(height: 10.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LeadLabeledField(
                      label: context.tr('مستوى الاهتمام'),
                      child: LeadDropdown(
                        value: _level,
                        items: PriceOfferItemOptions.levels(context),
                        hint: context.tr('اختر...'),
                        onChanged: (v) {
                          if (v != null) setState(() => _level = v);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: LeadLabeledField(
                      label: context.tr('سعر الوحدة'),
                      requiredField: true,
                      child: TextField(
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: FontSize.s14.sp,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          errorText: _submitted && ((_priceValue ?? 0) <= 0)
                              ? context.tr('أدخلي سعر صحيح')
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              LeadLabeledField(
                label: context.tr('ملاحظات'),
                child: LeadTextField(
                  controller: _notes,
                  hintText: context.tr('أضف ملاحظات (اختياري)'),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferItemField extends StatelessWidget {
  final String? title;
  final String hint;
  final String? errorText;
  final VoidCallback onTap;

  const _OfferItemField({
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
              color:
              theme.inputDecorationTheme.fillColor ?? theme.cardTheme.color,
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
                          : theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.7),
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

class _OfferItemPickerSheet extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String? selectedCode;

  const _OfferItemPickerSheet({
    required this.title,
    required this.items,
    required this.selectedCode,
  });

  @override
  State<_OfferItemPickerSheet> createState() => _OfferItemPickerSheetState();
}

class _OfferItemPickerSheetState extends State<_OfferItemPickerSheet> {
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
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      final isSelected = item['code'].toString() ==
                          widget.selectedCode;

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
                          '${item['code']} - ${fmtMoney((item['unitPrice'] as num).toDouble())}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontSize: 11.sp),
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