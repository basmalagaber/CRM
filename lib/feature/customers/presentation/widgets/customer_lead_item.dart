import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/app_decorations.dart';
import 'package:erp_system/feature/add_activity/presentation/screens/add_activity_screen.dart';
import 'package:erp_system/feature/add_lead/presentation/screens/add_lead_screen.dart';
import 'package:erp_system/feature/clients/data/client_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/activity_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/change_manager.dart';
import 'package:erp_system/feature/customers/presentation/widgets/convert_to_client_dialog.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_activities_screen.dart';
import 'package:erp_system/feature/customers/presentation/widgets/merge_customer.dart';
import 'package:erp_system/feature/customers_details/presentation/widgets/activity_type.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';
import '../../../../core/routes_manager/routes.dart';
import 'customer_actions_menu.dart';
import 'customer_lead_store.dart';
import 'record_store.dart';

enum LeadStatus { newLead, contacted, qualified, lost, converted, merged }

extension LeadStatusData on LeadStatus {
  String get label {
    switch (this) {
      case LeadStatus.newLead:
        return 'جديد';
      case LeadStatus.contacted:
        return 'تم التواصل';
      case LeadStatus.qualified:
        return 'مؤهل';
      case LeadStatus.lost:
        return 'خسارة';
      case LeadStatus.converted:
        return 'محوّل';
      case LeadStatus.merged:
        return 'مدمج';
    }
  }

  Color get color {
    switch (this) {
      case LeadStatus.newLead:
        return const Color(0xFF2F6BFF);
      case LeadStatus.contacted:
        return const Color(0xFF29C7E0);
      case LeadStatus.qualified:
        return const Color(0xFF2ED47A);
      case LeadStatus.lost:
        return const Color(0xFFE84C6D);
      case LeadStatus.converted:
        return const Color(0xFF9C6BFF);
      case LeadStatus.merged:
        return const Color(0xFFFF9F1C);
    }
  }
}

String normalizePhone(String raw, {String defaultDialCode = '20'}) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');

  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = defaultDialCode + digits.substring(1);
  }
  return digits;
}

Future<void> openWhatsApp(String phone) async {
  final number = normalizePhone(phone);
  final Uri url = Uri.parse("https://wa.me/$number");

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not open WhatsApp');
  }
}

Future<void> makePhoneCall(String phone) async {
  await FlutterPhoneDirectCaller.callNumber(phone.trim());
}

Future<void> openTruecaller(String phone) async {
  final number = normalizePhone(phone);

  final Uri searchUrl = Uri.parse(
    "https://www.truecaller.com/search/eg/$number",
  );

  await launchUrl(searchUrl, mode: LaunchMode.externalApplication);
}

class CustomerLeadItem extends StatefulWidget {
  final String name;
  final String company;
  final String avatarLetter;
  final Color avatarColor;
  final LeadStatus status;
  final String? phoneNum;
  final String? managerName;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsapp;
  final VoidCallback? onTruecaller;
  final VoidCallback? onMore;
  final VoidCallback? onTap;
  final String? email;
  final String? source;
  final String? nextFollowUp;

  final void Function(CustomerMenuAction action, String? note)? onMenuAction;

  final ValueChanged<CustomerLeadItem>? onEdited;

  final void Function(Map<String, dynamic> activity)? onActivityAdded;

  final void Function(String newManager, String? reason)? onChangeManager;

  final void Function(String client)? onConvertToClient;

  final void Function(
      CustomerLeadItem duplicate,
      Set<MergeField> takeFromDuplicate,
      )?
  onMerge;

  final VoidCallback? onDelete;

  final List<Map<String, dynamic>> products;

  final List<Map<String, String>> records;

  final List<Map<String, dynamic>> activities;

  final UserRole role;
  final String userName;

  const CustomerLeadItem({
    super.key,
    required this.name,
    required this.company,
    required this.avatarLetter,
    this.email,
    this.source,
    this.nextFollowUp,
    this.products = const [],
    this.records = const [],
    this.activities = const [],
    required this.status,
    this.phoneNum,
    this.managerName,
    this.avatarColor = const Color(0xFF3B4CE0),
    this.onCall,
    this.onWhatsapp,
    this.onTruecaller,
    this.onMore,
    this.onTap,
    this.onMenuAction,
    this.onEdited,
    this.onActivityAdded,
    this.onChangeManager,
    this.onConvertToClient,
    this.onMerge,
    this.onDelete,
    this.role = UserRole.manager,
    this.userName = '',
  });

