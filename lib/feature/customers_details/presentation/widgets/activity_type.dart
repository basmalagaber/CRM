import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';

enum ActivityType { visit, email, sms, call, whatsapp }

extension ActivityTypeData on ActivityType {
  String label(BuildContext context) {
    switch (this) {
      case ActivityType.visit:
        return context.tr('زيارة');
      case ActivityType.email:
        return context.tr('بريد إلكتروني');
      case ActivityType.sms:
        return context.tr('رسالة نصية');
      case ActivityType.call:
        return context.tr('مكالمة');
      case ActivityType.whatsapp:
        return context.tr('واتساب');
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.visit:
        return Icons.location_on_outlined;
      case ActivityType.email:
        return Icons.email_outlined;
      case ActivityType.sms:
        return Icons.sms_outlined;
      case ActivityType.call:
        return Icons.call_rounded;
      case ActivityType.whatsapp:
        return Icons.chat_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ActivityType.visit:
        return const Color(0xFF9C6BFF);
      case ActivityType.email:
        return const Color(0xFF29C7E0);
      case ActivityType.sms:
        return const Color(0xFFFFA726);
      case ActivityType.call:
        return const Color(0xFF2F6BFF);
      case ActivityType.whatsapp:
        return const Color(0xFF00C853);
    }
  }
}