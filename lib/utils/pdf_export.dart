import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class PdfExporter {
  static Future<void> exportExpenses({
    required List<Expense> expenses,
    required String title,
    required String currency,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: currency, decimalDigits: 0);
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    // Regroupement par catégorie pour le résumé
    final Map<String, double> byCategory = {};
    for (var e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Rapport de Dépenses',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800),
            ),
            pw.SizedBox(height: 4),
            pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(
              'Généré le ${dateFormatter.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
            pw.Divider(color: PdfColors.orange200, thickness: 1.5),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ),
        build: (context) => [
          // ---- Résumé total ----
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total général', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(
                      formatter.format(total),
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Nombre de dépenses', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(
                      '${expenses.length}',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ---- Résumé par catégorie ----
          pw.Text('Résumé par catégorie', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.orange100),
                children: [
                  _cell('Catégorie', bold: true),
                  _cell('Montant', bold: true),
                  _cell('Part', bold: true),
                ],
              ),
              ...sortedCategories.map((e) {
                final percent = total > 0 ? (e.value / total * 100) : 0;
                return pw.TableRow(
                  children: [
                    _cell(e.key),
                    _cell(formatter.format(e.value)),
                    _cell('${percent.toStringAsFixed(1)}%'),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 24),

          // ---- Liste détaillée ----
          pw.Text('Détail des dépenses', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.orange100),
                children: [
                  _cell('Date', bold: true),
                  _cell('Description', bold: true),
                  _cell('Catégorie', bold: true),
                  _cell('Montant', bold: true),
                ],
              ),
              ...expenses.map((e) => pw.TableRow(
                    children: [
                      _cell(dateFormatter.format(e.date)),
                      _cell(e.description),
                      _cell(e.category),
                      _cell(formatter.format(e.amount)),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'depenses_${DateFormat('yyyy_MM_dd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }
}