import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/activities/presentation/screens/activities_screen.dart';
import 'package:erp_system/feature/add_lead/presentation/screens/add_lead_screen.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_store.dart';
import 'package:erp_system/feature/clients/data/client_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/activity_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/change_manager.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_manager_service.dart';
import 'package:erp_system/feature/customers/presentation/widgets/merge_customer.dart';
import 'package:erp_system/feature/customers_details/presentation/widgets/activity_type.dart';
import 'package:erp_system/feature/home/presentation/widgets/app_bar_screen.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:erp_system/feature/notification/presentation/widgets/notification_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/customers_filter_section.dart';



class CustomersScreen extends StatefulWidget {
  const CustomersScreen({
    super.key,
    required this.role,
    required this.userInitial,
    required this.userName,
  });

  final UserRole role;
  final String userInitial;
  final String userName;

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  static const String _allFilter = 'الكل';
  static const String _autoAssign = 'تعيين تلقائي';
  static const String _notSpecified = 'غير محدد';

  int _nextEmployeeIndex = 0;

  bool get _isManager => widget.role == UserRole.manager;

  bool get _canAddCustomers =>
      widget.role == UserRole.manager || widget.role == UserRole.leader;

  List<CustomerLeadItem> get _allCustomers {
    if (_canAddCustomers) {
      return CustomerLeadStore.customers;
    }

    return CustomerLeadStore.customers
        .where((customer) => customer.managerName == widget.userName)
        .toList();
  }

  List<CustomerLeadItem> _filteredCustomers = [];

  String _searchQuery = '';

  String _selectedFilter = _allFilter;

  @override
  void initState() {
    super.initState();

    _filteredCustomers = List.from(_allCustomers);
  }

