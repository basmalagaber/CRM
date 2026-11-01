import 'package:erp_system/feature/clients/data/client_store.dart';
import 'package:flutter/foundation.dart';

class PriceStore {
  PriceStore._();

  static const String draft = 'مسودة';
  static const String sent = 'مرسل';
  static const String accepted = 'مقبول';
  static const String rejected = 'مرفوض';

  static final List<Map<String, dynamic>> quotes = [];

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void _notify() => changes.value++;

  static Map<String, dynamic> add(
      Map<String, dynamic> offer, {
        String owner = '',
      }) {
    final now = DateTime.now();

    final item = <String, dynamic>{
      'code': _generateCode(now),
      'quoteNumber': _generateQuoteNumber(now),
      'owner': owner,
      'quoteDate': _formatDate(offer['offerDate']),
      'expiryDate': _formatDate(offer['expiryDate']),
      'total': '0',
      'status': draft,
      'approvalStatus': '',
      'approvalDate': '',
      'customer': offer['goal'] ?? offer['name'] ?? '',
      'phone': offer['phone'] ?? '',
      'customerType': offer['customerType'],
      'goal': offer['goal'],
      'source': offer['source'],
      'activity': offer['activity'],
      'paymentMethod': offer['paymentMethod'],
      'discount': offer['discount'],
      'notes': offer['notes'],
    };

    quotes.insert(0, item);
    _notify();
    return item;
  }

  static void remove(Map<String, dynamic> item) {
    quotes.remove(item);
    _notify();
  }

  static void update(Map<String, dynamic> item, Map<String, dynamic> values) {
    item.addAll(values);
    _notify();
  }

  static bool setStatus(Map<String, dynamic> item, String status) {
    item['status'] = status;

    var converted = false;

    if (status == accepted) {
      final now = DateTime.now();
      item['acceptedAt'] = _formatDate(now.toIso8601String());

      final isLead = item['customerType'] == 'عميل محتمل';
      final leadName = (item['goal'] ?? '').toString().trim();

      if (isLead && leadName.isNotEmpty) {
        converted = ClientStore.convertLeadByName(
          leadName,
          quoteCode: (item['quoteNumber'] ?? '').toString(),
        );
      }
    }

    if (converted) item['convertedToClient'] = true;

    _notify();
    return converted;
  }

  static String _generateCode(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return 'CQX-$yy$mm$dd${quotes.length + 1}';
  }

  static String _generateQuoteNumber(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final n = (quotes.length + 1).toString().padLeft(4, '0');
    return 'QT-$yy$mm-$n';
  }

  static String _formatDate(dynamic iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso.toString());
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${d.year}/$mm/$dd';
  }
}