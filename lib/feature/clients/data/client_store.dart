import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_manager_service.dart';
import 'package:flutter/foundation.dart';

const String kConvertToNewClient = '__new_client__';

enum ClientOrigin { newClient, existingClient, acceptedQuote }

extension ClientOriginX on ClientOrigin {
  String get label {
    switch (this) {
      case ClientOrigin.newClient:
        return 'عميل جديد';
      case ClientOrigin.existingClient:
        return 'عميل سابق';
      case ClientOrigin.acceptedQuote:
        return 'عرض سعر مقبول';
    }
  }
}

class ClientItem {
  ClientItem({
    required this.id,
    required this.name,
    required this.origin,
    required this.createdAt,
    this.company = '',
    this.phone = '',
    this.email = '',
    this.source = '',
    this.managerName = '',
    this.quoteCode,
    this.lastConvertedAt,
    List<String>? convertedLeads,
    List<Map<String, dynamic>>? interests,
  })  : convertedLeads = convertedLeads ?? <String>[],
        interests = interests ?? <Map<String, dynamic>>[];

  final String id;
  final String name;
  final ClientOrigin origin;
  final DateTime createdAt;

  String company;
  String phone;
  String email;
  String source;

  String managerName;

  final String? quoteCode;

  DateTime? lastConvertedAt;

  final List<String> convertedLeads;

  final List<Map<String, dynamic>> interests;
}

class ClientStore {
  ClientStore._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static int _seq = 0;

  static final List<ClientItem> _clients = [];

  static List<ClientItem> get all => List.unmodifiable(_clients);

  static List<String> get names => [for (final c in _clients) c.name];

  static ClientItem? byName(String name) {
    for (final c in _clients) {
      if (c.name == name) return c;
    }
    return null;
  }


  static String _s(Object? v) => v?.toString().trim() ?? '';

  static List<Map<String, dynamic>> _interestsOf(CustomerLeadItem lead) {
    final Object? raw = lead.products;
    if (raw is! List) return <Map<String, dynamic>>[];

    return [
      for (final p in raw)
        if (p is Map) Map<String, dynamic>.from(p),
    ];
  }

  static ClientItem convertLead(
      CustomerLeadItem lead, {
        String? existingClientName,
        ClientOrigin origin = ClientOrigin.newClient,
        String? quoteCode,
      }) {
    final now = DateTime.now();
    final leadName = _s(lead.name);
    final interests = _interestsOf(lead);

    ClientItem? target =
    existingClientName == null ? null : byName(existingClientName);

    if (target == null) {
      target = ClientItem(
        id: 'c-new-${_seq++}',
        name: leadName,
        company: _s(lead.company),
        phone: _s(lead.phoneNum),
        email: _s(lead.email),
        source: _s(lead.source),
        managerName: _s(lead.managerName),
        origin: origin,
        createdAt: now,
        lastConvertedAt: now,
        quoteCode: quoteCode,
        convertedLeads: [leadName],
        interests: interests,
      );
      _clients.insert(0, target);
    } else {
      target.convertedLeads.add(leadName);
      target.interests.addAll(interests);
      target.lastConvertedAt = now;
      if (target.phone.isEmpty) target.phone = _s(lead.phoneNum);
      if (target.email.isEmpty) target.email = _s(lead.email);
    }

    CustomerManagerService.delete(lead.customerKey);

    changes.value++;
    return target;
  }

  static bool convertLeadByName(String leadName, {String? quoteCode}) {
    CustomerLeadItem? found;

    for (final l in CustomerLeadStore.customers) {
      if (_s(l.name) == leadName.trim()) {
        found = l;
        break;
      }
    }

    if (found == null) return false;

    convertLead(
      found,
      origin: ClientOrigin.acceptedQuote,
      quoteCode: quoteCode,
    );
    return true;
  }
}