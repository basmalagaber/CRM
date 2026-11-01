import 'dart:typed_data';
import 'package:excel/excel.dart' as xl;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum ReportFileFormat { excel, pdf }

extension ReportFileFormatX on ReportFileFormat {
  String get label => this == ReportFileFormat.excel ? 'Excel' : 'PDF';
  String get ext => this == ReportFileFormat.excel ? 'xlsx' : 'pdf';
}

class ReportTable {
  const ReportTable({
    required this.fileName,
    required this.title,
    required this.headers,
    required this.rows,
    this.meta = const [],
  });

  final String fileName;
  final String title;

  final List<String> meta;
  final List<String> headers;

  final List<List<Object?>> rows;
}

class ReportExporter {
  ReportExporter._();

  static const String _regularFont =
      'assets/fonts/IBMPlexSansArabic-Regular.ttf';
  static const String _boldFont = 'assets/fonts/IBMPlexSansArabic-Bold.ttf';

  static Future<String> save(
      ReportTable table,
      ReportFileFormat format,
      ) async {
    final Uint8List bytes = format == ReportFileFormat.excel
        ? _buildExcel(table)
        : await _buildPdf(table);

    return FileSaver.instance.saveFile(
      name: '${table.fileName}_${_stamp()}',
      bytes: bytes,
      ext: format.ext,
      mimeType: format == ReportFileFormat.excel
          ? MimeType.microsoftExcel
          : MimeType.pdf,
    );
  }


  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _stamp() {
    final d = DateTime.now();
    return '${d.year}${_two(d.month)}${_two(d.day)}_${_two(d.hour)}${_two(d.minute)}';
  }

  static String _exportedAt() {
    final d = DateTime.now();
    return '${d.year}/${_two(d.month)}/${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';
  }

  static String _text(Object? v) {
    if (v == null) return '';
    if (v is int) return '$v';
    if (v is double) {
      return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
    }
    return v.toString();
  }

  static xl.CellValue _cell(Object? v) {
    if (v is int) return xl.IntCellValue(v);
    if (v is double) return xl.DoubleCellValue(v);
    return xl.TextCellValue(_text(v));
  }

  static List<double> _weights(ReportTable t) {
    return [
      for (var c = 0; c < t.headers.length; c++)
            () {
          var len = t.headers[c].length;
          for (final r in t.rows) {
            if (c < r.length) {
              final l = _text(r[c]).length;
              if (l > len) len = l;
            }
          }
          return len.clamp(5, 26).toDouble();
        }(),
    ];
  }


  static Uint8List _buildExcel(ReportTable t) {
    final excel = xl.Excel.createExcel();

    const sheetName = 'التقرير';
    final defaultName = excel.getDefaultSheet();
    if (defaultName != null && defaultName != sheetName) {
      excel.rename(defaultName, sheetName);
    }

    final sheet = excel[sheetName];
    sheet.isRTL = true;

    final titleStyle = xl.CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex: xl.ExcelColor.fromHexString('#2F6BFF'),
    );
    final metaStyle = xl.CellStyle(
      fontColorHex: xl.ExcelColor.fromHexString('#5B6B8C'),
    );
    final headStyle = xl.CellStyle(
      bold: true,
      fontColorHex: xl.ExcelColor.white,
      backgroundColorHex: xl.ExcelColor.fromHexString('#2F6BFF'),
      horizontalAlign: xl.HorizontalAlign.Center,
      verticalAlign: xl.VerticalAlign.Center,
    );
    final cellStyle = xl.CellStyle(horizontalAlign: xl.HorizontalAlign.Center);
    final zebraStyle = xl.CellStyle(
      horizontalAlign: xl.HorizontalAlign.Center,
      backgroundColorHex: xl.ExcelColor.fromHexString('#F4F7FD'),
    );

    void put(int col, int row, xl.CellValue value, xl.CellStyle style) {
      sheet.updateCell(
        xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
        value,
        cellStyle: style,
      );
    }

    var row = 0;
    put(0, row++, xl.TextCellValue(t.title), titleStyle);
    for (final line in [...t.meta, 'تاريخ التصدير: ${_exportedAt()}']) {
      put(0, row++, xl.TextCellValue(line), metaStyle);
    }
    row++;

    for (var c = 0; c < t.headers.length; c++) {
      put(c, row, xl.TextCellValue(t.headers[c]), headStyle);
    }
    row++;

    for (var r = 0; r < t.rows.length; r++) {
      final style = r.isOdd ? zebraStyle : cellStyle;
      for (var c = 0; c < t.headers.length; c++) {
        final v = c < t.rows[r].length ? t.rows[r][c] : null;
        put(c, row, _cell(v), style);
      }
      row++;
    }

    final weights = _weights(t);
    for (var c = 0; c < weights.length; c++) {
      sheet.setColumnWidth(c, weights[c] * 1.5 + 4);
    }

    final out = excel.encode();
    if (out == null) throw StateError('تعذر إنشاء ملف Excel');
    return Uint8List.fromList(out);
  }


  static Future<Uint8List> _buildPdf(ReportTable t) async {
    final regular = pw.Font.ttf(await rootBundle.load(_regularFont));
    final bold = pw.Font.ttf(await rootBundle.load(_boldFont));

    const primary = PdfColor.fromInt(0xFF2F6BFF);
    const zebra = PdfColor.fromInt(0xFFF4F7FD);

    final cols = t.headers.length;
    final fontSize = cols > 10 ? 7.5 : (cols > 6 ? 9.0 : 11.0);
    final weights = _weights(t);

    pw.Widget cell(String text, {bool header = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            font: header ? bold : regular,
            fontSize: fontSize,
            color: header ? PdfColors.white : PdfColors.black,
          ),
        ),
      );
    }

    List<pw.Widget> reversed(List<pw.Widget> l) => l.reversed.toList();

    final headerRow = pw.TableRow(
      repeat: true,
      decoration: const pw.BoxDecoration(color: primary),
      children: reversed([
        for (final h in t.headers) cell(h, header: true),
      ]),
    );

    final dataRows = <pw.TableRow>[
      for (var r = 0; r < t.rows.length; r++)
        pw.TableRow(
          decoration: r.isOdd ? const pw.BoxDecoration(color: zebra) : null,
          children: reversed([
            for (var c = 0; c < cols; c++)
              cell(_text(c < t.rows[r].length ? t.rows[r][c] : null)),
          ]),
        ),
    ];

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: cols > 6 ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(base: regular, bold: bold),
          textDirection: pw.TextDirection.rtl,
        ),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            '${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(
              font: regular,
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ),
        build: (ctx) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                t.title,
                textAlign: pw.TextAlign.right,
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(font: bold, fontSize: 18, color: primary),
              ),
              pw.SizedBox(height: 6),
              for (final line in [...t.meta, 'تاريخ التصدير: ${_exportedAt()}'])
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(
                    line,
                    textAlign: pw.TextAlign.right,
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              pw.SizedBox(height: 12),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            columnWidths: {
              for (var i = 0; i < cols; i++)
                i: pw.FlexColumnWidth(weights[cols - 1 - i]),
            },
            children: [headerRow, ...dataRows],
          ),
        ],
      ),
    );

    return doc.save();
  }
}