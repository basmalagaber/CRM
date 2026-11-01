import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'lead_dropdown.dart';
import 'lead_labeled_field.dart';
import 'lead_section_card.dart';
import 'lead_text_field.dart';

class LeadLocationSection extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController expectedValueController;

  final String? country;
  final String? region;
  final String? currency;

  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onRegionChanged;
  final ValueChanged<String?> onCurrencyChanged;

  final List<String> countries;
  final List<String> regions;
  final List<String> currencies;

  const LeadLocationSection({
    super.key,
    required this.addressController,
    required this.expectedValueController,
    required this.country,
    required this.region,
    required this.currency,
    required this.onCountryChanged,
    required this.onRegionChanged,
    required this.onCurrencyChanged,
    required this.countries,
    required this.regions,
    required this.currencies,
  });

  @override
  Widget build(BuildContext context) {
    return LeadSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LeadLabeledField(
            label: context.tr('الدولة (اختياري)'),
            child: LeadDropdown(
              value: country,
              items: countries,
              hint: context.tr('اختر الدولة'),
              onChanged: onCountryChanged,
            ),
          ),

          SizedBox(height: 14.h),

          LeadLabeledField(
            label: context.tr('المنطقة (اختياري)'),
            child: LeadDropdown(
              value: region,
              items: regions,
              hint: context.tr('اختر المنطقة'),
              onChanged: onRegionChanged,
            ),
          ),

          SizedBox(height: 14.h),

          LeadLabeledField(
            label: context.tr('العنوان (اختياري)'),
            child: LeadTextField(
              controller: addressController,
              hintText: context.tr('أدخل العنوان'),
              maxLines: 1,
            ),
          ),

          SizedBox(height: 14.h),

          LeadLabeledField(
            label: context.tr('العملة'),
            child: LeadDropdown(
              value: currency,
              items: currencies,
              hint: context.tr('اختر العملة'),
              onChanged: onCurrencyChanged,
            ),
          ),

          SizedBox(height: 14.h),

          LeadLabeledField(
            label: context.tr('القيمة المتوقعة'),
            child: LeadTextField(
              controller: expectedValueController,
              hintText: context.tr('أدخل القيمة المتوقعة'),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}