import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/pdf_export.dart';

class ExportDialog extends StatefulWidget {
  final List<Expense> allExpenses;
  final String currency;

  const ExportDialog({
    super.key,
    required this.allExpenses,
    required this.currency,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _isExporting = false;

  Future<void> _export(bool monthOnly) async {
    setState(() => _isExporting = true);

    List<Expense> toExport;
    String title;

    if (monthOnly) {
      final now = DateTime.now();
      toExport = widget.allExpenses
          .where((e) => e.date.year == now.year && e.date.month == now.month)
          .toList();
      title = 'Dépenses de ${DateFormat('MMMM yyyy', 'fr_FR').format(now)}';
    } else {
      toExport = widget.allExpenses;
      title = 'Toutes les dépenses';
    }

    try {
      await PdfExporter.exportExpenses(
        expenses: toExport,
        title: title,
        currency: widget.currency,
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exporter en PDF'),
      content: _isExporting
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: Colors.orange)),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: Colors.orange),
                  title: const Text('Mois en cours'),
                  subtitle: Text(DateFormat('MMMM yyyy', 'fr_FR').format(DateTime.now())),
                  onTap: () => _export(true),
                ),
                ListTile(
                  leading: const Icon(Icons.all_inbox, color: Colors.orange),
                  title: const Text('Tout exporter'),
                  subtitle: Text('${widget.allExpenses.length} dépenses au total'),
                  onTap: () => _export(false),
                ),
              ],
            ),
      actions: _isExporting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ],
    );
  }
}