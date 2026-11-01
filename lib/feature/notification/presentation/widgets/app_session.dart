import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:flutter/foundation.dart';

class AppSession {
  AppSession._();

  static String? userName;
  static UserRole? role;
  static void clear() {
    userName = null;
    role = null;
  }
  static void start({required String userName, required UserRole role}) {
    AppSession.userName = userName;
    AppSession.role = role;
  }

  static bool get isManager => role == UserRole.manager;

  static String roleLabel(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return 'المدير';
      case UserRole.leader:
        return 'الليدر';
      case UserRole.employee:
        return 'الموظف';
    }
  }
}

class AppNavigation {
  AppNavigation._();

  static const int approvalsTab = 0;
  static const int activitiesTab = 1;
  static const int salesTab = 2;
  static const int customersTab = 3;
  static const int homeTab = 4;

  static final ValueNotifier<int?> requestedTab = ValueNotifier<int?>(null);
}