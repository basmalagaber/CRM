import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/add_lead_footer.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/add_lead_steps.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_location_section.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_store.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/personal_data_section.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/products_section.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/responsible_employee_section.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/sales_pipeline_section.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/colors_manager.dart';
import '../widgets/add_lead_header.dart';

class AddLeadScreen extends StatefulWidget {
  final CustomerLeadItem? initialLead;

  final bool readOnly;

  const AddLeadScreen({
    super.key,
    this.initialLead,
    this.readOnly = false,
  });

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  int currentStep = 0;
  bool showValidationErrors = false;

  bool get isEdit => widget.initialLead != null;
  bool get isReadOnly => widget.readOnly;

  final ScrollController _scrollController = ScrollController();

  // Personal data
  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final phoneController = TextEditingController();
  final phone2Controller = TextEditingController();
  final jobTitleController = TextEditingController();
  final emailController = TextEditingController();
  final activityDateController = TextEditingController();

  // Location / value
  final addressController = TextEditingController();
  final expectedValueController = TextEditingController();

  // Sales pipeline
  final descriptionController = TextEditingController();

  // Temporary UI state
  String? dial1;
  String? dial2;
  String? source;
  String? country;
  String? region;
  String? currency;
  String? assignMode;
  String? responsibleEmployee;
  String? priority;

  List<String> selectedChannels = [];

  static const List<String> employees = [
    'محمد',
    'احمد',
    'بسملة',
    'علي',
    'عمرو',
  ];

  final List<Map<String, dynamic>> products = [];

  static const List<String> dialCodes = [
    '+20',
    '+966',
    '+971',
    '+974',
    '+965',
  ];

  static const List<String> sources = [
    'إعلانات جوجل',
    'اتصال تسويقي مباشر',
    'اتصال مباشر',
    'الموقع الإلكتروني',
    'ترشيح عميل',
    'حملة بريد إلكتروني',
    'فيسبوك',
    'لينكدإن',
    'معرض أو فعالية',
    'شريك أعمال',
    'سمسار',
    'مصدر آخر',
  ];

  static const List<String> channelOptions = [
    'البريد الإلكتروني',
    'الموقع الإلكتروني',
    'رسالة نصية',
    'هاتف',
    'واتساب',
  ];

  static const List<String> countries = [
    'مصر',
    'السعودية',
    'الإمارات',
    'قطر',
    'الكويت',
  ];

