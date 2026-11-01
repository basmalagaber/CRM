import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/fonts_manager.dart';
import 'lead_dropdown.dart';
import 'lead_labeled_field.dart';
import 'lead_text_field.dart';

class AddProductSheet extends StatefulWidget {
  final Map<String, dynamic>? initialProduct;

  const AddProductSheet({
    super.key,
    this.initialProduct,
  });

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  static const List<Map<String, dynamic>> productOptions = [
    {
      'name': 'نظام إدارة العملاء CRM',
      'unitPrice': 15000.0,
    },
    {
      'name': 'نظام المحاسبة',
      'unitPrice': 12000.0,
    },
    {
      'name': 'نظام إدارة المخزون',
      'unitPrice': 10000.0,
    },
    {
      'name': 'نظام الموارد البشرية HR',
      'unitPrice': 18000.0,
    },
    {
      'name': 'تطبيق موبايل',
      'unitPrice': 25000.0,
    },
  ];

  late List<Map<String, dynamic>> _options;

  String? selectedProduct;
  double? selectedPrice;

  late final TextEditingController quantityController;

  bool get isEdit => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();

    _options = List<Map<String, dynamic>>.from(productOptions);

    final p = widget.initialProduct;

    quantityController = TextEditingController(
      text: (p?['quantity'] ?? 1).toString(),
    );

    if (p != null) {
      final String name = (p['name'] ?? '').toString();
      final double price = (p['unitPrice'] ?? 0).toDouble();

      final exists = _options.any((item) => item['name'] == name);
      if (!exists && name.isNotEmpty) {
        _options.add({'name': name, 'unitPrice': price});
      }

      selectedProduct = name.isEmpty ? null : name;
      selectedPrice = price;
    }

    quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    quantityController.removeListener(_onQuantityChanged);
    quantityController.dispose();

    super.dispose();
  }

  void _onQuantityChanged() {
    setState(() {});
  }

  void _onProductChanged(String? value) {
    if (value == null) return;

    final product = _options.firstWhere(
          (item) => item['name'] == value,
    );

    setState(() {
      selectedProduct = value;
      selectedPrice = (product['unitPrice'] as num).toDouble();
    });
  }

  double get _total {
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

    if (selectedPrice == null || quantity <= 0) {
      return 0;
    }

    return selectedPrice! * quantity;
  }

  void _addProduct() {
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

    if (selectedProduct == null) {
      _showError(context.tr('يرجى اختيار المنتج'));
      return;
    }

    if (quantity <= 0) {
      _showError(context.tr('يرجى إدخال كمية صحيحة'));
      return;
    }

    if (selectedPrice == null) {
      _showError(context.tr('سعر المنتج غير متوفر'));
      return;
    }

    Navigator.pop(
      context,
      {
        ...?widget.initialProduct,
        'name': selectedProduct,
        'quantity': quantity,
        'unitPrice': selectedPrice,
        'total': _total,
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: Container(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              Text(
                context.tr(isEdit ? 'تعديل المنتج' : 'إضافة منتج'),
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s20.sp,
                  fontWeight: FontWeightManager.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),

              SizedBox(height: 20.h),

              LeadLabeledField(
                label: context.tr('اسم المنتج'),
                requiredField: true,
                child: LeadDropdown(
                  value: selectedProduct,
                  items: _options
                      .map((product) => product['name'] as String)
                      .toList(),
                  hint: context.tr('اختر المنتج'),
                  onChanged: _onProductChanged,
                ),
              ),

              SizedBox(height: 14.h),

              LeadLabeledField(
                label: context.tr('الكمية'),
                requiredField: true,
                child: LeadTextField(
                  controller: quantityController,
                  hintText: context.tr('أدخل الكمية'),
                  keyboardType: TextInputType.number,
                ),
              ),

              SizedBox(height: 14.h),

              LeadLabeledField(
                label: context.tr('سعر الوحدة'),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedPrice == null
                              ? context.tr('سيظهر السعر تلقائيًا')
                              : selectedPrice!.toStringAsFixed(2),
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: FontSize.s14.sp,
                            color: selectedPrice == null
                                ? theme.textTheme.bodyMedium?.color
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: selectedPrice == null
                                ? FontWeightManager.regular
                                : FontWeightManager.semiBold,
                          ),
                        ),
                      ),
                      if (selectedPrice != null)
                        Text(
                          context.tr('ج.م'),
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: FontSize.s14.sp,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      context.tr('الإجمالي'),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s14.sp,
                        fontWeight: FontWeightManager.semiBold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_total.toStringAsFixed(2)} ${context.tr('ج.م')}',
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s16.sp,
                        fontWeight: FontWeightManager.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: ColorManager.iconColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    context.tr(isEdit ? 'حفظ التعديل' : 'إضافة المنتج'),
                    style: TextStyle(
                      fontFamily: FontConstants.fontFamily,
                      fontSize: FontSize.s16.sp,
                      fontWeight: FontWeightManager.bold,
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