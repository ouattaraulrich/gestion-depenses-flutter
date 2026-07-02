import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final currency = context.watch<SettingsProvider>().currency;
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: currency, decimalDigits: 0);

    if (provider.globalBudget == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.savings_outlined, color: Colors.orange),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Aucun budget défini ce mois-ci', style: TextStyle(fontSize: 13)),
            ),
            TextButton(
              onPressed: () => _showBudgetDialog(context, provider),
              child: const Text('Définir'),
            ),
          ],
        ),
      );
    }

    final progress = provider.globalBudgetProgress;
    final isOver = progress >= 1.0;
    final isWarning = progress >= 0.8 && progress < 1.0;

    Color barColor = Colors.green;
    if (isWarning) barColor = Colors.orange;
    if (isOver) barColor = Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Budget du mois', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              GestureDetector(
                onTap: () => _showBudgetDialog(context, provider),
                child: const Icon(Icons.edit, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress > 1.0 ? 1.0 : progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey.shade200,
                  color: barColor,
                  minHeight: 8,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatter.format(provider.totalThisMonth)} / ${formatter.format(provider.globalBudget)}',
            style: const TextStyle(fontSize: 12),
          ),
          if (isOver)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '⚠️ Budget dépassé !',
                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )
          else if (isWarning)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '⚠️ Tu approches de la limite',
                style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController(
      text: provider.globalBudget?.toStringAsFixed(0) ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Budget mensuel'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant du budget'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text.replaceAll(',', '.'));
              if (value != null && value > 0) {
                provider.setGlobalBudget(value);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}