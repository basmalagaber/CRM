import 'dart:ui' as ui;
import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/approval/presentation/widgets/approval_store.dart';
import 'package:erp_system/feature/home/presentation/widgets/app_bar_screen.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:erp_system/feature/notification/presentation/widgets/notification_store.dart';
import 'package:erp_system/feature/sales/presentation/widgets/add_price_offer_screen.dart';
import 'package:erp_system/feature/sales/presentation/widgets/price_card.dart';
import 'package:erp_system/feature/sales/presentation/widgets/price_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SalesScreen extends StatefulWidget {
  final UserRole role;
  final String userInitial;
  final String userName;

  const SalesScreen({
    super.key,
    required this.role,
    required this.userInitial,
    required this.userName,
  });

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  bool get _isManager => widget.role == UserRole.manager;

  Future<void> _addOffer() async {
    final offer = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPriceOfferScreen(
          role: widget.role,
          userName: widget.userName,
        ),
      ),
    );

    if (offer == null || !mounted) return;

    offer['approvalStatus'] =
    _isManager ? ApprovalStore.approved : ApprovalStore.pending;

    PriceStore.add(offer, owner: widget.userName);

    ApprovalStore.add(
      title: '${context.tr('عرض السعر')}: ${offer['name'] ?? ''}',
      requester: widget.userName,
      newOwner: widget.userName,
      customer: (offer['goal'] ?? '').toString(),
      source: offer,
      autoApproved: _isManager,
    );

    NotificationStore.notifyManagersNewItem(
      actorName: widget.userName,
      actorRole: widget.role,
      kind: NotificationItemKind.quote,
      itemName: (offer['name'] ?? '').toString(),
    );
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool danger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('إلغاء')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: danger
                  ? TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              )
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _findApproval(Map<String, dynamic> quote) {
    final number = (quote['quoteNumber'] ?? '').toString().trim();
    final name = (quote['name'] ?? '').toString().trim();
    final owner = (quote['owner'] ?? '').toString().trim();

    if (number.isNotEmpty) {
      for (final a in ApprovalStore.approvals) {
        final details = a['details'];
        final src = a['source'];
        final maps = <Map>[a, if (details is Map) details, if (src is Map) src];

        if (maps.any((m) => (m['quoteNumber'] ?? '').toString().trim() == number)) {
          return a;
        }
      }
    }

    if (name.isEmpty) return null;

    for (final a in ApprovalStore.approvals) {
      final title =
      (a['title'] ?? '').toString().replaceFirst(context.tr('عرض السعر'), '').trim();
      final requester = (a['requester'] ?? '').toString().trim();
      final current = (a['approvalStatus'] ?? '').toString();
      final pending = current.isEmpty || current == ApprovalStore.pending;

      if (title == name && pending && (owner.isEmpty || requester == owner)) {
        return a;
      }
    }

    return null;
  }

  void _syncApproval(Map<String, dynamic> quote, String status) {
    final accepted = status == PriceStore.accepted;
    final rejected = status == PriceStore.rejected;
    if (!accepted && !rejected) return;

    final approvalStatus =
    accepted ? ApprovalStore.approved : ApprovalStore.rejected;

    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');

    quote['approvalStatus'] = approvalStatus;
    quote['approvalDate'] = '${now.year}-${two(now.month)}-${two(now.day)}';

    final approval = _findApproval(quote);
    if (approval == null) return;

    final current = (approval['approvalStatus'] ?? '').toString();
    if (current.isEmpty || current == ApprovalStore.pending) {
      ApprovalStore.setStatus(approval, approvalStatus);
    }
  }

  Future<void> _changeStatus(Map<String, dynamic> quote, String status) async {
    final customer = (quote['customer'] ?? '').toString();
    final quoteNumber = (quote['quoteNumber'] ?? '').toString();
    final isLead = quote['customerType'] == context.tr('عميل محتمل');

    if (status == PriceStore.accepted) {
      final ok = await _confirm(
        title: context.tr('قبول عرض السعر'),
        message: isLead
            ? context.trArgs('تأكيد قبول العرض؟ العميل المحتمل "{customer}" هيتحول إلى عميل.', {'customer': customer})
            : context.tr('تأكيد قبول العرض؟'),
        confirmLabel: context.tr('قبول'),
      );
      if (ok != true || !mounted) return;
    } else if (status == PriceStore.rejected) {
      final ok = await _confirm(
        title: context.tr('رفض عرض السعر'),
        message: context.tr('تأكيد رفض العرض؟ مش هتقدري تغيّري الحالة بعد كده.'),
        confirmLabel: context.tr('رفض'),
        danger: true,
      );
      if (ok != true || !mounted) return;
    }

    _syncApproval(quote, status);

    final converted = PriceStore.setStatus(quote, status);

    final message = status == PriceStore.accepted
        ? (converted
        ? context.trArgs('تم قبول العرض وتحويل {customer} إلى عميل', {'customer': customer})
        : context.tr('تم قبول العرض'))
        : context.trArgs('تم تغيير حالة العرض إلى {status}', {'status': status});

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

    if (status == PriceStore.accepted && !_isManager) {
      NotificationStore.notifyManagers(
        type: AppNotificationType.general,
        title: context.tr('عرض سعر مقبول'),
        body: context.trArgs('{role} {name} سجّل قبول عرض السعر {number} للعميل {customer}{converted}', {
          'role': AppSession.roleLabel(widget.role),
          'name': widget.userName,
          'number': quoteNumber,
          'customer': customer,
          'converted': converted ? context.tr(' وتم تحويله إلى عميل') : '',
        }),
        targetTab: AppNavigation.salesTab,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _buildFab(),
      appBar: AppBarScreen(
        title: context.tr('عروض الأسعار'),
        userInitial: widget.userInitial,
        onNotificationsTap: () {},
        onAvatarTap: () {},
      ),
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: ValueListenableBuilder<int>(
          valueListenable: PriceStore.changes,
          builder: (context, _, __) {
            final quotes = PriceStore.quotes;

            if (quotes.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
              itemCount: quotes.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Text(
                      context.tr('عروض الأسعار'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                final q = quotes[i - 1];
                q['index'] = '$i';

                return PriceCard(
                  quote: q,
                  onView: () {},
                  onEdit: () {},
                  onDelete: () => PriceStore.remove(q),
                  onWhatsapp: () {},
                  onStatusChange: (status) => _changeStatus(q, status),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      heroTag: 'sales_fab',
      onPressed: _addOffer,
      backgroundColor: ColorManager.primaryColor,
      foregroundColor: ColorManager.iconColor,
      elevation: 4,
      shape: const StadiumBorder(),
      icon: Icon(
        Icons.add_rounded,
        size: 24.sp,
      ),
      label: Text(
        context.tr('عرض سعر جديد'),
        style: TextStyle(
          fontFamily: FontConstants.fontFamily,
          fontSize: FontSize.s14.sp,
          fontWeight: FontWeightManager.bold,
          color: ColorManager.iconColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

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
                Icons.request_quote_outlined,
                size: 46.sp,
                color: ColorManager.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              context.tr('لا توجد عروض أسعار بعد'),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s18.sp,
                fontWeight: FontWeightManager.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              context.tr('اضغطي على زر "عرض سعر جديد" لإضافة أول عرض سعر'),
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
}