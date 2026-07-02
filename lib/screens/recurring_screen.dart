import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/recurring_expense.dart';
import '../providers/recurring_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsProvider>().currency;
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: currency, decimalDigits: 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dépenses récurrentes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RecurringProvider>(
        builder: (context, provider, _) {
          if (provider.recurringExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Aucune dépense récurrente', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text(
                    'Ex: loyer, abonnement Internet...',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.recurringExpenses.length,
            itemBuilder: (context, index) {
              final r = provider.recurringExpenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.15),
                    child: Text(AppCategories.getIcon(r.category), style: const TextStyle(fontSize: 18)),
                  ),
                  title: Text(r.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${r.category} • le ${r.dayOfMonth} de chaque mois'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatter.format(r.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Supprimer'),
                              content: Text('Supprimer la récurrence "${r.description}" ?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            provider.deleteRecurring(r.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = AppCategories.categories.first['name']!;
    int selectedDay = 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvelle dépense récurrente'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description (ex: Loyer)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Montant'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Catégorie'),
                      items: AppCategories.categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat['name'],
                          child: Text('${cat['icon']} ${cat['name']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedDay,
                      decoration: const InputDecoration(labelText: 'Jour du mois'),
                      items: List.generate(28, (i) => i + 1)
                          .map((d) => DropdownMenuItem(value: d, child: Text('Le $d')))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => selectedDay = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
                    if (descController.text.trim().isEmpty || amount == null || amount <= 0) {
                      return;
                    }

                    final now = DateTime.now();
                    final startMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

                    context.read<RecurringProvider>().addRecurring(
                          RecurringExpense(
                            description: descController.text.trim(),
                            amount: amount,
                            category: selectedCategory,
                            dayOfMonth: selectedDay,
                            startMonth: startMonth,
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