  String get customerKey =>
      phoneNum?.trim().isNotEmpty == true ? phoneNum!.trim() : name;

  @override
  State<CustomerLeadItem> createState() => _CustomerLeadItemState();
}

class _CustomerLeadItemState extends State<CustomerLeadItem> {
  late CustomerLeadItem _current;

  static const String _whatsappIcon = 'assets/images/action_whatsapp.png';
  static const String _callIcon = 'assets/images/action_call.png';
  static const String _truecallerIcon = 'assets/images/action_truecaller.png';

  @override
  void initState() {
    super.initState();
    _current = widget;
  }

  @override
  void didUpdateWidget(covariant CustomerLeadItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget, widget)) {
      _current = widget;
    }
  }

  Future<void> _withPhone(
      BuildContext context,
      Future<void> Function(String) action, {
        VoidCallback? afterAction,
      }) async {
    final phone = _current.phoneNum?.trim() ?? '';

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('لا يوجد رقم هاتف لهذا العميل'))),
      );
      return;
    }

    try {
      await action(phone);
      afterAction?.call();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('تعذر إكمال العملية'))),
        );
      }
    }
  }


  void _addRecord(
      BuildContext context,
      String key,
      CustomerMenuAction action,
      String subtitle,
      ) {
    final now = DateTime.now();

    RecordStore.instance.add(key, {
      'title': context.tr(action.recordTitle),
      'subtitle': subtitle,
      'date': '${now.day}/${now.month}/${now.year}',
      'time': TimeOfDay.fromDateTime(now).format(context),
    });
  }

  void _openDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.customersDetailsScreen,
      arguments: _current,
    );
  }

  Future<void> _onMoreTap(BuildContext buttonContext) async {
    final action = await showCustomerActionsMenu(buttonContext);
    if (action == null || !buttonContext.mounted) return;

    if (action == CustomerMenuAction.view) {
      Navigator.push(
        buttonContext,
        MaterialPageRoute(
          builder: (_) => AddLeadScreen(initialLead: _current, readOnly: true),
        ),
      );
      return;
    }

    if (action == CustomerMenuAction.viewActivity) {
      Navigator.push(
        buttonContext,
        MaterialPageRoute(
          builder:
              (_) => CustomerActivitiesScreen(
            customerName: _current.name,
            customerKey: _current.customerKey,
          ),
        ),
      );
      return;
    }

    if (action == CustomerMenuAction.addActivity) {
      final result = await Navigator.push<Map<String, dynamic>>(
        buttonContext,
        MaterialPageRoute(
          builder:
              (_) => AddActivityScreen(
            role: widget.role,
            userName: widget.userName,
            lockedCustomerName: _current.name,
            lockedCustomerKey: _current.customerKey,
            initialProducts: _current.products,
          ),
        ),
      );

      if (result == null || !mounted) return;

      widget.onActivityAdded?.call(result);
      return;
    }

    if (action == CustomerMenuAction.changeManager) {
      final result = await showChangeManagerDialog(
        buttonContext,
        customerName: _current.name,
        currentManager: _current.managerName,
      );

      if (result == null || !mounted) return;

      _addRecord(
        context,
        _current.customerKey,
        action,
        widget.role == UserRole.manager
            ? context.trArgs(
          'تم تغيير المسؤول إلى {name}',
          {'name': result.newManager},
        )
            : context.trArgs(
          'تم طلب تغيير المسؤول إلى {name} (بانتظار الموافقة)',
          {'name': result.newManager},
        ),
      );

      widget.onChangeManager?.call(result.newManager, result.reason);
      return;
    }

    if (action == CustomerMenuAction.convertToClient) {
      final client = await showConvertToClientDialog(
        buttonContext,
        customerName: _current.name,
      );

      if (client == null || !mounted) return;

      _addRecord(
        context,
        _current.customerKey,
        action,
        client == kConvertToNewClient
            ? context.trArgs(
          'تم تحويل {name} لعميل جديد',
          {'name': _current.name},
        )
            : context.trArgs(
          'تم ربط {name} بالعميل {client}',
          {'name': _current.name, 'client': client},
        ),
      );

      widget.onConvertToClient?.call(client);
      return;
    }

    if (action == CustomerMenuAction.mergeWith) {
      final candidates =
      CustomerLeadStore.customers
          .where((c) => c.customerKey != _current.customerKey)
          .toList();

      if (candidates.isEmpty) {
        ScaffoldMessenger.of(buttonContext).showSnackBar(
          SnackBar(
            content: Text(context.tr('لا توجد عملاء آخرين للدمج معهم')),
          ),
        );
        return;
      }

      final result = await showMergeCustomerDialog(
        buttonContext,
        current: _current,
        candidates: candidates,
      );

      if (result == null || !mounted) return;

      _addRecord(
        context,
        _current.customerKey,
        action,
        context.trArgs(
          'تم دمج {dup} مع {keep}',
          {'dup': result.duplicate.name, 'keep': _current.name},
        ),
      );

      widget.onMerge?.call(result.duplicate, result.takeFromDuplicate);
      return;
    }

    if (action == CustomerMenuAction.edit) {
      final updated = await Navigator.push<CustomerLeadItem>(
        buttonContext,
        MaterialPageRoute(builder: (_) => AddLeadScreen(initialLead: _current)),
      );

      if (updated == null || !mounted) return;

      _addRecord(context, updated.customerKey, action, updated.name);

      setState(() => _current = updated);

      widget.onEdited?.call(updated);
      return;
    }

    if (action == CustomerMenuAction.delete) {
      final confirmed = await askCustomerAction(
        buttonContext,
        action,
        _current.name,
      );

      if (confirmed == null || !mounted) return;

      widget.onDelete?.call();
      return;
    }

    final result = await askCustomerAction(
      buttonContext,
      action,
      _current.name,
    );
    if (result == null || !buttonContext.mounted) return;

    _addRecord(
      buttonContext,
      _current.customerKey,
      action,
      result.note ?? _current.name,
    );

    widget.onMenuAction?.call(action, result.note);
  }

  @override
  Widget build(BuildContext context) {
    final c = _current;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.color;
    final hasCompany = c.company.trim().isNotEmpty;

    return Directionality(
      textDirection: context.dir,
      child: GestureDetector(
        onTap: widget.onTap ?? () => _openDetails(context),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(14.r),
          decoration: AppDecorations.card(context, radius: 20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 46.r,
                    height: 46.r,
                    decoration: BoxDecoration(
                      color: c.avatarColor,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c.avatarLetter,
                      style: TextStyle(
                        fontFamily: FontConstants.fontFamily,
                        color: Colors.white,
                        fontWeight: FontWeightManager.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeightManager.bold,
                          ),
                        ),
                        if (hasCompany) ...[
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.business_rounded,
                                size: 14.sp,
                                color: muted,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  c.company,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: c.status.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            color: c.status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          context.tr(c.status.label),
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            fontSize: 12.sp,
                            fontWeight: FontWeightManager.bold,
                            color: c.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),
              Divider(height: 1, color: theme.dividerColor),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.phone_rounded,
                      text: c.phoneNum?.trim().isNotEmpty == true
                          ? c.phoneNum!
                          : '-',
                      ltr: true,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.perm_identity,
                      text: c.managerName?.trim().isNotEmpty == true
                          ? c.managerName!
                          : '-',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      tint: ColorManager.primaryColor,
                      child: _imageGlyph(_whatsappIcon),
                      onTap: () => _withPhone(
                        context,
                        openWhatsApp,
                        afterAction: widget.onWhatsapp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _ActionButton(
                      tint: ColorManager.primaryColor,
                      child: _imageGlyph(_callIcon),
                      onTap: () => _withPhone(
                        context,
                        makePhoneCall,
                        afterAction: widget.onCall,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _ActionButton(
                      tint: ColorManager.primaryColor,
                      child: _imageGlyph(_truecallerIcon),
                      onTap: () => _withPhone(
                        context,
                        openTruecaller,
                        afterAction: widget.onTruecaller,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Builder(
                      builder: (buttonContext) {
                        return _ActionButton(
                          tint: muted ?? ColorManager.primaryColor,
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 24.sp,
                            color: muted,
                          ),
                          onTap: () => _onMoreTap(buttonContext),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageGlyph(String asset) {
    return Image.asset(
      asset,
      width: 28.w,
      height: 28.w,
      fit: BoxFit.contain,
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool ltr;

  const _InfoItem({required this.icon, required this.text, this.ltr = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17.sp, color: ColorManager.primaryColor),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: ltr ? TextDirection.ltr : null,
              textAlign: TextAlign.start,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeightManager.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget child;
  final Color tint;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.child,
    required this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint.withOpacity(0.10),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: tint.withOpacity(0.20)),
          ),
          child: child,
        ),
      ),
    );
  }
}