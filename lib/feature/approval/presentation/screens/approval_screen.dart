import 'dart:ui' as ui;
import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_accept.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_card.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_details_page.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_reject.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_store.dart';
import 'package:erp_system/feature/customers/presentation/widgets/customer_manager_service.dart';
import 'package:erp_system/feature/home/presentation/widgets/app_bar_screen.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:erp_system/feature/sales/presentation/widgets/price_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApproveScreen extends StatefulWidget {
  final UserRole role;
  final String userName;

  const ApproveScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  State<ApproveScreen> createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen> {
  String get _userInitial {
    final name = widget.userName.trim();
    return name.isEmpty ? '؟' : name.characters.first;
  }

  List<Map<String, dynamic>> get _visibleApprovals {
    final all = ApprovalStore.approvals;

    if (widget.role == UserRole.manager) return all;

    final me = widget.userName.trim();

    return all
        .where((a) => (a['requester'] ?? '').toString().trim() == me)
        .toList();
  }

  void _setStatus(Map<String, dynamic> item, String status) {
    ApprovalStore.setStatus(item, status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == ApprovalStore.approved ? context.tr('تم الاعتماد') : context.tr('تم الرفض'),
        ),
      ),
    );
  }

  Map<String, dynamic> _detailsOf(Map<String, dynamic> item) {
    final details = item['details'];
    return details is Map ? Map<String, dynamic>.from(details) : item;
  }

  Map<String, dynamic>? _findQuote(Map<String, dynamic> item) {
    final d = _detailsOf(item);
    final src = item['source'];

    String pick(String key) {
      final maps = <Map>[item, d, if (src is Map) src];
      for (final m in maps) {
        final v = (m[key] ?? '').toString().trim();
        if (v.isNotEmpty) return v;
      }
      return '';
    }

    final quotes = PriceStore.quotes;
    final number = pick('quoteNumber');

    if (number.isNotEmpty) {
      for (final q in quotes) {
        if ((q['quoteNumber'] ?? '').toString().trim() == number) return q;
      }
    }

    final name = (item['title'] ?? '')
        .toString()
        .replaceFirst('عرض سعر:', '')
        .trim();

    if (name.isEmpty) return null;

    for (final q in quotes) {
      final sameName = (q['name'] ?? '').toString().trim() == name;
      final pending =
          (q['approvalStatus'] ?? '').toString() == ApprovalStore.pending;
      if (sameName && pending) return q;
    }

    return null;
  }

  void _applyQuoteDecision(
      Map<String, dynamic> item, {
        required bool approved,
      }) {
    final quote = _findQuote(item);
    if (quote == null) return;

    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');

    quote['approvalStatus'] =
    approved ? ApprovalStore.approved : ApprovalStore.rejected;
    quote['approvalDate'] = '${now.year}-${two(now.month)}-${two(now.day)}';

    PriceStore.setStatus(
      quote,
      approved ? PriceStore.accepted : PriceStore.rejected,
    );
  }

  void _applyApprovedAction(Map<String, dynamic> item) {
    final d = _detailsOf(item);

    if ((d['action'] ?? '').toString() == 'changeManager') {
      final key = (d['customerKey'] ?? '').toString();
      final newOwner = (d['newOwner'] ?? item['newOwner'] ?? '').toString();

      CustomerManagerService.apply(key, newOwner);
    }

    _applyQuoteDecision(item, approved: true);
  }

  Future<void> _onApprove(Map<String, dynamic> item) async {
    final result = await showApprovalAccept(
      context,
      code: (item['code'] ?? '').toString(),
    );

    if (result == null || !mounted) return;

    item['managerNote'] = result.note;
    item['allowPreviousActivity'] = result.allowPreviousActivity;

    _applyApprovedAction(item);

    _setStatus(item, ApprovalStore.approved);
  }

  Future<void> _onReject(Map<String, dynamic> item) async {
    final reason = await showApprovalReject(
      context,
      code: (item['code'] ?? '').toString(),
    );

    if (reason == null || !mounted) return;

    item['rejectReason'] = reason;

    _applyQuoteDecision(item, approved: false);

    _setStatus(item, ApprovalStore.rejected);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isManager = widget.role == UserRole.manager;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.r,
              height: 96.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.primaryColor.withOpacity(0.10),
              ),
              child: Icon(
                Icons.fact_check_outlined,
                size: 46.sp,
                color: ColorManager.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isManager
                  ? context.tr('لا توجد اعتمادات بعد')
                  : context.tr('لا توجد طلبات خاصة بك'),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s18.sp,
                fontWeight: FontWeightManager.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              isManager
                  ? context.tr('ستظهر هنا الطلبات المقدّمة للاعتماد')
                  : context.tr('ستظهر هنا طلباتك بعد إرسالها للاعتماد'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s14.sp,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBarScreen(
          title: context.tr('الاعتمادات'),
          userInitial: _userInitial,
          onNotificationsTap: () {},
          onAvatarTap: () {},
        ),
        body: Directionality(
          textDirection: context.dir,
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: ApprovalStore.changes,
                  builder: (context, _, __) {
                    final approvals = _visibleApprovals;

                    if (approvals.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        8.h,
                        16.w,
                        24.h,
                      ),
                      itemCount: approvals.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Text(
                              context.tr('الطلبات'),
                              style: theme.textTheme.titleMedium,
                            ),
                          );
                        }

                        final item = approvals[i - 1];

                        item['index'] = '$i';

                        return ApprovalCard(
                          key: ValueKey(item['code'] ?? i),
                          approval: item,
                          isManager: widget.role == UserRole.manager,
                          userName: widget.userName,
                          onView: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ApprovalDetailsPage(
                                  approval: item,
                                ),
                              ),
                            );
                          },
                          onApprove: () => _onApprove(item),
                          onReject: () => _onReject(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}