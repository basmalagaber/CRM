class EmployeeStats {
  const EmployeeStats({
    required this.id,
    required this.name,
    required this.leads,
    required this.converted,
    this.opportunities = 0,
    this.won = 0,
    this.invoices = 0,
    this.salesOrders = 0,
    this.calls = 0,
    this.visits = 0,
    this.followDone = 0,
    this.followPending = 0,
    this.overdueOpen = 0,
    this.compliance = 100,
    this.avgDelayMinutes = 0,
  });

  final String id;
  final String name;

  final int leads;

  final int converted;

  final int opportunities;

  final int won;

  final int invoices;
  final int salesOrders;
  final int calls;
  final int visits;
  final int followDone;
  final int followPending;
  final int overdueOpen;

  final double compliance;

  final int avgDelayMinutes;
}

class DelayRecord {
  const DelayRecord({
    required this.leadName,
    required this.responsible,
    required this.followUpAt,
    required this.discoveredAt,
    required this.delayMinutes,
    required this.resolved,
    this.resolvedAt,
    this.resolvedBy,
  });

  final String leadName;
  final String responsible;
  final DateTime followUpAt;
  final DateTime discoveredAt;
  final int delayMinutes;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;
}

class ReportsRepository {
  ReportsRepository._();

  static const List<EmployeeStats> employees = [
    EmployeeStats(id: 'e1', name: 'Ahmed Hatem', leads: 6, converted: 1),
    EmployeeStats(
      id: 'e2',
      name: 'mariam',
      leads: 6,
      converted: 2,
      opportunities: 3,
      won: 1,
      invoices: 1,
      salesOrders: 1,
      calls: 14,
      visits: 3,
      followDone: 9,
      followPending: 2,
      overdueOpen: 1,
      compliance: 82,
      avgDelayMinutes: 95,
    ),
    EmployeeStats(
      id: 'e3',
      name: 'Rola Mahmoud',
      leads: 6,
      converted: 1,
      opportunities: 2,
      won: 1,
      invoices: 1,
      calls: 9,
      visits: 2,
      followDone: 6,
      followPending: 1,
    ),
    EmployeeStats(
      id: 'e4',
      name: 'mo ragab',
      leads: 5,
      converted: 1,
      opportunities: 2,
      calls: 11,
      visits: 1,
      followDone: 7,
      followPending: 3,
      compliance: 88,
      avgDelayMinutes: 242,
    ),
    EmployeeStats(id: 'e5', name: 'سارة علي', leads: 2, converted: 0, calls: 4),
    EmployeeStats(id: 'e6', name: 'كريم عادل', leads: 1, converted: 0),
    EmployeeStats(id: 'e7', name: 'منى حسن', leads: 1, converted: 0),
    EmployeeStats(id: 'e8', name: 'يوسف سامي', leads: 1, converted: 0),
    EmployeeStats(id: 'e9', name: 'هبة خالد', leads: 1, converted: 0),
    EmployeeStats(id: 'e10', name: 'عمر فاروق', leads: 1, converted: 0),
  ];

  static final List<DelayRecord> delays = [
    DelayRecord(
      leadName: 'عبدالله مؤمن',
      responsible: 'mo ragab',
      followUpAt: DateTime(2026, 10, 12, 20, 25),
      discoveredAt: DateTime(2026, 10, 13, 0, 27),
      delayMinutes: 242,
      resolved: true,
      resolvedAt: DateTime(2026, 10, 13, 0, 27),
      resolvedBy: '1123',
    ),
    DelayRecord(
      leadName: 'شركة النور للتجارة',
      responsible: 'mariam',
      followUpAt: DateTime(2026, 10, 14, 10, 0),
      discoveredAt: DateTime(2026, 10, 14, 11, 35),
      delayMinutes: 95,
      resolved: false,
    ),
    DelayRecord(
      leadName: 'محمد السيد',
      responsible: 'Ahmed Hatem',
      followUpAt: DateTime(2026, 10, 15, 14, 30),
      discoveredAt: DateTime(2026, 10, 15, 15, 5),
      delayMinutes: 35,
      resolved: true,
      resolvedAt: DateTime(2026, 10, 15, 15, 20),
      resolvedBy: 'mariam',
    ),
    DelayRecord(
      leadName: 'مصنع الأمل',
      responsible: 'سارة علي',
      followUpAt: DateTime(2026, 10, 16, 9, 15),
      discoveredAt: DateTime(2026, 10, 16, 13, 45),
      delayMinutes: 270,
      resolved: false,
    ),
  ];
}

String _two(int n) => n.toString().padLeft(2, '0');

String fmtDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

String fmtDateTime(DateTime d) {
  final isAm = d.hour < 12;
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${d.year}/${d.month}/${d.day} - $hour12:${_two(d.minute)} ${isAm ? 'ص' : 'م'}';
}

String fmtPercent(double v) {
  if (v == v.roundToDouble()) return '${v.toInt()}%';
  return '${v.toStringAsFixed(1)}%';
}
