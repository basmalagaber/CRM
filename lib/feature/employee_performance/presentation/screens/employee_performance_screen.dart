import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/resources/colors_manager.dart';
import '../../../../core/resources/fonts_manager.dart';
import '../widgets/activities_card.dart';
import '../widgets/adherence_card.dart';
import '../widgets/customer_stats_card.dart';
import '../widgets/delays_card.dart';
import '../widgets/employee_evaluation_tab.dart';
import '../widgets/follow_up_delays_tab.dart';
import '../widgets/offers_invoices_card.dart';
import '../widgets/performance_filter_card.dart';
import '../widgets/performance_header.dart';
import '../widgets/performance_tabs.dart';

class EmployeePerformanceScreen extends StatefulWidget {
  const EmployeePerformanceScreen({super.key});

  @override
  State<EmployeePerformanceScreen> createState() =>
      _EmployeePerformanceScreenState();
}

class _EmployeePerformanceScreenState extends State<EmployeePerformanceScreen> {
  int _selectedTab = 0;

  String? _selectedEmployee;

  final GlobalKey<EmployeeEvaluationTabState> _evaluationKey =
  GlobalKey<EmployeeEvaluationTabState>();

  bool get _hasEmployee => _selectedEmployee != null;
  bool get _isEvaluationTab => _selectedTab == 1;

  void _onEmployeeChanged(String? value) =>
      setState(() => _selectedEmployee = value);

  List<Widget> _tabContent() {
    switch (_selectedTab) {
      case 1:
        return [
          EmployeeEvaluationTab(
            key: _evaluationKey,
            showAddButton: false,
            selectedEmployee: _selectedEmployee,
            onEmployeeChanged: _onEmployeeChanged,
          ),
        ];
      case 2:
        return [
          FollowUpDelaysTab(
            selectedEmployee: _selectedEmployee,
            onEmployeeChanged: _onEmployeeChanged,
          ),
        ];
      case 0:
      default:
        return [
          PerformanceFilterCard(
            selectedEmployee: _selectedEmployee,
            onEmployeeChanged: _onEmployeeChanged,
          ),
          if (_hasEmployee) ...const [
            AdherenceCard(),
            CustomerStatsCard(),
            OffersInvoicesCard(),
            ActivitiesCard(),
            DelaysCard(),
          ],
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: _isEvaluationTab
            ? FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => _evaluationKey.currentState?.openEditor(),
          backgroundColor: ColorManager.primaryColor,
          foregroundColor: ColorManager.iconColor,
          elevation: 4,
          shape: const StadiumBorder(),
          icon: Icon(Icons.add_rounded, size: 22.sp),
          label: Text(
            'إضافة تقييم',
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeightManager.bold,
              color: ColorManager.iconColor,
            ),
          ),
        )
            : null,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const PerformanceHeader(),
              PerformanceTabs(
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
              SizedBox(height: 9.h),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: _isEvaluationTab ? 96.h : 16.h),
                  children: _tabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}