  String _getNextEmployee() {
    final employee = kEmployees[_nextEmployeeIndex];

    _nextEmployeeIndex = (_nextEmployeeIndex + 1) % kEmployees.length;

    return employee;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();

      _applyFilters();
    });
  }

  void _onFilterSelected(String filterLabel) {
    setState(() {
      _selectedFilter = filterLabel;

      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredCustomers = _allCustomers.where((customer) {
      final name = customer.name.toLowerCase();
      final company = customer.company.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          company.contains(_searchQuery);

      final matchesStatus =
          _selectedFilter == _allFilter || customer.status.label == _selectedFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  String _getCustomerKey(CustomerLeadItem customer) {
    return customer.phoneNum?.trim().isNotEmpty == true
        ? customer.phoneNum!.trim()
        : customer.name;
  }

  void _logActivity(
      CustomerLeadItem customer,
      ActivityType type, {
        String? note,
      }) {
    final now = DateTime.now();

    final activity = {
      'name': customer.name,
      'description': note?.trim().isNotEmpty == true
          ? note!.trim()
          : type.label(context),
      'date': '${now.day}/${now.month}/${now.year}',
      'statusLabel': context.tr('تم'),
      'statusColor': ColorManager.statusColor1,
      'icon': type.icon,
      'iconColor': type.color,
    };

    ActivityStore.instance.add(
      _getCustomerKey(customer),
      activity,
    );
  }

  void _onActivityAdded(
      CustomerLeadItem customer,
      Map<String, dynamic> result,
      ) {
    final card = ActivitiesListStore.buildCard(
      result,
      owner: widget.userName,
      phone: customer.phoneNum ?? '',
    );

    ActivitiesListStore.activities.insert(0, card);

    ApprovalStore.add(
      title: 'نشاط',
      requester: widget.userName,
      customer: customer.name,
      source: card,
      autoApproved: _isManager,
    );

    if (!_isManager) {
      NotificationStore.notifyManagers(
        type: AppNotificationType.approvalRequest,
        title: context.tr('طلب نشاط جديد'),
        body: context.trArgs(
          '{role} {owner} أضاف نشاطًا ({type}) للعميل {customer} — كود الطلب {code} بانتظار اعتمادك.',
          {
            'role': context.tr(AppSession.roleLabel(widget.role)),
            'owner': widget.userName,
            'type': context.tr('${card['type']}'),
            'customer': customer.name,
            'code': '${card['code']}',
          },
        ),
        data: {'code': card['code']},
      );
    }
  }

  void _onChangeManager(
      CustomerLeadItem customer,
      String newManager,
      String? reason,
      ) {
    final messenger = ScaffoldMessenger.of(context);

    if (_isManager) {
      CustomerManagerService.apply(customer.customerKey, newManager);

      setState(_applyFilters);

      if (newManager != widget.userName) {
        NotificationStore.notifyUser(
          userName: newManager,
          type: AppNotificationType.newLead,
          title: context.tr('تم إسناد عميل لك'),
          body: context.trArgs(
            'قام المدير {manager} بإسنادك كمسؤول عن العميل "{customer}".',
            {'manager': widget.userName, 'customer': customer.name},
          ),
          data: {'customer': customer.name},
        );
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.trArgs('تم تغيير المسؤول إلى {name}', {'name': newManager}),
          ),
        ),
      );
      return;
    }

    ApprovalStore.add(
      title: 'تغيير مسؤول عميل',
      requester: widget.userName,
      newOwner: newManager,
      customer: customer.name,
      autoApproved: false,
      details: {
        'action': 'changeManager',
        'customerKey': customer.customerKey,
        'oldOwner': customer.managerName,
        'newOwner': newManager,
        'reason': reason,
      },
    );

    final reasonText = (reason ?? '').trim();

    NotificationStore.notifyManagers(
      type: AppNotificationType.approvalRequest,
      title: context.tr('طلب تغيير مسؤول العميل'),
      body: context.trArgs(
        'طلب {role} {user} تغيير مسؤول العميل "{customer}" إلى {newManager}',
        {
          'role': context.tr(AppSession.roleLabel(widget.role)),
          'user': widget.userName,
          'customer': customer.name,
          'newManager': newManager,
        },
      ) +
          (reasonText.isEmpty ? '' : ' (${context.tr('السبب')}: $reasonText)'),
      data: {'customer': customer.name},
    );

    messenger.showSnackBar(
      SnackBar(content: Text(context.tr('تم إرسال طلب التغيير للموافقة'))),
    );
  }

  void _onConvertToClient(CustomerLeadItem customer, String client) {
    final isNew = client == kConvertToNewClient;

    ClientStore.convertLead(
      customer,
      existingClientName: isNew ? null : client,
    );

    setState(_applyFilters);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNew
              ? context.trArgs(
            'تم تحويل {name} لعميل جديد',
            {'name': customer.name},
          )
              : context.trArgs(
            'تم ربط {name} بالعميل {client}',
            {'name': customer.name, 'client': client},
          ),
        ),
      ),
    );
  }

  void _onMerge(
      CustomerLeadItem keep,
      CustomerLeadItem duplicate,
      Set<MergeField> takeFromDuplicate,
      ) {
    final ok = CustomerManagerService.merge(
      keep.customerKey,
      duplicate.customerKey,
      takeFromDuplicate: takeFromDuplicate,
    );

    setState(_applyFilters);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? context.trArgs(
            'تم دمج {dup} مع {keep}',
            {'dup': duplicate.name, 'keep': keep.name},
          )
              : context.tr('تعذر إكمال الدمج'),
        ),
      ),
    );
  }

  void _onDelete(CustomerLeadItem customer) {
    final ok = CustomerManagerService.delete(customer.customerKey);

    setState(_applyFilters);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? context.trArgs('تم حذف {name}', {'name': customer.name})
              : context.tr('تعذر حذف العميل'),
        ),
      ),
    );
  }

  Widget _buildCustomerItem(CustomerLeadItem customer) {
    return CustomerLeadItem(
      name: customer.name,
      company: customer.company,
      avatarLetter: customer.avatarLetter,
      avatarColor: customer.avatarColor,
      phoneNum: customer.phoneNum,
      managerName: customer.managerName,
      status: customer.status,
      email: customer.email,
      source: customer.source,
      nextFollowUp: customer.nextFollowUp,
      products: customer.products,
      records: customer.records,
      activities: customer.activities,
      role: widget.role,
      userName: widget.userName,
      onTap: customer.onTap,
      onActivityAdded: (result) => _onActivityAdded(customer, result),
      onChangeManager: (newManager, reason) =>
          _onChangeManager(customer, newManager, reason),
      onConvertToClient: (client) => _onConvertToClient(customer, client),
      onMerge: (duplicate, takeFromDuplicate) =>
          _onMerge(customer, duplicate, takeFromDuplicate),
      onDelete: () => _onDelete(customer),
      onCall: () {
        customer.onCall?.call();

        _logActivity(
          customer,
          ActivityType.call,
          note: context.tr('تم إجراء مكالمة هاتفية'),
        );
      },
      onWhatsapp: () {
        customer.onWhatsapp?.call();

        _logActivity(
          customer,
          ActivityType.whatsapp,
          note: context.tr('تم التواصل عبر واتساب'),
        );
      },
      onTruecaller: () {
        customer.onTruecaller?.call();

        _logActivity(
          customer,
          ActivityType.call,
          note: context.tr('تم فتح Truecaller'),
        );
      },
      onMore: customer.onMore,
    );
  }

  Future<void> _addCustomer() async {
    final addedCustomer = await Navigator.push<CustomerLeadItem>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddLeadScreen(),
      ),
    );

    if (addedCustomer == null || !mounted) {
      return;
    }

    CustomerLeadItem customer = addedCustomer;

    if (addedCustomer.managerName == _autoAssign) {
      final assignedEmployee = _getNextEmployee();

      customer = CustomerLeadItem(
        name: addedCustomer.name,
        company: addedCustomer.company,
        avatarLetter: addedCustomer.avatarLetter,
        avatarColor: addedCustomer.avatarColor,
        phoneNum: addedCustomer.phoneNum,
        managerName: assignedEmployee,
        status: addedCustomer.status,
        email: addedCustomer.email,
        source: addedCustomer.source,
        nextFollowUp: addedCustomer.nextFollowUp,
        products: addedCustomer.products,
        records: addedCustomer.records,
        activities: addedCustomer.activities,
        onTap: addedCustomer.onTap,
        onCall: addedCustomer.onCall,
        onWhatsapp: addedCustomer.onWhatsapp,
        onTruecaller: addedCustomer.onTruecaller,
        onMore: addedCustomer.onMore,
        onMenuAction: addedCustomer.onMenuAction,
        onEdited: addedCustomer.onEdited,
      );
    }

    CustomerLeadStore.add(customer);
    ApprovalStore.add(
      title: 'تعيين مسؤول لعميل جديد',
      requester: widget.userName,
      newOwner: customer.managerName ?? _notSpecified,
      customer: customer.name,
      autoApproved: _isManager,
      details: {
        'customerPhone': customer.phoneNum,
        'company': customer.company,
        'email': customer.email,
        'source': customer.source,
        'status': customer.status.label,
        'nextFollowUp': customer.nextFollowUp,
        'products': customer.products,
        'records': customer.records,
        'activities': customer.activities,
      },
    );

    final assignedTo = (customer.managerName ?? '').trim();

    if (_isManager) {
      if (assignedTo.isNotEmpty &&
          assignedTo != _notSpecified &&
          assignedTo != widget.userName) {
        NotificationStore.notifyUser(
          userName: assignedTo,
          type: AppNotificationType.newLead,
          title: context.tr('تم إضافة عميل جديد لك'),
          body: context.trArgs(
            'قام المدير {manager} بإضافة العميل "{customer}" وإسناده لك. يرجى البدء بالمتابعة.',
            {'manager': widget.userName, 'customer': customer.name},
          ),
          data: {'customer': customer.name},
        );
      }
    } else {
      NotificationStore.notifyManagers(
        type: AppNotificationType.approvalRequest,
        title: context.tr('طلب إسناد مسؤول لعميل جديد'),
        body: context.trArgs(
          'قام {role} {user} بإضافة العميل "{customer}" وطلب إسناده إلى {assignedTo}.',
          {
            'role': context.tr(AppSession.roleLabel(widget.role)),
            'user': widget.userName,
            'customer': customer.name,
            'assignedTo': assignedTo,
          },
        ),
        data: {'customer': customer.name},
      );
    }

    setState(() {
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _canAddCustomers
          ? FloatingActionButton.extended(
        heroTag: 'customers_fab',
        onPressed: _addCustomer,
        backgroundColor: ColorManager.primaryColor,
        foregroundColor: ColorManager.iconColor,
        elevation: 4,
        shape: const StadiumBorder(),
        icon: Icon(Icons.add_rounded, size: 24.sp),
        label: Text(
          context.tr('عميل جديد'),
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: FontSize.s14.sp,
            fontWeight: FontWeightManager.bold,
            color: ColorManager.iconColor,
          ),
        ),
      )
          : null,
      appBar: AppBarScreen(
        userInitial: widget.userInitial,
        title: context.tr('العملاء المحتملون'),
        onNotificationsTap: () {},
        onAvatarTap: () {},
      ),
      body: Directionality(
        textDirection: context.dir,
        child: ValueListenableBuilder<int>(
          valueListenable: ApprovalStore.changes,
          builder: (context, _, __) {
            _applyFilters();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomersFilterSection(
                  totalCustomers: _allCustomers.length,
                  newCustomers: _allCustomers
                      .where(
                        (customer) => customer.status == LeadStatus.newLead,
                  )
                      .length,
                  qualifiedCustomers: _allCustomers
                      .where(
                        (customer) => customer.status == LeadStatus.qualified,
                  )
                      .length,
                  mergedCustomers: _allCustomers
                      .where(
                        (customer) => customer.status == LeadStatus.merged,
                  )
                      .length,
                  onSearchChanged: _onSearchChanged,
                  onFilterSelected: _onFilterSelected,
                ),
                Expanded(
                  child: _filteredCustomers.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];

                      return _buildCustomerItem(customer);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: ColorManager.primaryColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 40.sp,
                color: ColorManager.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isSearching
                  ? context.tr('لا توجد نتائج مطابقة')
                  : context.tr('لا يوجد عملاء بعد'),
              style: theme.textTheme.titleSmall,
            ),
            if (!isSearching && _canAddCustomers) ...[
              SizedBox(height: 6.h),
              Text(
                context.tr('اضغط على زر "عميل جديد" لإضافة أول عميل'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: FontSize.s12.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}