import 'package:erp_system/core/routes_manager/routes.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:erp_system/feature/customers_details/presentation/screens/customers_details_screen.dart';
import 'package:erp_system/feature/forget_password/presentation/screens/forget_password_screen.dart';
import 'package:erp_system/feature/login/presentation/screens/login_screen.dart';
import 'package:erp_system/feature/notification/presentation/screens/notification_screen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case Routes.forgetPasswordScreen:
        return MaterialPageRoute(
          builder: (_) => const ForgetPasswordScreen(),
        );
      case Routes.notificationsScreen:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      case Routes.customersDetailsScreen:
        final customer = settings.arguments as CustomerLeadItem;

        return MaterialPageRoute(
          builder: (_) => CustomersDetailsScreen(
            customer: customer,
          ),
        );

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('No Route Found'),
        ),
        body: const Center(
          child: Text('No Route Found'),
        ),
      ),
    );
  }
}