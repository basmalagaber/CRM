import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/widgets/app_primary_button.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_basic_data_section.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_schedule_section.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_steps.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/activity_type_placeholder.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/call_details_section.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/email_details_section.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/sms_details_section.dart';
import 'package:erp_system/feature/add_activity/presentation/widgets/visit_details_section.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/products_section.dart';
import 'package:erp_system/feature/customers/presentation/widgets/activity_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_store.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/fonts_manager.dart' show FontConstants, FontSize, FontWeightManager;

class AddActivityScreen extends StatefulWidget {
  final UserRole role;
  final String userName;

  final String? lockedCustomerName;
  final String? lockedCustomerKey;
  final List<Map<String, dynamic>> initialProducts;

  const AddActivityScreen({
    super.key,
    required this.role,
    required this.userName,
    this.lockedCustomerName,
    this.lockedCustomerKey,
    this.initialProducts = const [],
  });

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  int currentStep = 0;

  bool showErrors = false;

  bool get _isCustomerLocked => widget.lockedCustomerName != null;

  final nameController = TextEditingController();
  final commentController = TextEditingController();
  final durationController = TextEditingController(text: '15');

  String? customerType;
  String? prospect;
  String? activityType;
  String? status;
  String? rating;

  DateTime? nextFollowUp;

  final List<Map<String, dynamic>> products = [];

  Map<String, dynamic> activityExtraDetails = {};

  bool _initialized = false;

  List<String> get customerTypes => [
    context.tr('عميل محتمل'),
    context.tr('عميل'),
    context.tr('جهة اتصال'),
  ];

  List<String> get activityTypes => [
    context.tr('بريد الكتروني'),
    context.tr('رسالة نصية'),
    context.tr('زيارة'),
    context.tr('مكالمة'),
  ];

  List<String> get statuses => [
    context.tr('قيد التنفيذ'),
    context.tr('مخطط'),
    context.tr('مكتمل'),
    context.tr('ملغي'),
  ];

  List<String> get ratings => [
    context.tr('جاهز للتعاقد'),
    context.tr('ضعيف الاهتمام'),
    context.tr('موهل للبيع'),
    context.tr('مهتم'),
    context.tr('مهتم جدا'),
  ];

  ThemeData get _theme => Theme.of(context);

  Color get _textColor =>
      _theme.textTheme.bodyLarge?.color ?? ColorManager.textDarkColor;

  Color get _mutedColor =>
      _theme.textTheme.bodyMedium?.color ?? ColorManager.textMutedColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    if (_isCustomerLocked) {
      customerType = context.tr('عميل محتمل');
      prospect = widget.lockedCustomerName;

      products.addAll(
        widget.initialProducts.map((p) => Map<String, dynamic>.from(p)),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    commentController.dispose();
    durationController.dispose();
    super.dispose();
  }

  bool _isBasicDataValid() {
    return customerType != null &&
        prospect != null &&
        activityType != null &&
        nameController.text.trim().isNotEmpty &&
        status != null &&
        commentController.text.trim().isNotEmpty;
  }

  void nextStep() {
    if (currentStep == 0 && !_isBasicDataValid()) {
      setState(() => showErrors = true);
      return;
    }

    if (currentStep < 2) {
      setState(() {
        currentStep++;
        showErrors = false;
      });
    } else {
      saveActivity();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void saveActivity() {
    final isManager = widget.role == UserRole.manager;
    final now = DateTime.now();
    final today =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final Map<String, dynamic> activity = {
      'customerType': customerType,
      'prospect': prospect,
      'activityType': activityType,
      'name': nameController.text.trim(),
      'status': status,
      'approvalStatus': isManager ? 'معتمد' : 'في الانتظار',
      if (isManager) 'approvalDate': today,
      'rating': rating,
      'products': products,
      'comment': commentController.text.trim(),
      'durationMinutes': int.tryParse(durationController.text),
      'nextFollowUp': nextFollowUp?.toIso8601String(),
      'details': activityExtraDetails,
    };

    String? customerKey = widget.lockedCustomerKey;

    if (customerKey == null) {
      final matches =
      CustomerLeadStore.customers.where((c) => c.name == prospect);
      if (matches.isNotEmpty) {
        customerKey = matches.first.customerKey;
      }
    }

    if (customerKey != null) {
      final icon = switch (activityType) {
        'مكالمة' || 'Call' => Icons.call,
        'بريد الكتروني' || 'Email' => Icons.email_outlined,
        'رسالة نصية' || 'SMS' => Icons.sms_outlined,
        'زيارة' || 'Visit' => Icons.location_on_outlined,
        _ => Icons.event,
      };

      ActivityStore.instance.add(customerKey, {
        'name': nameController.text.trim(),
        'description': commentController.text.trim().isNotEmpty
            ? commentController.text.trim()
            : (activityType ?? ''),
        'date': today,
        'statusLabel': status ?? '',
        'statusColor': const Color(0xFF2ED47A),
        'icon': icon,
        'iconColor': const Color(0xFF2F6BFF),
      });
    }

    Navigator.pop(context, activity);
  }

  Future<void> pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
    bool withTime = false,
  }) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );

