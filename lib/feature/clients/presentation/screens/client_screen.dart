import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/clients/data/client_store.dart';
import 'package:erp_system/feature/clients/presentation/widgets/client_card.dart';
import 'package:erp_system/feature/login/presentation/widgets/login_buttton.dart';
import 'package:erp_system/feature/notification/presentation/widgets/app_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:erp_system/feature/clients/presentation/widgets/client_details_sheet.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _query = '';
  ClientOrigin? _origin;

  bool get _seesAll =>
      AppSession.role == UserRole.manager ||
          AppSession.role == UserRole.leader;

  List<ClientItem> _mine() => ClientStore.all
      .where((c) => _seesAll || c.managerName == AppSession.userName)
      .toList();

  List<ClientItem> _filtered(List<ClientItem> mine) {
    final q = _query.trim().toLowerCase();

    return mine.where((c) {
      if (_origin != null && c.origin != _origin) return false;
      if (q.isEmpty) return true;

      return c.name.toLowerCase().contains(q) ||
          c.company.toLowerCase().contains(q) ||
          c.phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: context.dir,
      child: Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: ClientStore.changes,
            builder: (context, _, __) {
              final mine = _mine();
              final list = _filtered(mine);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('العملاء'),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: FontSize.s20.sp,
                                ),
                              ),
                              Text(
                                context.trArgs('{count} عميل', {'count': mine.length}),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14.sp,
                        height: 1.3,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                      decoration: InputDecoration(
                        fillColor: theme.cardTheme.color,
                        hintText: context.tr('بحث بالاسم أو الشركة أو الهاتف...'),
                        prefixIcon: Icon(Icons.search_rounded, size: 22.sp),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 40.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: [
                        _FilterChip(
                          label: context.trArgs('الكل ({count})', {'count': mine.length}),
                          selected: _origin == null,
                          onTap: () => setState(() => _origin = null),
                        ),
                        for (final o in ClientOrigin.values) ...[
                          SizedBox(width: 8.w),
                          _FilterChip(
                            label: context.trArgs('{label} ({count})', {
                              'label': context.tr(o.label),
                              'count': mine.where((c) => c.origin == o).length,
                            }),
                            selected: _origin == o,
                            onTap: () => setState(() => _origin = o),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Expanded(
                    child: list.isEmpty
                        ? _EmptyState(isFiltering: mine.isNotEmpty)
                        : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      itemCount: list.length,
                      itemBuilder: (context, i) => ClientCard(
                        client: list[i],
                        onTap: () => showClientDetails(context, list[i]),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ColorManager.primaryColor : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? ColorManager.primaryColor : theme.dividerColor,
          ),

        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FontConstants.fontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeightManager.semiBold,
            color: selected
                ? ColorManager.iconColor
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltering;

  const _EmptyState({required this.isFiltering});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Icons.groups_2_outlined,
                size: 40.sp,
                color: ColorManager.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isFiltering
                  ? context.tr('لا توجد نتائج مطابقة')
                  : context.tr('لا يوجد عملاء بعد'),
              style: theme.textTheme.titleSmall,
            ),
            SizedBox(height: 6.h),
            Text(
              isFiltering
                  ? context.tr('جرّب تغيير البحث أو الفلتر')
                  : context.tr('العميل بيظهر هنا بعد تحويل عميل محتمل إلى عميل، أو تلقائيًا لما عرض السعر يتقبّل.'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: FontSize.s12.sp,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}