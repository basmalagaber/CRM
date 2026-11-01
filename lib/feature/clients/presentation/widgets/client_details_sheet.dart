import 'package:erp_system/core/localization/app_strings.dart';
import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:erp_system/core/resources/fonts_manager.dart';
import 'package:erp_system/feature/clients/data/client_store.dart';
import 'package:erp_system/feature/clients/presentation/widgets/client_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show NumberFormat;

Future<void> showClientDetails(BuildContext context, ClientItem client) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (_) => _ClientDetailsSheet(client: client),
  );
}

class _ClientDetailsSheet extends StatelessWidget {
  final ClientItem client;

  const _ClientDetailsSheet({required this.client});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final origin = client.origin;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Directionality(
      textDirection: context.dir,
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.name, style: theme.textTheme.titleMedium),
                          Text(
                            client.company.isEmpty ? '-' : client.company,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: origin.color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(origin.icon, size: 13.sp, color: origin.color),
                          SizedBox(width: 4.w),
                          Text(
                            context.tr(origin.label),
                            style: TextStyle(
                              fontFamily: FontConstants.fontFamily,
                              fontSize: 11.sp,
                              fontWeight: FontWeightManager.bold,
                              color: origin.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Section(
                        title: context.tr('بيانات العميل'),
                        rows: [
                          _Row(Icons.person_outline_rounded, context.tr('المسؤول'),
                              client.managerName),
                          _Row(Icons.phone_outlined, context.tr('الهاتف'), client.phone,
                              ltr: true),
                          _Row(Icons.mail_outline_rounded, context.tr('البريد الإلكتروني'),
                              client.email,
                              ltr: true),
                          _Row(Icons.campaign_outlined, context.tr('المصدر'), client.source),
                        ],
                      ),
                      _Section(
                        title: context.tr('بيانات التحويل'),
                        rows: [
                          _Row(Icons.swap_horiz_rounded, context.tr('نوع التحويل'),
                              context.tr(origin.label)),
                          _Row(Icons.event_available_outlined, context.tr('تاريخ التحويل'),
                              fmtClientDate(
                                  client.lastConvertedAt ?? client.createdAt)),
                          _Row(Icons.event_outlined, context.tr('عميل منذ'),
                              fmtClientDate(client.createdAt)),
                          if (client.quoteCode != null)
                            _Row(Icons.request_quote_outlined, context.tr('عرض السعر'),
                                client.quoteCode!),
                          if (client.convertedLeads.isNotEmpty)
                            _Row(Icons.people_outline_rounded,
                                context.tr('العملاء المحتملون المحوّلون'),
                                client.convertedLeads.join('، ')),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 18.h, bottom: 8.h),
                        child: Text(context.tr('الاهتمامات العقارية'),
                            style: theme.textTheme.titleSmall),
                      ),
                      if (client.interests.isEmpty)
                        Text(context.tr('لا توجد اهتمامات مسجلة.'),
                            style: theme.textTheme.bodyMedium)
                      else
                        for (final p in client.interests)
                          _InterestTile(data: p),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row {
  final IconData icon;
  final String label;
  final String value;
  final bool ltr;

  const _Row(this.icon, this.label, this.value, {this.ltr = false});
}

class _Section extends StatelessWidget {
  final String title;
  final List<_Row> rows;

  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
          child: Text(title, style: theme.textTheme.titleSmall),
        ),
        for (final r in rows)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 7.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: ColorManager.primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(r.icon,
                      size: 18.sp, color: ColorManager.primaryColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.label, style: theme.textTheme.bodySmall),
                      Text(
                        r.value.isEmpty ? '-' : r.value,
                        textDirection: r.ltr ? TextDirection.ltr : null,
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InterestTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _InterestTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = (data['code'] ?? '').toString();
    final name = (data['name'] ?? '').toString();
    final title = code.isNotEmpty ? '$code - $name' : name;
    final price = data['unitPrice'];
    final tags = [
      data['interestType'],
      data['dealType'],
      data['interestLevel'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(' • ');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.isEmpty ? '-' : title,
                    style: theme.textTheme.titleSmall),
                if (tags.isNotEmpty)
                  Text(tags, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (price is num)
            Text(
              NumberFormat('#,##0.##').format(price),
              style: TextStyle(
                fontFamily: FontConstants.fontFamily,
                fontSize: FontSize.s14.sp,
                fontWeight: FontWeightManager.bold,
                color: ColorManager.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}