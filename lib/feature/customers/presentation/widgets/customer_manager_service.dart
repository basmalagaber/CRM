import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_store.dart';

import 'merge_customer.dart';

class CustomerManagerService {
  CustomerManagerService._();

  static bool apply(String customerKey, String newManager) {
    if (customerKey.isEmpty || newManager.isEmpty) return false;

    return _replace(
      customerKey,
          (old) => _copy(old, managerName: newManager),
    );
  }

  static bool setStatus(String customerKey, LeadStatus status) {
    if (customerKey.isEmpty) return false;

    return _replace(
      customerKey,
          (old) => _copy(old, status: status),
    );
  }

  static bool delete(String customerKey) {
    if (customerKey.isEmpty) return false;

    final list = CustomerLeadStore.customers;
    final before = list.length;

    list.removeWhere((c) => c.customerKey == customerKey);

    return list.length < before;
  }

  static bool merge(
      String keepKey,
      String duplicateKey, {
        Set<MergeField> takeFromDuplicate = const {},
      }) {
    if (keepKey.isEmpty || duplicateKey.isEmpty || keepKey == duplicateKey) {
      return false;
    }

    final list = CustomerLeadStore.customers;
    final ki = list.indexWhere((c) => c.customerKey == keepKey);
    final di = list.indexWhere((c) => c.customerKey == duplicateKey);
    if (ki == -1 || di == -1) return false;

    final keep = list[ki];
    final dup = list[di];

    String pick(MergeField field) {
      final a = field.valueOf(keep);
      final b = field.valueOf(dup);

      if (a.trim().isEmpty) return b;
      return takeFromDuplicate.contains(field) ? b : a;
    }

    String? orNull(String value) => value.trim().isEmpty ? null : value;

    List<T> union<T>(List<T> a, List<T> b) {
      final seen = <String>{};
      return [...a, ...b].where((e) => seen.add(e.toString())).toList();
    }

    final name = pick(MergeField.name);
    final nameFromDuplicate = name != keep.name;

    list[ki] = CustomerLeadItem(
      name: name,
      company: pick(MergeField.company),
      avatarLetter:
      nameFromDuplicate ? dup.avatarLetter : keep.avatarLetter,
      avatarColor: nameFromDuplicate ? dup.avatarColor : keep.avatarColor,
      status: LeadStatus.merged,
      phoneNum: orNull(pick(MergeField.phone)),
      managerName: orNull(pick(MergeField.manager)),
      email: orNull(pick(MergeField.email)),
      source: orNull(pick(MergeField.source)),
      nextFollowUp: orNull(pick(MergeField.nextFollowUp)),
      products: union(keep.products, dup.products),
      records: union(keep.records, dup.records),
      activities: union(keep.activities, dup.activities),
      onCall: keep.onCall,
      onWhatsapp: keep.onWhatsapp,
      onTruecaller: keep.onTruecaller,
      onMore: keep.onMore,
      onTap: keep.onTap,
      onMenuAction: keep.onMenuAction,
      onEdited: keep.onEdited,
      onActivityAdded: keep.onActivityAdded,
      onChangeManager: keep.onChangeManager,
      onConvertToClient: keep.onConvertToClient,
      onMerge: keep.onMerge,
      onDelete: keep.onDelete,
      role: keep.role,
      userName: keep.userName,
    );

    list.removeWhere((c) => identical(c, dup));
    return true;
  }

  static bool _replace(
      String customerKey,
      CustomerLeadItem Function(CustomerLeadItem old) build,
      ) {
    final list = CustomerLeadStore.customers;
    final i = list.indexWhere((c) => c.customerKey == customerKey);
    if (i == -1) return false;

    list[i] = build(list[i]);
    return true;
  }

  static CustomerLeadItem _copy(
      CustomerLeadItem old, {
        String? managerName,
        LeadStatus? status,
      }) {
    return CustomerLeadItem(
      name: old.name,
      company: old.company,
      avatarLetter: old.avatarLetter,
      avatarColor: old.avatarColor,
      status: status ?? old.status,
      phoneNum: old.phoneNum,
      managerName: managerName ?? old.managerName,
      email: old.email,
      source: old.source,
      nextFollowUp: old.nextFollowUp,
      products: old.products,
      records: old.records,
      activities: old.activities,
      onCall: old.onCall,
      onWhatsapp: old.onWhatsapp,
      onTruecaller: old.onTruecaller,
      onMore: old.onMore,
      onTap: old.onTap,
      onMenuAction: old.onMenuAction,
      onEdited: old.onEdited,
      onActivityAdded: old.onActivityAdded,
      onChangeManager: old.onChangeManager,
      onConvertToClient: old.onConvertToClient,
      onMerge: old.onMerge,
      onDelete: old.onDelete,
      role: old.role,
      userName: old.userName,
    );
  }
}