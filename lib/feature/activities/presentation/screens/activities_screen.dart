import 'dart:ui' as ui;
import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/activities/presentation/widgets/activities_filter_section.dart';
import 'package:erp_system/feature/activities/presentation/widgets/activity_card.dart';
import 'package:erp_system/feature/add_activity/presentation/screens/add_activity_screen.dart';
import 'package:erp_system/feature/add_lead/presentation/widgets/lead_store.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_lead_item.dart';
import 'package:erp_system/feature/home/presentation/widgets/app_bar_screen.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:erp_system/feature/notification/presentation/widgets/notification_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivitiesListStore {
  ActivitiesListStore._();

  static const String pendingStatus = 'في الانتظار';

  static final List<Map<String, dynamic>> activities = [];

  static String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  static String _formatDateTime(DateTime d) {
    final isAm = d.hour < 12;
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    return '${_formatDate(d)} في $hour12:$minute ${isAm ? 'ص' : 'م'}';
  }

  static String generateCode(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final prefix = 'CAX-$yy$mm$dd';

    final todayCount = activities
        .where((a) => (a['code'] ?? '').toString().startsWith(prefix))
        .length;

    return '$prefix${todayCount + 1}';
  }

  static Map<String, dynamic> buildCard(
      Map<String, dynamic> saved, {
        required String owner,
        String phone = '',
      }) {
    final now = DateTime.now();
    final minutes = (saved['durationMinutes'] as int?) ?? 0;
    final end = now.add(Duration(minutes: minutes));

    final nextFollowUp = saved['nextFollowUp'] == null
        ? null
        : DateTime.tryParse(saved['nextFollowUp'].toString());

    final approval = (saved['approvalStatus'] ?? '').toString().trim();

    return {
      ...saved,
      'phone': saved['phone'] ?? phone,
      'code': generateCode(now),
      'type': (saved['activityType'] ?? '').toString(),
      'owner': owner,
      'customer': (saved['prospect'] ?? '').toString(),
      'startDate': _formatDate(now),
      'endDate': _formatDate(end),
      'followUp': nextFollowUp == null ? '' : _formatDateTime(nextFollowUp),
      'status': (saved['status'] ?? '').toString(),
      'approvalStatus': approval.isEmpty ? pendingStatus : approval,
    };
  }
}

class ActivitiesScreen extends StatefulWidget {
  final UserRole role;
  final String userName;

  const ActivitiesScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  List<Map<String, dynamic>> get _activities => ActivitiesListStore.activities;

  static const String _allFilter = 'الكل';
  static const String _pendingStatus = ActivitiesListStore.pendingStatus;
  static const String _approvedStatus = 'معتمد';
  static const String _rejectedStatus = 'مرفوض';

  String _searchQuery = '';
  String _statusFilter = _allFilter;

  String get _userInitial {
    final name = widget.userName.trim();
    return name.isEmpty ? '؟' : name.characters.first;
  }

  String _approvalOf(Map<String, dynamic> a) {
    final v = (a['approvalStatus'] ?? '').toString().trim();
    return v.isEmpty ? _pendingStatus : v;
  }

  int get _approvedCount =>
      _activities.where((a) => _approvalOf(a) == _approvedStatus).length;

  int get _rejectedCount =>
      _activities.where((a) => _approvalOf(a) == _rejectedStatus).length;

  int get _pendingCount => _activities.length - _approvedCount - _rejectedCount;

  List<Map<String, dynamic>> get _filteredActivities {
    final q = _searchQuery.trim();

    return _activities.where((a) {
      final approval = _approvalOf(a);

      final matchesChip =
          _statusFilter == _allFilter || approval == _statusFilter;
      final matchesSearch =
          q.isEmpty || approval.contains(q) || q.contains(approval);

      return matchesChip && matchesSearch;
    }).toList();
  }

  Future<void> _openAddActivity() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddActivityScreen(
          role: widget.role,
          userName: widget.userName,
        ),
      ),
    );

    if (result == null || !mounted) return;

    final isManager = widget.role == UserRole.manager;

    final prospectName = (result['prospect'] ?? '').toString();
    final lead = LeadStore.leads
        .where((l) => l.name == prospectName)
        .cast<CustomerLeadItem?>()
        .firstWhere((_) => true, orElse: () => null);

    final card = ActivitiesListStore.buildCard(
      result,
      owner: widget.userName,
      phone: lead?.phoneNum ?? '',
    );

    setState(() {
      _activities.insert(0, card);
    });

    ApprovalStore.add(
      title: context.tr('نشاط'),
      requester: (card['owner'] ?? '').toString(),
      customer: (card['customer'] ?? '').toString(),
      source: card,
      autoApproved: isManager,
    );

    if (!isManager) {
      NotificationStore.notifyManagers(
        type: AppNotificationType.approvalRequest,
        title: context.tr('طلب نشاط جديد'),
        body: context.trArgs('{role} {owner} أضاف نشاطًا ({type}) للعميل {customer} — كود الطلب {code} بانتظار اعتمادك.', {
          'role': AppSession.roleLabel(widget.role),
          'owner': card['owner'],
          'type': card['type'],
          'customer': card['customer'],
          'code': card['code'],
        }),
        data: {'code': card['code']},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'activities_fab',
        onPressed: _openAddActivity,
        backgroundColor: ColorManager.primaryColor,
        foregroundColor: ColorManager.iconColor,
        elevation: 4,
        shape: const StadiumBorder(),
        icon: Icon(Icons.add_rounded, size: 24.sp),
        label: Text(
          context.tr('نشاط جديد'),
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: FontSize.s14.sp,
            fontWeight: FontWeightManager.bold,
            color: ColorManager.iconColor,
          ),
        ),
      ),
      appBar: AppBarScreen(
        title: context.tr('الأنشطة'),
        userInitial: _userInitial,
        onNotificationsTap: () {},
        onAvatarTap: () {},
      ),
      body: Directionality(
        textDirection: context.dir,
        child: ValueListenableBuilder<int>(
          valueListenable: ApprovalStore.changes,
          builder: (context, _, __) {
            final filtered = _filteredActivities;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivitiesFilterSection(
                  totalActivities: _activities.length,
                  pendingActivities: _pendingCount,
                  approvedActivities: _approvedCount,
                  rejectedActivities: _rejectedCount,
                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value),
                  onFilterSelected: (status) =>
                      setState(() => _statusFilter = status),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => ActivityCard(
                      activity: filtered[i],
                      onWhatsapp: () {},
                      onMenu: () {},
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isFiltering =
        _searchQuery.trim().isNotEmpty || _statusFilter != _allFilter;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: ColorManager.primaryColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note_outlined,
                size: 40.sp,
                color: ColorManager.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isFiltering ? context.tr('لا توجد أنشطة بهذه الحالة') : context.tr('لا توجد أنشطة بعد'),
              style: theme.textTheme.titleSmall,
            ),
            if (!isFiltering) ...[
              SizedBox(height: 6.h),
              Text(
                context.tr('اضغط على زر "نشاط جديد" لإضافة أول نشاط'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: FontSize.s12.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}