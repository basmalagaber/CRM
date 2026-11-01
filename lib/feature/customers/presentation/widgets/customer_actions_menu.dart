import 'package:erp_system/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


enum CustomerMenuAction {
  view,
  viewActivity,
  history,
  addActivity,
  changeManager,
  convertToClient,
  mergeWith,
  edit,
  delete,
}

extension CustomerMenuActionData on CustomerMenuAction {
  String get label {
    switch (this) {
      case CustomerMenuAction.view:
        return 'عرض';
      case CustomerMenuAction.viewActivity:
        return 'عرض نشاط';
      case CustomerMenuAction.history:
        return 'السجلات';
      case CustomerMenuAction.addActivity:
        return 'اضافة نشاط';
      case CustomerMenuAction.changeManager:
        return 'تغيير المسؤول';
      case CustomerMenuAction.convertToClient:
        return 'تحويل إلى عميل';
      case CustomerMenuAction.mergeWith:
        return 'دمج مع';
      case CustomerMenuAction.edit:
        return 'تعديل';
      case CustomerMenuAction.delete:
        return 'حذف';
    }
  }

  IconData get icon {
    switch (this) {
      case CustomerMenuAction.view:
        return Icons.visibility_outlined;
      case CustomerMenuAction.viewActivity:
        return Icons.trending_up_rounded;
      case CustomerMenuAction.history:
        return Icons.history_rounded;
      case CustomerMenuAction.addActivity:
        return Icons.fast_forward_outlined;
      case CustomerMenuAction.changeManager:
        return Icons.manage_accounts_outlined;
      case CustomerMenuAction.convertToClient:
        return Icons.person_add_alt_outlined;
      case CustomerMenuAction.mergeWith:
        return Icons.account_tree_outlined;
      case CustomerMenuAction.edit:
        return Icons.edit_outlined;
      case CustomerMenuAction.delete:
        return Icons.delete;
    }
  }

  String get recordTitle {
    switch (this) {
      case CustomerMenuAction.view:
        return 'عرض العميل';
      case CustomerMenuAction.viewActivity:
        return 'عرض النشاط';
      case CustomerMenuAction.history:
        return 'السجلات';
      case CustomerMenuAction.addActivity:
        return 'تمت إضافة نشاط';
      case CustomerMenuAction.changeManager:
        return 'تم تغيير المسؤول';
      case CustomerMenuAction.convertToClient:
        return 'تم التحويل إلى عميل';
      case CustomerMenuAction.mergeWith:
        return 'تم الدمج';
      case CustomerMenuAction.edit:
        return 'تم تعديل بيانات العميل';
      case CustomerMenuAction.delete:
        return 'تم حذف العميل';
    }
  }

  bool get needsInput =>
      this == CustomerMenuAction.changeManager ||
          this == CustomerMenuAction.mergeWith;

  bool get needsConfirm =>
      this == CustomerMenuAction.convertToClient ||
          this == CustomerMenuAction.delete;
}

class CustomerActionResult {
  final CustomerMenuAction action;
  final String? note;

  const CustomerActionResult({required this.action, this.note});
}

Future<CustomerMenuAction?> showCustomerActionsMenu(
    BuildContext buttonContext,
    ) {
  final theme = Theme.of(buttonContext);

  final button = buttonContext.findRenderObject() as RenderBox;

  final overlay =
  Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

  final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);

  final rect = Rect.fromLTWH(
    topLeft.dx,
    topLeft.dy,
    button.size.width,
    button.size.height,
  );

  return showMenu<CustomerMenuAction>(
    context: buttonContext,
    position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
    color: theme.cardColor,
    elevation: 6,
    menuPadding: const EdgeInsets.symmetric(vertical: 6),
    constraints: const BoxConstraints(minWidth: 200, maxWidth: 220),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: theme.dividerColor),
    ),
    items: CustomerMenuAction.values
        .map(
          (action) => PopupMenuItem<CustomerMenuAction>(
        value: action,
        height: 46,
        padding: EdgeInsets.zero,
        child: _MenuRow(action: action),
      ),
    )
        .toList(),
  );
}

class _MenuRow extends StatelessWidget {
  final CustomerMenuAction action;

  const _MenuRow({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDelete = action == CustomerMenuAction.delete;

    final color =
    isDelete ? theme.colorScheme.error : theme.textTheme.bodyLarge?.color;

    return Directionality(
      textDirection: context.dir,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.tr(action.label),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16.sp,
                  color: color,
                ),
              ),
            ),
            Icon(
              action.icon,
              size: 28,
              color: isDelete
                  ? theme.colorScheme.error
                  : theme.textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }
}

Future<CustomerActionResult?> askCustomerAction(
    BuildContext context,
    CustomerMenuAction action,
    String customerName,
    ) async {
  if (action.needsInput) {
    final controller = TextEditingController();

    final hint = action == CustomerMenuAction.changeManager
        ? 'اسم المسؤول الجديد'
        : 'اسم العميل المراد الدمج معه';

    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: context.dir,
        child: AlertDialog(
          title: Text(context.tr(action.label)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: context.tr(hint)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text(context.tr('إلغاء')),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(ctx, value);
                }
              },
              child: Text(context.tr('تأكيد')),
            ),
          ],
        ),
      ),
    );

    controller.dispose();

    if (text == null) {
      return null;
    }

    return CustomerActionResult(action: action, note: text);
  }

  if (action.needsConfirm) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: context.dir,
        child: AlertDialog(
          title: Text(context.tr(action.label)),
          content: Text(
            context.trArgs('هل تريد تنفيذ "{action}" للعميل {name}؟', {
              'action': context.tr(action.label),
              'name': customerName,
            }),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: Text(context.tr('إلغاء')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: Text(context.tr('تأكيد')),
            ),
          ],
        ),
      ),
    );

    if (ok != true) {
      return null;
    }

    return CustomerActionResult(action: action);
  }

  return CustomerActionResult(action: action);
}