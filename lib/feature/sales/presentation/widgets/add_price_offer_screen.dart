import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/core/widgets/app_primary_button.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_store.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:erp_system/feature/sales/presentation/widgets/price_offer_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';

class AddPriceOfferScreen extends StatefulWidget {
  final UserRole role;
  final String userName;

  const AddPriceOfferScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  State<AddPriceOfferScreen> createState() => _AddPriceOfferScreenState();
}

class _AddPriceOfferScreenState extends State<AddPriceOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _customerType;
  String? _goal;
  String? _source = 'النشاط';
  String? _activity;
  String? _paymentMethod = 'نقدي';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discountController =
  TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController();

  DateTime? _offerDate;
  DateTime? _expiryDate;
  bool _isSaving = false;
  bool _submitted = false;

  final List<PriceOfferItem> _items = [];

  double get _subtotal => _items.fold<double>(0, (s, i) => s + i.unitPrice);

  double get _discountPercent {
    final v = double.tryParse(_discountController.text.trim()) ?? 0;
    if (v < 0) return 0;
    if (v > 100) return 100;
    return v;
  }

  double get _total => _subtotal * (1 - _discountPercent / 100);

  List<String> get _customerTypes => [
    context.tr('عميل محتمل'),
    context.tr('عميل'),
  ];

  static const List<String> _fixedCustomers = [
    'شركة النور',
    'مؤسسة الأمل',
    'شركة الفجر',
    'مكتب الصفوة',
  ];

  List<String> get _paymentMethods => [
    context.tr('نقدي'),
    context.tr('بطاقة'),
    context.tr('تحويل بنكي'),
    context.tr('محفظة'),
  ];

  List<String> get _customerNames {
    if (_customerType == null) return [];

    if (_customerType == context.tr('عميل')) return _fixedCustomers;

    final visible = CustomerLeadStore.visibleCustomers(
      role: widget.role,
      userName: widget.userName,
    );

    return visible
        .where((c) => c.status != LeadStatus.lost)
        .map((c) => c.name)
        .toSet()
        .toList();
  }

  String? get _selectedPhone {
    if (_customerType != context.tr('عميل محتمل') || _goal == null) return null;

    final visible = CustomerLeadStore.visibleCustomers(
      role: widget.role,
      userName: widget.userName,
    );

    for (final c in visible) {
      if (c.name == _goal) {
        final phone = c.phoneNum?.trim() ?? '';
        return phone.isEmpty ? null : phone;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final item = await showPriceOfferItemSheet(context);
    if (item == null || !mounted) return;
    setState(() => _items.add(item));
  }

  Future<void> _editItem(int index) async {
    final item = await showPriceOfferItemSheet(context, initial: _items[index]);
    if (item == null || !mounted) return;
    setState(() => _items[index] = item);
  }

  Future<void> _deleteItem(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: context.dir,
        child: AlertDialog(
          title: Text(context.tr('حذف البند')),
          content: Text(context.tr('متأكدة إنك عايزة تحذفي البند ده؟')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('إلغاء')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                context.tr('حذف'),
                style: const TextStyle(color: ColorManager.errorBorder),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _items.removeAt(index));
  }

  bool get _isExpiryBeforeOffer =>
      _offerDate != null &&
          _expiryDate != null &&
          _expiryDate!.isBefore(_offerDate!);

  Future<void> _selectDate({required bool isExpiryDate}) async {
    final now = DateTime.now();
    final currentDate = isExpiryDate ? _expiryDate : _offerDate;

    final firstDate = isExpiryDate && _offerDate != null
        ? _offerDate!
        : DateTime(2020);

    var initialDate = currentDate ?? now;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ColorManager.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      if (isExpiryDate) {
        _expiryDate = pickedDate;
      } else {
        _offerDate = pickedDate;
      }
    });

    if (!isExpiryDate && _isExpiryBeforeOffer) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.tr('تاريخ الانتهاء يجب أن يكون بعد تاريخ عرض السعر'),
            ),
          ),
        );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return context.trArgs('{label} مطلوب', {'label': label});
    }
    return null;
  }

  String? _validateDate(DateTime? date, String label) {
    if (!_submitted) return null;
    if (date == null) return context.trArgs('{label} مطلوب', {'label': label});
    return null;
  }

  String? get _expiryError {
    if (_isExpiryBeforeOffer) {
      return context.tr('تاريخ الانتهاء يجب أن يكون بعد تاريخ عرض السعر');
    }
    return _validateDate(_expiryDate, context.tr('تاريخ الانتهاء'));
  }

  Future<void> _saveOffer() async {
    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState?.validate() ?? false;

    setState(() => _submitted = true);

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('أضيفي بند واحد على الأقل'))),
      );
    }

    if (!isFormValid ||
        _items.isEmpty ||
        _offerDate == null ||
        _expiryDate == null ||
        _customerType == null ||
        _goal == null) {
      return;
    }

    if (_isExpiryBeforeOffer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              context.tr('تاريخ الانتهاء يجب أن يكون بعد تاريخ عرض السعر')),
        ),
      );
      return;
    }

    final discount = double.tryParse(_discountController.text.trim());

    if (discount == null || discount < 0 || discount > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('نسبة الخصم لازم تكون بين 0 و 100')),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final offer = <String, dynamic>{
      'name': _nameController.text.trim(),
      'customerType': _customerType,
      'goal': _goal,
      'source': _source,
      'activity': _activity,
      'phone': _selectedPhone,
      'offerDate': _offerDate!.toIso8601String(),
      'expiryDate': _expiryDate!.toIso8601String(),
      'paymentMethod': _paymentMethod,
      'discount': discount,
      'items': _items.map((i) => i.toMap()).toList(),
      'subtotal': _subtotal,
      'total': _total,
      'notes': _notesController.text.trim(),
    };

    if (!mounted) return;

    setState(() => _isSaving = false);
    Navigator.pop(context, offer);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final names = _customerNames;
    final expiryError = _expiryError;

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    child: Column(
                      children: [
                        _buildSection(
                          theme,
                          icon: Icons.description_outlined,
                          title: context.tr('البيانات الأساسية'),
                          children: [
                            _buildPair(
                              first: _buildField(
                                theme,
                                label: context.tr('اسم عرض السعر'),
                                requiredField: true,
                                child: TextFormField(
                                  controller: _nameController,
                                  textDirection: context.dir,
                                  style: _inputTextStyle(theme),
                                  validator: (value) => _validateRequired(
                                    value,
                                    context.tr('اسم عرض السعر'),
                                  ),
                                  decoration: _inputDecoration(
                                    theme,
                                    hint: context.tr('اكتب اسم عرض السعر'),
                                  ),
                                ),
                              ),
                              second: const SizedBox.shrink(),
                              fullWidthFirst: true,
                            ),
                            _buildPair(
                              first: _buildField(
                                theme,
                                label: context.tr('نوع العميل'),
                                requiredField: true,
                                child: _buildDropdown(
                                  theme,
                                  value: _customerType,
                                  hint: context.tr('اختر...'),
                                  items: _customerTypes,
                                  validator: (value) => _validateRequired(
                                    value,
                                    context.tr('نوع العميل'),
                                  ),
                                  onChanged: (value) => setState(() {
                                    _customerType = value;
                                    _goal = null;
                                  }),
                                ),
                              ),
                              second: _buildField(
                                theme,
                                label: _customerType ?? context.tr('الهدف'),
                                requiredField: true,
                                child: _buildDropdown(
                                  theme,
                                  value: names.contains(_goal) ? _goal : null,
                                  hint: _customerType == null
                                      ? context.tr('اختر نوع العميل أولاً')
                                      : (names.isEmpty
                                      ? context.tr('لا يوجد')
                                      : context.tr('اختر...')),
                                  items: names,
                                  validator: (value) => _validateRequired(
                                      value, context.tr('العميل')),
                                  onChanged: (value) =>
                                      setState(() => _goal = value),
                                ),
                              ),
                              isLast: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildSection(
                          theme,
                          icon: Icons.event_note_outlined,
                          title: context.tr('التواريخ والدفع'),
                          children: [
                            _buildPair(
                              first: _buildField(
                                theme,
                                label: context.tr('تاريخ عرض السعر'),
                                requiredField: true,
                                errorText: _validateDate(
                                  _offerDate,
                                  context.tr('تاريخ عرض السعر'),
                                ),
                                child: _buildDateField(
                                  theme,
                                  date: _offerDate,
                                  hasError: _submitted && _offerDate == null,
                                  onTap: () =>
                                      _selectDate(isExpiryDate: false),
                                ),
                              ),
                              second: _buildField(
                                theme,
                                label: context.tr('تاريخ الانتهاء'),
                                requiredField: true,
                                errorText: expiryError,
                                child: _buildDateField(
                                  theme,
                                  date: _expiryDate,
                                  hasError: expiryError != null,
                                  onTap: () => _selectDate(isExpiryDate: true),
                                ),
                              ),
                            ),
                            _buildPair(
                              first: _buildField(
                                theme,
                                label: context.tr('طريقة الدفع'),
                                child: _buildDropdown(
                                  theme,
                                  value: _paymentMethod,
                                  hint: context.tr('اختر...'),
                                  items: _paymentMethods,
                                  onChanged: (value) =>
                                      setState(() => _paymentMethod = value),
                                ),
                              ),
                              second: _buildField(
                                theme,
                                label: context.tr('نسبة الخصم %'),
                                child: TextFormField(
                                  controller: _discountController,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  textDirection: TextDirection.ltr,
                                  textAlign: context.isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: _inputTextStyle(theme),
                                  onChanged: (_) => setState(() {}),
                                  decoration: _inputDecoration(
                                    theme,
                                    hint: '0',
                                  ),
                                  validator: (value) {
                                    final discount = double.tryParse(
                                      value?.trim() ?? '',
                                    );
                                    if (discount == null ||
                                        discount < 0 ||
                                        discount > 100) {
                                      return context.tr('من 0 إلى 100');
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              isLast: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildSection(
                          theme,
                          icon: Icons.sticky_note_2_outlined,
                          title: context.tr('ملاحظات'),
                          children: [
                            _buildField(
                              theme,
                              label: context.tr('ملاحظات إضافية'),
                              isLast: true,
                              child: TextFormField(
                                controller: _notesController,
                                maxLines: 4,
                                minLines: 4,
                                textDirection: context.dir,
                                textAlignVertical: TextAlignVertical.top,
                                style: _inputTextStyle(theme),
                                decoration: _inputDecoration(
                                  theme,
                                  hint: context.tr('اكتب أي ملاحظات هنا...'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        PriceOfferItemsSection(
                          items: _items,
                          showError: _submitted && _items.isEmpty,
                          onAdd: _addItem,
                          onEdit: _editItem,
                          onDelete: _deleteItem,
                        ),
                        SizedBox(height: 16.h),
                        PriceOfferTotalsSection(
                          subtotal: _subtotal,
                          discountPercent: _discountPercent,
                          total: _total,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),

      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.r),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ColorManager.primaryLightShade,
                  ColorManager.primaryColor,
                ],
              ),

            ),
            child: Icon(
              Icons.request_quote_outlined,
              size: 22.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              context.tr('إضافة عرض سعر'),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s20.sp,
                fontWeight: FontWeightManager.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 40.r,
              height: 40.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(0.6),
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 22.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      ThemeData theme, {
        required IconData icon,
        required String title,
        required List<Widget> children,
      }) {
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
                  icon,
                  size: 19.sp,
                  color: ColorManager.primaryColor,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s16.sp,
                  fontWeight: FontWeightManager.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          Divider(height: 28.h, color: theme.dividerColor),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPair({
    required Widget first,
    required Widget second,
    bool isLast = false,
    bool fullWidthFirst = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 300;

        Widget content;
        if (fullWidthFirst) {
          content = first;
        } else if (narrow) {
          content = Column(
            children: [
              first,
              SizedBox(height: 16.h),
              second,
            ],
          );
        } else {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              SizedBox(width: 12.w),
              Expanded(child: second),
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
          child: content,
        );
      },
    );
  }

  Widget _buildField(
      ThemeData theme, {
        required String label,
        required Widget child,
        bool requiredField = false,
        bool isLast = false,
        String? errorText,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s14.sp,
                  fontWeight: FontWeightManager.medium,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              if (requiredField)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s14.sp,
                    color: ColorManager.errorBorder,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        child,
        if (errorText != null) ...[
          SizedBox(height: 5.h),
          Text(
            errorText,
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: FontSize.s12.sp,
              color: ColorManager.errorBorder,
            ),
          ),
        ],
      ],
    );
  }

  TextStyle _inputTextStyle(ThemeData theme) {
    return TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: FontSize.s14.sp,
      color: theme.textTheme.bodyLarge?.color,
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, {required String hint}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: theme.dividerColor),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: FontConstants.fontFamily,
        fontSize: FontSize.s14.sp,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
      ),
      errorStyle: TextStyle(
        fontFamily: FontConstants.fontFamily,
        fontSize: FontSize.s12.sp,
        color: ColorManager.errorBorder,
      ),
      filled: true,
      fillColor: theme.scaffoldBackgroundColor.withOpacity(0.6),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
      isDense: true,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(
          color: ColorManager.primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: ColorManager.errorBorder),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide:
        const BorderSide(color: ColorManager.errorBorder, width: 1.5),
      ),
    );
  }

  Widget _buildDropdown(
      ThemeData theme, {
        required String? value,
        required String hint,
        required List<String> items,
        required ValueChanged<String?> onChanged,
        String? Function(String?)? validator,
      }) {
    return FormField<String>(
      key: ValueKey('$hint-$value'),
      initialValue: value,
      validator: validator,
      builder: (state) => LeadDropdown(
        value: value,
        items: items,
        hint: hint,
        errorText: state.errorText,
        onChanged: (v) {
          state.didChange(v);
          onChanged(v);
        },
      ),
    );
  }

  Widget _buildDateField(
      ThemeData theme, {
        required DateTime? date,
        required VoidCallback onTap,
        bool hasError = false,
      }) {
    final hasValue = date != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.6),
          border: Border.all(
            color: hasError ? ColorManager.errorBorder : theme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? _formatDate(date) : context.tr('اختر التاريخ'),
                textDirection: TextDirection.ltr,
                textAlign: context.isArabic ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s14.sp,
                  color: hasValue
                      ? theme.textTheme.bodyLarge?.color
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.calendar_today_outlined,
              size: 18.sp,
              color: hasError
                  ? ColorManager.errorBorder
                  : ColorManager.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(top: BorderSide(color: theme.dividerColor)),

      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AppPrimaryButton(
              label: context.tr('حفظ'),
              icon: Icons.save_outlined,
              isLoading: _isSaving,
              onPressed: _saveOffer,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 52.h,
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorManager.primaryColor,
                  side: BorderSide(
                    color: ColorManager.primaryColor.withOpacity(0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  context.tr('إلغاء'),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s16.sp,
                    fontWeight: FontWeightManager.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}