  static const List<String> regions = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'بني سويف',
    'المنصورة',
  ];

  static const List<String> currencies = [
    'جنيه مصري',
    'ريال سعودي',
    'درهم إماراتي',
    'ريال قطري',
    'دينار كويتي',
  ];

  static const List<String> priorities = [
    'عاجل',
    'عادي',
    'عالي',
    'منخفض',
  ];

  static const List<String> assignModes = [
    'تعيين تلقائي',
    'تعيين يدوي',
  ];

  @override
  void initState() {
    super.initState();

    final lead = widget.initialLead;
    if (lead == null) return;

    nameController.text = lead.name;

    companyController.text = lead.company == 'بدون شركة' ? '' : lead.company;

    phoneController.text = lead.phoneNum ?? '';
    emailController.text = lead.email ?? '';
    activityDateController.text = lead.nextFollowUp ?? '';

    if (lead.source != null && sources.contains(lead.source)) {
      source = lead.source;
    }

    if (lead.managerName != null && assignModes.contains(lead.managerName)) {
      assignMode = lead.managerName;
    } else if (lead.managerName != null &&
        employees.contains(lead.managerName)) {
      assignMode = 'تعيين يدوي';
      responsibleEmployee = lead.managerName;
    }

    products.addAll(
      lead.products.map(
            (p) => <String, dynamic>{
          ...p,
          'unitPrice': p['unitPrice'] ?? p['price'] ?? 0,
          'quantity': p['quantity'] ?? 1,
        },
      ),
    );
  }

  bool validateStepOne() {
    final name = nameController.text.trim();
    final phone1 = phoneController.text.trim();
    final phone2 = phone2Controller.text.trim();

    final hasPhone = phone1.isNotEmpty || phone2.isNotEmpty;

    final isPhoneDuplicated =
        phone1.isNotEmpty && phone2.isNotEmpty && phone1 == phone2;

    if (name.isEmpty || !hasPhone || source == null || isPhoneDuplicated) {
      setState(() {
        showValidationErrors = true;
      });

      return false;
    }

    setState(() {
      showValidationErrors = false;
    });

    return true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    phone2Controller.dispose();
    jobTitleController.dispose();
    emailController.dispose();
    activityDateController.dispose();
    addressController.dispose();
    expectedValueController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void nextStep() {
    if (isReadOnly) {
      if (currentStep == 0) {
        setState(() {
          currentStep++;
        });
      } else {
        Navigator.pop(context);
      }
      return;
    }

    if (currentStep == 0) {
      if (!validateStepOne()) {
        return;
      }

      setState(() {
        currentStep++;
      });

      return;
    }

    saveLead();
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void saveLead() {
    if (isReadOnly) return;

    final name = nameController.text.trim();
    final old = widget.initialLead;

    final savedProducts = products.map((p) {
      final unitPrice = (p['unitPrice'] ?? 0) as num;
      return <String, dynamic>{
        ...p,
        'price': unitPrice.toStringAsFixed(0),
        'currency': p['currency'] ?? context.tr('ج.م'),
      };
    }).toList();

    final customer = CustomerLeadItem(
      name: name,
      company: companyController.text.trim().isEmpty
          ? context.tr('بدون شركة')
          : companyController.text.trim(),

      avatarLetter: name.isNotEmpty ? name.substring(0, 1) : '؟',

      avatarColor: old?.avatarColor ?? ColorManager.primaryColor,

      status: old?.status ?? LeadStatus.newLead,

      phoneNum: phoneController.text.trim(),
      managerName: responsibleEmployee ?? assignMode ?? context.tr('غير محدد'),

      email: emailController.text.trim(),
      source: source ?? context.tr('غير محدد'),
      nextFollowUp: activityDateController.text.trim(),

      products: savedProducts,

      records: old?.records ??
          [
            {
              'title': context.tr('إنشاء العميل'),
              'subtitle': context.tr('تم إنشاء العميل'),
              'date': context.tr('اليوم'),
              'time': TimeOfDay.now().format(context),
            },
          ],

      activities: old?.activities ?? [],

      onCall: old?.onCall ?? () {},
      onWhatsapp: old?.onWhatsapp ?? () {},
      onTruecaller: old?.onTruecaller,
      onMore: old?.onMore ?? () {},
      onMenuAction: old?.onMenuAction,
      onEdited: old?.onEdited,
    );

    if (isEdit) {
      LeadStore.updateLead(customer);
    } else {
      LeadStore.addLead(customer);
    }

    Navigator.pop(context, customer);
  }

  void updateChannels(List<String> channels) {
    setState(() {
      selectedChannels = channels;
    });
  }

  void addProduct(Map<String, dynamic> product) {
    setState(() {
      products.add(product);
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              AddLeadHeader(
                onClose: () {
                  Navigator.pop(context);
                },
              ),

              AddLeadSteps(
                currentStep: currentStep,
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    12.h,
                    16.w,
                    24.h + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: IgnorePointer(
                    ignoring: isReadOnly,
                    child: currentStep == 0
                        ? Column(
                      children: [
                        PersonalDataSection(
                          nameController: nameController,
                          companyController: companyController,
                          phoneController: phoneController,
                          phone2Controller: phone2Controller,
                          jobTitleController: jobTitleController,
                          emailController: emailController,
                          activityDateController:
                          activityDateController,

                          dial1: dial1,
                          dial2: dial2,
                          source: source,
                          selectedChannels: selectedChannels,

                          onDial1Changed: (value) {
                            setState(() {
                              dial1 = value;
                            });
                          },

                          onDial2Changed: (value) {
                            setState(() {
                              dial2 = value;
                            });
                          },

                          onSourceChanged: (value) {
                            setState(() {
                              source = value;
                            });
                          },

                          onChannelsChanged: updateChannels,

                          dialCodes: dialCodes,
                          sources: sources,
                          channelOptions: channelOptions,

                          showValidationErrors: showValidationErrors,
                        ),

                        SizedBox(height: 16.h),

                        LeadLocationSection(
                          addressController: addressController,
                          expectedValueController:
                          expectedValueController,
                          country: country,
                          region: region,
                          currency: currency,
                          onCountryChanged: (value) {
                            setState(() {
                              country = value;
                            });
                          },
                          onRegionChanged: (value) {
                            setState(() {
                              region = value;
                            });
                          },
                          onCurrencyChanged: (value) {
                            setState(() {
                              currency = value;
                            });
                          },
                          countries: countries,
                          regions: regions,
                          currencies: currencies,
                        ),

                        SizedBox(height: 16.h),

                        ResponsibleEmployeeSection(
                          assignMode: assignMode,
                          responsibleEmployee: responsibleEmployee,

                          onAssignModeChanged: (value) {
                            setState(() {
                              assignMode = value;

                              if (value != 'تعيين يدوي') {
                                responsibleEmployee = null;
                              }
                            });

                            if (value == 'تعيين يدوي') {
                              _scrollToBottom();
                            }
                          },

                          onResponsibleEmployeeChanged: (value) {
                            setState(() {
                              responsibleEmployee = value;
                            });
                          },

                          assignModes: assignModes,
                          employees: employees,
                        ),
                      ],
                    )
                        : Column(
                      children: [
                        ProductsSection(
                          products: products,
                          onAddProduct: (p) =>
                              setState(() => products.add(p)),
                          onDeleteProduct: (i) =>
                              setState(() => products.removeAt(i)),
                          onEditProduct: (i, p) =>
                              setState(() => products[i] = p),
                        ),

                        SizedBox(height: 16.h),

                        SalesPipelineSection(
                          priority: priority,
                          descriptionController: descriptionController,
                          onPriorityChanged: (value) {
                            setState(() {
                              priority = value;
                            });
                          },
                          priorities: priorities,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              AddLeadFooter(
                currentStep: currentStep,
                onBack: previousStep,
                onNext: nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}