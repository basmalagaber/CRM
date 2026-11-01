import 'package:flutter/foundation.dart';

class ApprovalStore {
  ApprovalStore._();

  static const String pending = 'في الانتظار';
  static const String approved = 'معتمد';
  static const String rejected = 'مرفوض';

  static final List<Map<String, dynamic>> approvals = [];

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void _notify() => changes.value++;

  static Map<String, dynamic> add({
    required String title,
    required String requester,
    String newOwner = '',
    String customer = '',
    Map<String, dynamic>? source,
    Map<String, dynamic>? details,
    bool autoApproved = false,
  }) {
    final now = DateTime.now();
    final status = autoApproved ? approved : pending;
    final dateText = _formatDateTime(now);

    final item = <String, dynamic>{
      'code': _generateCode(now),
      'title': title,
      'requester': requester,
      'newOwner': newOwner,
      'customer': customer,
      'date': dateText,
      'source': source,
      'messages': <Map<String, dynamic>>[],
      ...?details,
      'approvalStatus': status,
      if (autoApproved) 'approvalDate': dateText,
    };

    if (source != null) {
      source['approvalStatus'] = status;
      if (autoApproved) source['approvalDate'] = dateText;
    }

    approvals.insert(0, item);
    _notify();
    return item;
  }

  static void setStatus(Map<String, dynamic> item, String status) {
    item['approvalStatus'] = status;

    final source = item['source'];
    if (source is Map<String, dynamic>) {
      source['approvalStatus'] = status;
    }

    _notify();
  }

  static String _generateCode(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final prefix = 'CAR-$yy$mm$dd';

    final todayCount = approvals
        .where((a) => (a['code'] ?? '').toString().startsWith(prefix))
        .length;

    return '$prefix${todayCount + 1}';
  }

  static String _formatDateTime(DateTime d) {
    final isAm = d.hour < 12;
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.year}/${d.month}/${d.day} في $hour12:$minute ${isAm ? 'ص' : 'م'}';
  }
}