import 'package:expense_tracker/core/formatters/money_format.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReportService {
  const PdfReportService();

  pw.Document buildExpenseReport({
    required DateTime from,
    required DateTime to,
    required List<Expense> expenses,
  }) {
    final dateFmt = DateFormat('yyyy-MM-dd');
    final title = 'Mikisho Expense Report';
    final range = '${dateFmt.format(from)} → ${dateFmt.format(to)}';

    final filtered = expenses
        .where((e) => !e.dateTime.isBefore(from) && !e.dateTime.isAfter(to))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final total = filtered.fold<double>(0, (sum, e) => sum + e.amount);

    final byCategory = <String, double>{};
    for (final e in filtered) {
      byCategory[e.categoryId] = (byCategory[e.categoryId] ?? 0) + e.amount;
    }
    final catSorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 32),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(999),
                  ),
                  child: pw.Text(
                    range,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Total spent',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      formatBirr(total),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Transactions',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '${filtered.length}',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Category breakdown',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Category',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Amount',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              for (final entry in catSorted.take(10))
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        DefaultExpenseCategories.byId(entry.key).name,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        formatBirr(entry.value),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Transactions',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(4),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(
                      'Date',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(
                      'Category',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(
                      'Title / Notes',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(7),
                    child: pw.Text(
                      'Amount',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              for (final e in filtered)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(7),
                      child: pw.Text(dateFmt.format(e.dateTime)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(7),
                      child: pw.Text(
                        DefaultExpenseCategories.byId(e.categoryId).name,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(7),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(e.title),
                          if ((e.notes ?? '').trim().isNotEmpty)
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 2),
                              child: pw.Text(
                                e.notes!,
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(7),
                      child: pw.Text(
                        formatBirr(e.amount),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return doc;
  }
}