    if (date == null || !mounted) return;

    if (!withTime) {
      onPicked(date);
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        current ?? now,
      ),
    );

    if (time == null || !mounted) return;

    onPicked(
      DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  void addProduct(Map<String, dynamic> product) {
    setState(() {
      products.add(product);
    });
  }

  void editProduct(int index, Map<String, dynamic> product) {
    setState(() {
      products[index] = product;
    });
  }

  void deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        backgroundColor: _theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                child: ActivitySteps(currentStep: currentStep),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: _buildCurrentStep(),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      color: _theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('إضافة نشاط'),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s22.sp,
                    fontWeight: FontWeightManager.bold,
                    color: _textColor,
                  ),
                ),
                Text(
                  context.trArgs('الخطوة {current} من 3', {
                    'current': currentStep + 1,
                  }),
                  style: TextStyle(
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s12.sp,
                    color: _mutedColor,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: _theme.cardTheme.color,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _theme.dividerColor),
              ),
              child: Icon(Icons.close_rounded, size: 20.sp, color: _textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return Column(
          children: [
            ActivityBasicDataSection(
              hideCustomerFields: _isCustomerLocked,
              nameController: nameController,
              commentController: commentController,
              customerType: customerType,
              prospect: prospect,
              activityType: activityType,
              status: status,
              rating: rating,
              showErrors: showErrors,
              customerTypes: customerTypes,
              activityTypes: activityTypes,
              statuses: statuses,
              ratings: ratings,
              onCustomerTypeChanged: (value) {
                setState(() {
                  customerType = value;
                  prospect = null;
                  products.clear();
                });
              },
              onProspectChanged: (value) {
                _loadProspectProducts(value);

                setState(() {
                  prospect = value;
                });
              },
              onActivityTypeChanged: (value) {
                setState(() {
                  activityType = value;
                  activityExtraDetails = {};
                });
              },
              onStatusChanged: (value) {
                setState(() {
                  status = value;
                });
              },
              prospectNames: CustomerLeadStore.customers
                  .where((customer) {
                if (widget.role == UserRole.manager) {
                  return true;
                }
                return customer.managerName == widget.userName;
              })
                  .map((customer) => customer.name)
                  .toList(),
              onRatingChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            SizedBox(height: 16.h),
            ProductsSection(
              products: products,
              onAddProduct: addProduct,
              onEditProduct: editProduct,
              onDeleteProduct: deleteProduct,
            ),
          ],
        );

      case 1:
        return ActivityScheduleSection(
          durationController: durationController,
          nextFollowUp: nextFollowUp,
          onNextFollowUpChanged: (date) {
            setState(() {
              nextFollowUp = date;
            });
          },
          onPickDate: pickDate,
        );

      default:
        final typeMatches = (activityType ?? '');
        if (typeMatches.contains('بريد') || typeMatches.contains('Email')) {
          return EmailDetailsSection(
            key: const ValueKey('email_details'),
            onChanged: (data) => activityExtraDetails = data,
          );
        } else if (typeMatches.contains('رسالة') || typeMatches.contains('SMS')) {
          return SmsDetailsSection(
            key: const ValueKey('sms_details'),
            onChanged: (data) => activityExtraDetails = data,
          );
        } else if (typeMatches.contains('مكالمة') || typeMatches.contains('Call')) {
          return CallDetailsSection(
            key: const ValueKey('call_details'),
            onChanged: (data) => activityExtraDetails = data,
          );
        } else if (typeMatches.contains('زيارة') || typeMatches.contains('Visit')) {
          return VisitDetailsSection(
            key: const ValueKey('visit_details'),
            onChanged: (data) => activityExtraDetails = data,
          );
        } else {
          return const ActivityTypePlaceholder();
        }
    }
  }

  Widget _buildFooter() {
    final isLastStep = currentStep == 2;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: _theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(top: BorderSide(color: _theme.dividerColor)),

      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: AppPrimaryButton(
                label: isLastStep ? context.tr('حفظ') : context.tr('التالي'),
                icon: isLastStep ? Icons.check_rounded : null,
                onPressed: nextStep,
              ),
            ),
            if (currentStep > 0) ...[
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52.h,
                  child: OutlinedButton(
                    onPressed: previousStep,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      context.tr('السابق'),
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        fontSize: FontSize.s14.sp,
                        fontWeight: FontWeightManager.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  void _loadProspectProducts(String? selectedName) {
    final isProspect = customerType == context.tr('عميل محتمل');

    if (!isProspect || selectedName == null) {
      setState(() {
        products.clear();
      });
      return;
    }

    final matches = CustomerLeadStore.customers.where(
          (customer) => customer.name == selectedName,
    );

    setState(() {
      products.clear();

      if (matches.isNotEmpty) {
        products.addAll(
          matches.first.products.map(
                (product) => <String, dynamic>{
              ...product,
              'unitPrice': product['unitPrice'] ?? product['price'] ?? 0,
              'quantity': product['quantity'] ?? 1,
            },
          ),
        );
      }
    });
  }
}