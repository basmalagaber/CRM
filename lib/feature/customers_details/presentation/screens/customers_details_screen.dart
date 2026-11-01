import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/add_activity/presentation/screens/add_activity_screen.dart';
import 'package:erp_system/feature/customers/presentation/widgets/activity_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:erp_system/feature/customers_details/presentation/widgets/activity_type.dart';
import 'package:erp_system/feature/home/presentation/widgets/activity_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/info_overview.dart';
import '../widgets/product_overview.dart';
import '../widgets/records_list.dart';

class CustomersDetailsScreen extends StatefulWidget {
  final CustomerLeadItem customer;
  final ValueChanged<String>? onFilterSelected;

  const CustomersDetailsScreen({
    super.key,
    required this.customer,
    this.onFilterSelected,
  });

  @override
  State<CustomersDetailsScreen> createState() =>
      _CustomersDetailsScreenState();
}

class _CustomersDetailsScreenState
    extends State<CustomersDetailsScreen> {
  String _selectedFilter = 'نظرة عامة';

  static const List<String> _filters = [
    'نظرة عامة',
    'الأنشطة',
    'السجلات',
  ];

  String get _customerKey =>
      widget.customer.phoneNum?.trim().isNotEmpty == true
          ? widget.customer.phoneNum!.trim()
          : widget.customer.name;


  void _logActivity(
      ActivityType type, {
        String? note,
      }) {
    final now = DateTime.now();

    final activity = {
      'name': widget.customer.name,
      'description': note?.trim().isNotEmpty == true
          ? note!.trim()
          : type.label(context),
      'date': '${now.day}/${now.month}/${now.year}',
      'statusLabel': context.tr('تم'),
      'statusColor': ColorManager.statusColor1 ,
      'icon': type.icon,
      'iconColor': type.color,
    };

    ActivityStore.instance.add(
      _customerKey,
      activity,
    );
  }

  Future<void> _addActivity() async {
    final customer = widget.customer;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddActivityScreen(
          role: customer.role,
          userName: customer.userName,
          lockedCustomerName: customer.name,
          lockedCustomerKey: _customerKey,
          initialProducts: customer.products,
        ),
      ),
    );

    if (result == null || !mounted) return;

    customer.onActivityAdded?.call(result);

    setState(() => _selectedFilter = 'الأنشطة');
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: Directionality(
          textDirection: context.dir,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: EdgeInsets.all(16.w),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                      ),

                      SizedBox(width: 8.w),

                      Text(
                        context.tr('العملاء'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),
                child: CustomerLeadItem(
                  name: widget.customer.name,
                  company: widget.customer.company,
                  avatarLetter: widget.customer.avatarLetter,
                  avatarColor: widget.customer.avatarColor,
                  phoneNum: widget.customer.phoneNum,
                  managerName: widget.customer.managerName,
                  status: widget.customer.status,
                  email: widget.customer.email,
                  source: widget.customer.source,
                  nextFollowUp: widget.customer.nextFollowUp,
                  products: widget.customer.products,
                  records: widget.customer.records,
                  activities: widget.customer.activities,
                  role: widget.customer.role,
                  userName: widget.customer.userName,
                  onActivityAdded: widget.customer.onActivityAdded,

                  onTap: () {},

                  onCall: () {
                    _logActivity(
                      ActivityType.call,
                      note: context.tr('تم إجراء مكالمة هاتفية'),
                    );
                  },

                  onWhatsapp: () {
                    _logActivity(
                      ActivityType.whatsapp,
                      note: context.tr('تم التواصل عبر واتساب'),
                    );
                  },

                  onTruecaller: () {
                    _logActivity(
                      ActivityType.call,
                      note: context.tr('تم فتح Truecaller'),
                    );
                  },

                  onMore: widget.customer.onMore,
                ),
              ),

              SizedBox(height: 8.h),

              SizedBox(
                height: 44.h,
                child: Row(
                  children: List.generate(
                    _filters.length,
                        (index) {
                      final filter = _filters[index];

                      final isSelected =
                          filter == _selectedFilter;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });

                            widget.onFilterSelected?.call(
                              filter,
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr(filter),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: theme
                                      .textTheme
                                      .bodyMedium
                                      ?.fontFamily,
                                  fontSize: 15.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),

                              SizedBox(height: 6.h),

                              AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 200,
                                ),
                                height: 2.5.h,
                                width: isSelected
                                    ? 90.w
                                    : 0,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius:
                                  BorderRadius.circular(2.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              Expanded(
                child: SingleChildScrollView(
                  child: _buildSelectedContent(
                    context,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent(
      BuildContext context,
      ) {
    if (_selectedFilter == 'السجلات') {
      return _buildRecords();
    }

    if (_selectedFilter == 'الأنشطة') {
      return _buildActivities();
    }

    return _buildOverview();
  }

  Widget _buildRecords() {
    final records = widget.customer.records;

    if (records.isEmpty) {
      return _buildEmptyState(
        context.tr('لا توجد سجلات لهذا العميل'),
      );
    }

    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context)
                .dividerColor
                .withOpacity(0.3),
          ),
        ),
        child: Column(
          children: List.generate(
            records.length,
                (index) {
              final record = records[index];

              final isLast =
                  index == records.length - 1;

              return RecordsList(
                title:
                record['title']?.toString() ?? '',
                subtitle:
                record['subtitle']?.toString() ?? '',
                date:
                record['date']?.toString() ?? '',
                time:
                record['time']?.toString() ?? '',
                showDivider: !isLast,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAddActivityButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: Center(
        child: SizedBox(
          width: 200.w,
          height: 46.h,
          child: ElevatedButton.icon(
            onPressed: _addActivity,
            icon: Icon(Icons.add_rounded, size: 20.sp),
            label: Text(
              context.tr('إضافة نشاط'),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeightManager.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorManager.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivities() {
    return ValueListenableBuilder<int>(
      valueListenable:
      ActivityStore.instance.changes,
      builder: (context, _, __) {
        final activities = [
          ...ActivityStore.instance.of(
            _customerKey,
          ),
          ...widget.customer.activities,
        ];

        return Column(
          children: [
            if (activities.isEmpty)
              _buildEmptyState(
                context.tr('لا توجد أنشطة لهذا العميل'),
              )
            else
              ...List.generate(
                activities.length,
                    (index) {
                  final activity =
                  activities[index];

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: ActivityItem(
                      name: activity['name']
                          ?.toString() ??
                          widget.customer.name,
                      description:
                      activity['description']
                          ?.toString() ??
                          '',
                      date: activity['date']
                          ?.toString() ??
                          '',
                      statusLabel:
                      activity['statusLabel']
                          ?.toString() ??
                          context.tr('مخطط'),
                      statusColor:
                      activity['statusColor']
                      as Color? ??
                          ColorManager.statusColor2,
                      icon: activity['icon']
                      as IconData? ??
                          Icons.call_rounded,
                      iconColor:
                      activity['iconColor']
                      as Color? ??
                          ColorManager.statusColor3,
                    ),
                  );
                },
              ),
            _buildAddActivityButton(),
          ],
        );
      },
    );
  }

  Widget _buildOverview() {
    final customer = widget.customer;

    final infoList = [
      InfoOverview(
        label: context.tr('الهاتف'),
        value:
        customer.phoneNum?.isNotEmpty == true
            ? customer.phoneNum!
            : context.tr('غير محدد'),
      ),
      InfoOverview(
        label: context.tr('البريد الإلكتروني'),
        value:
        customer.email?.isNotEmpty == true
            ? customer.email!
            : context.tr('غير محدد'),
      ),
      InfoOverview(
        label: context.tr('المصدر'),
        value:
        customer.source?.isNotEmpty == true
            ? customer.source!
            : context.tr('غير محدد'),
      ),
      InfoOverview(
        label: context.tr('المسؤول'),
        value:
        customer.managerName?.isNotEmpty == true
            ? customer.managerName!
            : context.tr('غير محدد'),
      ),
      InfoOverview(
        label: context.tr('المتابعة القادمة'),
        value:
        customer.nextFollowUp?.isNotEmpty == true
            ? customer.nextFollowUp!
            : context.tr('غير محدد'),
      ),
    ];

    return Column(
      children: [

        Padding(
          padding: EdgeInsets.all(16.w),
          child: Container(
            decoration: BoxDecoration(
              color:
              Theme.of(context).cardTheme.color,
              borderRadius:
              BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context)
                    .dividerColor
                    .withOpacity(0.3),
              ),
            ),
            child: Column(
              children: List.generate(
                infoList.length,
                    (index) {
                  final isLast =
                      index == infoList.length - 1;

                  final item = infoList[index];

                  return InfoOverview(
                    label: item.label,
                    value: item.value,
                    showDivider: !isLast,
                  );
                },
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
            decoration: BoxDecoration(
              color:
              Theme.of(context).cardTheme.color,
              borderRadius:
              BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context)
                    .dividerColor
                    .withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    14.h,
                    16.w,
                    4.h,
                  ),
                  child: Text(
                    context.tr('المنتجات المهتم بها'),
                    style: TextStyle(
                      fontFamily: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color,
                    ),
                  ),
                ),

                if (customer.products.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Text(
                        context.tr('لا توجد منتجات'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    customer.products.length,
                        (index) {
                      final isLast =
                          index ==
                              customer.products.length -
                                  1;

                      final product =
                      customer.products[index];

                      return ProductOverview(
                        name: product['name']
                            ?.toString() ??
                            context.tr('غير محدد'),
                        quantity:
                        _getInt(
                          product['quantity'],
                        ),
                        price:
                        product['price']
                            ?.toString() ??
                            '0',
                        currency:
                        product['currency']
                            ?.toString() ??
                            'AED',
                        showDivider: !isLast,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      String message,
      ) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  int _getInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}