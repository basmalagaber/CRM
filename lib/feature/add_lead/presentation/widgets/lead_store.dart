
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';

class LeadStore {
  static final List<CustomerLeadItem> leads = [];

  static void addLead(CustomerLeadItem lead) {
    leads.add(lead);
  }

  static void updateLead(CustomerLeadItem lead) {
    final index = leads.indexWhere(
          (item) => item.phoneNum == lead.phoneNum,
    );

    if (index != -1) {
      leads[index] = lead;
    }
  }
}