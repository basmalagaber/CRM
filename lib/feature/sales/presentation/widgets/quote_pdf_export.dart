import 'package:erp_system/feature/reports/presentation/widgets/report_exporter.dart';
import 'package:erp_system/feature/reports/presentation/widgets/reports_widgets.dart';
import 'package:flutter/material.dart';

Future<void> downloadQuotePdf(
    BuildContext context,
    Map<String, dynamic> quote,
    ) async {
  String s(String key) {
    final v = (quote[key] ?? '').toString().trim();
    return v.isEmpty ? '—' : v;
  }

  final number = s('quoteNumber');

  final safe = number.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');

  final table = ReportTable(
    fileName: safe.isEmpty ? 'quotation' : 'quotation_$safe',
    title: 'عرض سعر $number',
    meta: ['العميل: ${s('customer')}'],
    headers: const ['البند', 'القيمة'],
    rows: [
      ['رقم عرض السعر', number],
      ['الكود', s('code')],
      ['العميل', s('customer')],
      ['رقم الهاتف', s('phone')],
      ['الحالة', quote['status'] == null ? 'مسودة' : s('status')],
      ['حالة الاعتماد', s('approvalStatus')],
      ['الإجمالي', s('total')],
      ['المسؤول', s('owner')],
      ['تاريخ العرض', s('quoteDate')],
      ['تاريخ الاعتماد', s('approvalDate')],
    ],
  );

  await exportReport(context, table, ReportFileFormat.pdf);
}