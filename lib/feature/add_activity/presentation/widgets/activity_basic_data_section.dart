import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_dropdown.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_labeled_field.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_section_card.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityBasicDataSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController commentController;
  final bool hideCustomerFields;

  final String? customerType;
  final String? prospect;
  final String? activityType;
  final String? status;
  final String? rating;

  final bool showErrors;

  final List<String> prospectNames;
  final List<String> customerTypes;
  final List<String> activityTypes;
  final List<String> statuses;
  final List<String> ratings;

  final ValueChanged<String?> onCustomerTypeChanged;
  final ValueChanged<String?> onProspectChanged;
  final ValueChanged<String?> onActivityTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onRatingChanged;

  const ActivityBasicDataSection({
    super.key,
    required this.nameController,
    required this.commentController,
    required this.customerType,
    this.hideCustomerFields = false,
    required this.prospect,
    required this.activityType,
    required this.status,
    required this.rating,
    required this.customerTypes,
    required this.activityTypes,
    required this.statuses,
    required this.prospectNames,
    required this.ratings,
    required this.onCustomerTypeChanged,
    required this.onProspectChanged,
    required this.onActivityTypeChanged,
    required this.onStatusChanged,
    required this.onRatingChanged,
    this.showErrors = false,
  });

  String getLinkedRecordLabel(BuildContext context) {
    if (customerType == context.tr('عميل محتمل') || customerType == 'Lead') {
      return context.tr('العميل المحتمل');
    } else if (customerType == context.tr('عميل') || customerType == 'Customer') {
      return context.tr('العميل');
    } else if (customerType == context.tr('جهة اتصال') || customerType == 'Contact') {
      return context.tr('جهة الاتصال');
    } else {
      return context.tr('السجل المرتبط');
    }
  }

  List<String> get linkedRecords {
    if (customerType == 'عميل محتمل' || customerType == 'Lead') {
      return prospectNames;
    } else if (customerType == 'عميل' || customerType == 'Customer') {
      return ['راندا', 'أحمد', 'منى'];
    } else if (customerType == 'جهة اتصال' || customerType == 'Contact') {
      return ['خالد حسن', 'سارة محمد', 'أحمد علي'];
    } else {
      return [];
    }
  }

  Widget _error(BuildContext context, String? message) {
    if (message == null) return const SizedBox.shrink();

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Text(
          message,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: FontSize.s12.sp,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  String? _requiredError(bool isEmpty, String message) {
    return showErrors && isEmpty ? message : null;
  }

  @override
  Widget build(BuildContext context) {
    final recordLabel = getLinkedRecordLabel(context);

    return Directionality(
      textDirection: context.dir,
      child: LeadSectionCard(
        child: ListenableBuilder(
          listenable: Listenable.merge([nameController, commentController]),
          builder: (context, _) {
            return Column(
              children: [
                if (!hideCustomerFields) ...[
                  LeadLabeledField(
                    label: context.tr('نوع العميل'),
                    requiredField: true,
                    child: Column(
                      children: [
                        LeadDropdown(
                          value: customerType,
                          items: customerTypes,
                          hint: context.tr('اختر نوع العميل'),
                          onChanged: onCustomerTypeChanged,
                        ),
                        _error(
                          context,
                          _requiredError(
                            customerType == null,
                            context.tr('نوع العميل مطلوب'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  LeadLabeledField(
                    label: recordLabel,
                    requiredField: true,
                    child: Column(
                      children: [
                        LeadDropdown(
                          value: prospect,
                          items: linkedRecords,
                          hint: context.trArgs('اختر {label}', {'label': recordLabel}),
                          onChanged: onProspectChanged,
                        ),
                        _error(
                          context,
                          _requiredError(
                            prospect == null,
                            context.trArgs('{label} مطلوب', {'label': recordLabel}),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                LeadLabeledField(
                  label: context.tr('نوع النشاط'),
                  requiredField: true,
                  child: Column(
                    children: [
                      LeadDropdown(
                        value: activityType,
                        items: activityTypes,
                        hint: context.tr('اختر نوع النشاط'),
                        onChanged: onActivityTypeChanged,
                      ),
                      _error(
                        context,
                        _requiredError(activityType == null, context.tr('نوع النشاط مطلوب')),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                LeadLabeledField(
                  label: context.tr('اسم النشاط'),
                  requiredField: true,
                  child: Column(
                    children: [
                      LeadTextField(
                        controller: nameController,
                        hintText: context.tr('أدخل اسم النشاط'),
                      ),
                      _error(
                        context,
                        _requiredError(
                          nameController.text.trim().isEmpty,
                          context.tr('اسم النشاط مطلوب'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                LeadLabeledField(
                  label: context.tr('الحالة'),
                  requiredField: true,
                  child: Column(
                    children: [
                      LeadDropdown(
                        value: status,
                        items: statuses,
                        hint: context.tr('اختر الحالة'),
                        onChanged: onStatusChanged,
                      ),
                      _error(
                        context,
                        _requiredError(status == null, context.tr('الحالة مطلوبة')),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                LeadLabeledField(
                  label: context.tr('التقييم'),
                  child: LeadDropdown(
                    value: rating,
                    items: ratings,
                    hint: context.tr('اختر التقييم'),
                    onChanged: onRatingChanged,
                  ),
                ),
                SizedBox(height: 16.h),
                LeadLabeledField(
                  label: context.tr('التعليق'),
                  requiredField: true,
                  child: Column(
                    children: [
                      LeadTextField(
                        controller: commentController,
                        hintText: context.tr('أضف تعليقًا عن النشاط'),
                        maxLines: 4,
                      ),
                      _error(
                        context,
                        _requiredError(
                          commentController.text.trim().isEmpty,
                          context.tr('التعليق مطلوب'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}