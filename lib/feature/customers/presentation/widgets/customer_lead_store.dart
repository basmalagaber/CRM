import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';

class CustomerLeadStore {
  static final List<CustomerLeadItem> customers = [];

  static void add(CustomerLeadItem customer) {
    customers.add(customer);
  }

  static void update(CustomerLeadItem customer) {
    final index = customers.indexWhere(
          (item) => item.phoneNum == customer.phoneNum,
    );

    if (index != -1) {
      customers[index] = customer;
    }
  }

  static List<CustomerLeadItem> visibleCustomers({
    required UserRole role,
    required String userName,
  }) {
    if (role == UserRole.manager) {
      return customers;
    }

    return customers
        .where(
          (customer) => customer.managerName == userName,
    )
        .toList();
  }
}