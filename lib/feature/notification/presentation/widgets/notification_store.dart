import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:flutter/foundation.dart';
import 'app_session.dart';

enum AppNotificationType {
  newLead,
  approvalRequest,
  general,
}

enum NotificationItemKind {
  customer('عميل'),
  activity('نشاط'),
  quote('عرض سعر');

  final String label;
  const NotificationItemKind(this.label);
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final AppNotificationType type;
  final String? toUser;
  final bool toManagers;
  final int? targetTab;
  final Map<String, dynamic> data;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    this.toUser,
    this.toManagers = false,
    this.targetTab,
    this.data = const {},
    this.isRead = false,
  });
}

class NotificationStore {
  NotificationStore._();

  static final List<AppNotification> _items = [];
  static int _seq = 0;

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static bool _isForCurrentUser(AppNotification n) {
    final name = AppSession.userName;
    final role = AppSession.role;
    if (name == null || role == null) return false;

    if (n.toUser != null && n.toUser == name) return true;
    return n.toManagers && role == UserRole.manager;
  }

  static List<AppNotification> forCurrentUser() =>
      _items.where(_isForCurrentUser).toList();

  static int unreadCountForCurrentUser() =>
      _items.where((n) => _isForCurrentUser(n) && !n.isRead).length;

  static void _add(AppNotification n) {
    _items.insert(0, n);
    changes.value++;
  }

  static String _nextId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  static void notifyUser({
    required String userName,
    required String title,
    required String body,
    AppNotificationType type = AppNotificationType.general,
    int? targetTab,
    Map<String, dynamic> data = const {},
  }) {
    _add(
      AppNotification(
        id: _nextId(),
        title: title,
        body: body,
        createdAt: DateTime.now(),
        type: type,
        toUser: userName,
        targetTab: targetTab,
        data: data,
      ),
    );
  }

  static void notifyManagers({
    required String title,
    required String body,
    AppNotificationType type = AppNotificationType.approvalRequest,
    int? targetTab,
    Map<String, dynamic> data = const {},
  }) {
    _add(
      AppNotification(
        id: _nextId(),
        title: title,
        body: body,
        createdAt: DateTime.now(),
        type: type,
        toManagers: true,
        targetTab: targetTab ?? AppNavigation.approvalsTab,
        data: data,
      ),
    );
  }

  static void notifyManagersNewItem({
    required String actorName,
    required UserRole actorRole,
    required NotificationItemKind kind,
    String? itemName,
    Map<String, dynamic> data = const {},
  }) {
    if (actorRole == UserRole.manager) return;

    final who = '${AppSession.roleLabel(actorRole)} $actorName';
    final item = (itemName == null || itemName.trim().isEmpty)
        ? kind.label
        : '${kind.label} ($itemName)';

    notifyManagers(
      title: 'طلب اعتماد جديد',
      body: 'قام $who بإضافة $item',
      targetTab: AppNavigation.approvalsTab,
      data: data,
    );
  }

  static void notifyUserManagerAdded({
    required String toUser,
    required String managerName,
    required NotificationItemKind kind,
    String? itemName,
    Map<String, dynamic> data = const {},
  }) {
    final item = (itemName == null || itemName.trim().isEmpty)
        ? kind.label
        : '${kind.label} ($itemName)';

    notifyUser(
      userName: toUser,
      title: 'تمت إضافة ${kind.label} من الإدارة',
      body: 'قام المدير $managerName بإضافة $item',
      type: AppNotificationType.general,
      targetTab: AppNavigation.approvalsTab,
      data: data,
    );
  }

  static void markRead(String id) {
    for (final n in _items) {
      if (n.id == id && !n.isRead) {
        n.isRead = true;
        changes.value++;
        return;
      }
    }
  }

  static void markAllReadForCurrentUser() {
    var changed = false;
    for (final n in _items) {
      if (_isForCurrentUser(n) && !n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) changes.value++;
  }
}