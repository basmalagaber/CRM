import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/lead_date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'lead_dropdown.dart';
import 'lead_labeled_field.dart';
import 'lead_section_card.dart';
import 'lead_text_field.dart';

class PersonalDataSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController companyController;
  final TextEditingController phoneController;
  final TextEditingController phone2Controller;
  final TextEditingController jobTitleController;
  final TextEditingController emailController;
  final TextEditingController activityDateController;
  final bool showValidationErrors;
  final String? dial1;
  final String? dial2;
  final String? source;
  final List<String> selectedChannels;

  final ValueChanged<String?> onDial1Changed;
  final ValueChanged<String?> onDial2Changed;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<List<String>> onChannelsChanged;

  final List<String> dialCodes;
  final List<String> sources;
  final List<String> channelOptions;

  const PersonalDataSection({
    super.key,
    required this.nameController,
    required this.companyController,
    required this.phoneController,
    required this.phone2Controller,
    required this.jobTitleController,
    required this.emailController,
    required this.activityDateController,
    required this.dial1,
    required this.dial2,
    required this.source,
    required this.selectedChannels,
    required this.onDial1Changed,
    required this.onDial2Changed,
    required this.onSourceChanged,
    required this.onChannelsChanged,
    required this.dialCodes,
    required this.sources,
    required this.channelOptions,
    required this.showValidationErrors,
  });

  @override
  State<PersonalDataSection> createState() => _PersonalDataSectionState();
}

class _PersonalDataSectionState extends State<PersonalDataSection> {
  bool get _isPhoneDuplicated {
    final phone1 = widget.phoneController.text.trim();
    final phone2 = widget.phone2Controller.text.trim();

    if (phone1.isEmpty || phone2.isEmpty) {
      return false;
    }

    return phone1 == phone2;
  }

  bool get _hasPhone {
    final phone1 = widget.phoneController.text.trim();
    final phone2 = widget.phone2Controller.text.trim();

    return phone1.isNotEmpty || phone2.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    widget.phoneController.addListener(_onFieldChanged);
    widget.phone2Controller.addListener(_onFieldChanged);
    widget.nameController.addListener(_onFieldChanged);
    widget.activityDateController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(_onFieldChanged);
    widget.phone2Controller.removeListener(_onFieldChanged);
    widget.nameController.removeListener(_onFieldChanged);
    widget.activityDateController.removeListener(_onFieldChanged);

    super.dispose();
  }

  Future<void> _pickChannels() async {
    final theme = Theme.of(context);

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _ChannelsSheet(
        options: widget.channelOptions,
        selected: widget.selectedChannels,
      ),
    );

    if (result != null) {
      widget.onChannelsChanged(result);
    }
  }

  Future<void> _pickActivityDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    widget.activityDateController.text =
    '${date.day}/${date.month}/${date.year} - ${time.format(context)}';
  }

  Widget _errorText(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, right: 4.w),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: FontConstants.fontFamily,
          fontSize: FontSize.s12.sp,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LeadSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LeadLabeledField(
            label: context.tr('اسم العميل'),
            requiredField: true,
            child: LeadTextField(
              controller: widget.nameController,
              hintText: context.tr('أدخل اسم العميل'),
              errorText: widget.showValidationErrors &&
                  widget.nameController.text.trim().isEmpty
                  ? context.tr('اسم العميل مطلوب')
                  : null,
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('اسم الشركة (اختياري)'),
            child: LeadTextField(
              controller: widget.companyController,
              hintText: context.tr('اسم الشركة'),
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('وسائل التواصل المفضلة'),
            child: _ChannelsField(
              selected: widget.selectedChannels,
              onTap: _pickChannels,
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('رقم الهاتف'),
            requiredField: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 105.w,
                      child: LeadDropdown(
                        value: widget.dial1,
                        items: widget.dialCodes,
                        hint: context.tr('الكود'),
                        onChanged: widget.onDial1Changed,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: LeadTextField(
                        controller: widget.phoneController,
                        hintText: context.tr('رقم الهاتف'),
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
                if (widget.showValidationErrors && !_hasPhone)
                  _errorText(context.tr('يجب إدخال رقم هاتف واحد على الأقل')),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('رقم هاتف إضافي'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 105.w,
                  child: LeadDropdown(
                    value: widget.dial2,
                    items: widget.dialCodes,
                    hint: context.tr('الكود'),
                    onChanged: widget.onDial2Changed,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: LeadTextField(
                    controller: widget.phone2Controller,
                    hintText: context.tr('رقم إضافي'),
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    errorText: _isPhoneDuplicated
                        ? context.tr('رقم الموبايل لا يجب أن يساوي رقم الهاتف')
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('مصدر العميل'),
            requiredField: true,
            child: LeadDropdown(
              value: widget.source,
              items: widget.sources,
              hint: context.tr('اختر المصدر'),
              onChanged: widget.onSourceChanged,
              errorText: widget.showValidationErrors && widget.source == null
                  ? context.tr('مصدر العميل مطلوب')
                  : null,
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('المسمى الوظيفي (اختياري)'),
            child: LeadTextField(
              controller: widget.jobTitleController,
              hintText: context.tr('المسمى الوظيفي'),
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('البريد الإلكتروني (اختياري)'),
            child: LeadTextField(
              controller: widget.emailController,
              hintText: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
            ),
          ),
          SizedBox(height: 16.h),

          LeadLabeledField(
            label: context.tr('تاريخ النشاط'),
            child: LeadDateField(
              text: widget.activityDateController.text,
              hint: context.tr('اختر التاريخ والوقت'),
              onTap: _pickActivityDate,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelsField extends StatelessWidget {
  final List<String> selected;
  final VoidCallback onTap;

  const _ChannelsField({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasValue = selected.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),

        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? selected.map((e) => context.tr(e)).join('، ') : context.tr('اختر وسائل التواصل'),
                textAlign: context.isArabic ? TextAlign.right : TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s14.sp,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue
                      ? theme.textTheme.bodyLarge?.color
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24.sp,
              color: primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelsSheet extends StatefulWidget {
  final List<String> options;
  final List<String> selected;

  const _ChannelsSheet({required this.options, required this.selected});

  @override
  State<_ChannelsSheet> createState() => _ChannelsSheetState();
}

class _ChannelsSheetState extends State<_ChannelsSheet> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = [...widget.selected];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Directionality(
      textDirection: context.dir,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                context.tr('اختر وسائل التواصل'),
                style: TextStyle(
                  fontFamily: FontConstants.fontFamily,
                  fontSize: FontSize.s16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 14.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 10.h,
                children: widget.options.map((option) {
                  final isSelected = selected.contains(option);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected
                            ? selected.remove(option)
                            : selected.add(option);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary.withOpacity(0.12)
                            : theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: isSelected
                              ? primary
                              : theme.dividerColor.withOpacity(0.7),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Icon(Icons.check_rounded,
                                size: 16.sp, color: primary),
                            SizedBox(width: 4.w),
                          ],
                          Text(
                            context.tr(option),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: FontSize.s14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? primary
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                    foregroundColor: ColorManager.iconColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    context.tr('تم'),
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
      ),
    );
  }
}