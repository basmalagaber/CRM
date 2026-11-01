import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:flutter/foundation.dart';

enum CalendarEventType { meeting, travel, task, call, other }

enum CalendarEventStatus { upcoming, ongoing, finished, cancelled }

enum CalendarLogOp { add, update, delete }

extension CalendarEventTypeX on CalendarEventType {
  String get label {
    switch (this) {
      case CalendarEventType.meeting:
        return 'اجتماع';
      case CalendarEventType.travel:
        return 'سفر';
      case CalendarEventType.task:
        return 'مهمة';
      case CalendarEventType.call:
        return 'مكالمة';
      case CalendarEventType.other:
        return 'أخرى';
    }
  }
}

extension CalendarEventStatusX on CalendarEventStatus {
  String get label {
    switch (this) {
      case CalendarEventStatus.upcoming:
        return 'قادم';
      case CalendarEventStatus.ongoing:
        return 'قيد التنفيذ';
      case CalendarEventStatus.finished:
        return 'مكتمل';
      case CalendarEventStatus.cancelled:
        return 'ملغي';
    }
  }
}

extension CalendarLogOpX on CalendarLogOp {
  String get label {
    switch (this) {
      case CalendarLogOp.add:
        return 'إضافة';
      case CalendarLogOp.update:
        return 'تحديث';
      case CalendarLogOp.delete:
        return 'حذف';
    }
  }
}

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.start,
    required this.end,
    this.description = '',
    this.reminderEnabled = true,
    this.reminderMinutes = 15,
    this.summary = '',
    this.summaryAt,
  });

  final String id;
  final String title;
  final String description;
  final CalendarEventType type;
  final DateTime start;
  final DateTime end;
  final bool reminderEnabled;
  final int reminderMinutes;
  final String summary;
  final DateTime? summaryAt;

  CalendarEvent withSummary(String text, DateTime at) => CalendarEvent(
    id: id,
    title: title,
    type: type,
    start: start,
    end: end,
    description: description,
    reminderEnabled: reminderEnabled,
    reminderMinutes: reminderMinutes,
    summary: text,
    summaryAt: at,
  );

  CalendarEventStatus statusAt(DateTime now) {
    if (now.isBefore(start)) return CalendarEventStatus.upcoming;
    if (now.isAfter(end)) return CalendarEventStatus.finished;
    return CalendarEventStatus.ongoing;
  }

  CalendarEventStatus get status => statusAt(DateTime.now());

  bool isOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  String get displayTitle => title.trim().isEmpty ? 'حدث بدون عنوان' : title;
}

class CalendarLogEntry {
  const CalendarLogEntry({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.op,
    required this.description,
    required this.user,
    required this.at,
  });

  final String id;
  final String eventId;
  final String eventTitle;
  final CalendarLogOp op;
  final String description;
  final String user;
  final DateTime at;
}

class CalendarStore {
  CalendarStore._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static final List<CalendarEvent> _events = [
    CalendarEvent(
      id: 'CEX-2610191',
      title: 'بني سويف',
      type: CalendarEventType.task,
      start: DateTime(2026, 10, 19, 11, 7),
      end: DateTime(2026, 10, 19, 12, 57),
    ),
    CalendarEvent(
      id: 'CEX-2610121',
      title: 'اجتماع متابعة',
      type: CalendarEventType.meeting,
      start: DateTime(2026, 10, 13, 1, 14),
      end: DateTime(2026, 10, 13, 2, 10),
    ),
  ];

  static final List<CalendarLogEntry> _logs = [];
  static int _logSeq = 0;

  static List<CalendarEvent> get events => List.unmodifiable(_events);

  static List<CalendarLogEntry> logsFor(String eventId) =>
      _logs.where((l) => l.eventId == eventId).toList().reversed.toList();

  static bool hasEventOn(DateTime day) => _events.any((e) => e.isOn(day));

  static String nextId(DateTime date) {
    final prefix =
        'CEX-${calTwo(date.year % 100)}${calTwo(date.month)}${calTwo(date.day)}';
    var n = 1;
    while (_events.any((e) => e.id == '$prefix$n')) {
      n++;
    }
    return '$prefix$n';
  }

  static void _log(CalendarEvent e, CalendarLogOp op, String description) {
    final now = DateTime.now();
    _logSeq++;
    _logs.add(
      CalendarLogEntry(
        id: 'LOG-${calTwo(now.year % 100)}${calTwo(now.month)}${calTwo(now.day)}$_logSeq',
        eventId: e.id,
        eventTitle: e.displayTitle,
        op: op,
        description: description,
        user: AppSession.userName ?? '—',
        at: now,
      ),
    );
  }

  static void add(CalendarEvent e) {
    _events.add(e);
    _log(e, CalendarLogOp.add, 'تمت إضافة الحدث "${e.displayTitle}"');
    changes.value++;
  }

  static void update(CalendarEvent e) {
    final i = _events.indexWhere((x) => x.id == e.id);
    if (i == -1) return;
    _events[i] = e;
    _log(e, CalendarLogOp.update, 'تم تعديل الحدث "${e.displayTitle}"');
    changes.value++;
  }

  static void setSummary(String id, String text) {
    final i = _events.indexWhere((x) => x.id == id);
    if (i == -1) return;
    final e = _events[i].withSummary(text.trim(), DateTime.now());
    _events[i] = e;
    _log(e, CalendarLogOp.update, 'تم تحديث ملخص الحدث "${e.displayTitle}"');
    changes.value++;
  }

  static void remove(String id) {
    final i = _events.indexWhere((x) => x.id == id);
    if (i == -1) return;
    final e = _events.removeAt(i);
    _log(e, CalendarLogOp.delete, 'تم حذف الحدث "${e.displayTitle}"');
    changes.value++;
  }
}

const List<String> calMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

String calTwo(int n) => n.toString().padLeft(2, '0');

String calFmtDate(DateTime d) =>
    '${d.year}/${calTwo(d.month)}/${calTwo(d.day)}';

String calFmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${calTwo(h)}:${calTwo(d.minute)} ${d.hour < 12 ? 'ص' : 'م'}';
}

String calFmtDateTime(DateTime d) => '${calFmtDate(d)}  ${calFmtTime(d)}';

String calMinutesLabel(int m) {
  if (m == 60) return 'ساعة';
  if (m == 120) return 'ساعتان';
  if (m == 1440) return 'يوم';
  return '$m دقيقة';
}

bool calSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;