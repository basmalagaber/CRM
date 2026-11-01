import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum ExportFormat { excel, pdf }

class ReportSection {
  final String title;
  final List<List<String>> rows;
  const ReportSection({required this.title, required this.rows});
}

class PerformanceReport {
  final String employee;
  final String period;
  final List<ReportSection> sections;

  const PerformanceReport({
    required this.employee,
    required this.period,
    required this.sections,
  });

  factory PerformanceReport.sample({
    required String employee,
    required String period,
  }) {
    return PerformanceReport(
      employee: employee,
      period: period,
      sections: const [
        ReportSection(
          title: 'العملاء المحتملون والفرص',
          rows: [
            ['إجمالي العملاء المحتملين', '84'],
            ['العملاء المحولون إلى عميل', '71'],
            ['إجمالي الفرص', '23'],
            ['الفرص الرابحة', '41'],
            ['الفرص الخاسرة', '6'],
            ['الفرص المعلقة', '21'],
          ],
        ),
        ReportSection(
          title: 'عروض الأسعار والمبيعات والفواتير',
          rows: [
            ['إجمالي عروض الأسعار', '40'],
            ['معتمدة', '22'],
            ['مرفوضة', '7'],
            ['معلقة', '11'],
            ['إجمالي أوامر البيع المؤكدة', '51'],
            ['إجمالي أوامر البيع', '2'],
            ['أوامر البيع المعلقة', '3'],
          ],
        ),
        ReportSection(
          title: 'الأنشطة والمكالمات والزيارات',
          rows: [
            ['إجمالي الأنشطة', '46'],
            ['الأنشطة المكتملة', '94'],
            ['الأنشطة المعلقة', '51'],
            ['إجمالي المكالمات', '73'],
          ],
        ),
        ReportSection(
          title: 'تفاصيل تأخيرات المتابعة',
          rows: [
            ['إجمالي التأخيرات', '0'],
            ['تم حلها', '0'],
            ['مفتوحة', '0'],
            ['الالتزام', '100%'],
          ],
        ),
      ],
    );
  }
}

class PerformanceExportService {
  PerformanceExportService._();

  static const String _fontRegular = 'assets/fonts/Cairo-Regular.ttf';
  static const String _fontBold = 'assets/fonts/Cairo-Bold.ttf';

  static Future<String> export(
      PerformanceReport report,
      ExportFormat format,
      ) async {
    final fileName =
    'أداء_${report.employee}_${report.period}'.replaceAll(' ', '_');

    switch (format) {
      case ExportFormat.excel:
        final bytes = _buildExcel(report);
        return FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
      case ExportFormat.pdf:
        final bytes = await _buildPdf(report);
        return FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: 'pdf',
          mimeType: MimeType.pdf,
        );
    }
  }


  static Uint8List _buildExcel(PerformanceReport report) {
    final excel = Excel.createExcel();

    const sheetName = 'الأداء';
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null) excel.rename(defaultSheet, sheetName);

    final sheet = excel[sheetName];
    sheet.isRTL = true;
    sheet.setColumnWidth(0, 38);
    sheet.setColumnWidth(1, 16);

    final bold = CellStyle(bold: true);
    var row = 0;

    void addRow(List<String> values, {bool isBold = false}) {
      sheet.appendRow(values.map((v) => TextCellValue(v)).toList());
      if (isBold) {
        for (var c = 0; c < values.length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
              .cellStyle = bold;
        }
      }
      row++;
    }

    addRow(['تقرير أداء الموظف'], isBold: true);
    addRow(['الموظف', report.employee]);
    addRow(['الفترة', report.period]);
    addRow(['تاريخ التقرير', _today()]);
    addRow(['']);

    for (final section in report.sections) {
      addRow([section.title], isBold: true);
      addRow(['البند', 'القيمة'], isBold: true);
      for (final r in section.rows) {
        addRow(r);
      }
      addRow(['']);
    }

    final data = excel.encode();
    return Uint8List.fromList(data!);
  }


  static Future<Uint8List> _buildPdf(PerformanceReport report) async {
    final regular = pw.Font.ttf(await rootBundle.load(_fontRegular));
    final bold = pw.Font.ttf(await rootBundle.load(_fontBold));

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    const primary = PdfColor.fromInt(0xFF2F5BFF);

    pw.Widget rtlText(
        String text, {
          double size = 12,
          bool isBold = false,
          PdfColor? color,
        }) {
      return pw.Container(
        width: double.infinity,
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          text,
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            fontSize: size,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          rtlText('تقرير أداء الموظف', size: 22, isBold: true, color: primary),
          pw.SizedBox(height: 8),
          rtlText('الموظف: ${report.employee}'),
          rtlText('الفترة: ${report.period}'),
          rtlText('تاريخ التقرير: ${_today()}'),
          pw.SizedBox(height: 14),
          for (final section in report.sections) ...[
            rtlText(section.title, size: 15, isBold: true),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['القيمة', 'البند'],
              data: section.rows.map((r) => [r[1], r[0]]).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 11,
              ),
              headerDecoration: const pw.BoxDecoration(color: primary),
              cellStyle: const pw.TextStyle(fontSize: 11),
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerRight,
              },
              headerAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerRight,
              },
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FlexColumnWidth(),
              },
              cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: pw.TableBorder.all(color: PdfColors.grey300),
            ),
            pw.SizedBox(height: 16),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static String _today() {
    final d = DateTime.now();
    return '${d.day}/${d.month}/${d.year}';
  }
}