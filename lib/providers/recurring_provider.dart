import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/recurring_expense.dart';
import '../database/database_helper.dart';
import 'expense_provider.dart';

class RecurringProvider with ChangeNotifier {
  List<RecurringExpense> _recurringExpenses = [];

  List<RecurringExpense> get recurringExpenses => _recurringExpenses;

  Future<void> loadRecurring() async {
    _recurringExpenses = await DatabaseHelper.instance.readAllRecurring();
    notifyListeners();
  }

  Future<void> addRecurring(RecurringExpense recurring) async {
    final created = await DatabaseHelper.instance.createRecurring(recurring);
    _recurringExpenses.add(created);
    notifyListeners();
  }

  Future<void> updateRecurring(RecurringExpense recurring) async {
    await DatabaseHelper.instance.updateRecurring(recurring);
    final index = _recurringExpenses.indexWhere((r) => r.id == recurring.id);
    if (index != -1) {
      _recurringExpenses[index] = recurring;
      notifyListeners();
    }
  }

  Future<void> deleteRecurring(int id) async {
    await DatabaseHelper.instance.deleteRecurring(id);
    _recurringExpenses.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  String _monthKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  // Génère les dépenses dues pour tous les mois manquants, pour chaque récurrente.
  // Retourne le nombre de dépenses générées.
  Future<int> generateDueExpenses(ExpenseProvider expenseProvider) async {
    await loadRecurring();
    final now = DateTime.now();
    final currentMonthKey = _monthKey(now);
    int generatedCount = 0;

    for (var recurring in List<RecurringExpense>.from(_recurringExpenses)) {
      // Point de départ : mois suivant lastGeneratedMonth, ou startMonth si jamais généré.
      DateTime cursor;
      if (recurring.lastGeneratedMonth != null) {
        final parts = recurring.lastGeneratedMonth!.split('-');
        cursor = DateTime(int.parse(parts[0]), int.parse(parts[1]) + 1, 1);
      } else {
        final parts = recurring.startMonth.split('-');
        cursor = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
      }

      final currentMonthStart = DateTime(now.year, now.month, 1);

      // Génère pour chaque mois entre cursor et le mois courant inclus.
      while (!cursor.isAfter(currentMonthStart)) {
        final day = recurring.dayOfMonth.clamp(1, DateTime(cursor.year, cursor.month + 1, 0).day);
        final expenseDate = DateTime(cursor.year, cursor.month, day);

        // Ne génère pas une dépense dans le futur par rapport à aujourd'hui.
        if (!expenseDate.isAfter(now)) {
          final newExpense = Expense(
            description: '${recurring.description} (auto)',
            amount: recurring.amount,
            category: recurring.category,
            date: expenseDate,
          );
          await expenseProvider.addExpense(newExpense);
          generatedCount++;

          final generatedMonthKey = _monthKey(cursor);
          await DatabaseHelper.instance.markRecurringGenerated(recurring.id!, generatedMonthKey);

          final idx = _recurringExpenses.indexWhere((r) => r.id == recurring.id);
          if (idx != -1) {
            _recurringExpenses[idx] = _recurringExpenses[idx].copyWith(lastGeneratedMonth: generatedMonthKey);
          }
        }

        cursor = DateTime(cursor.year, cursor.month + 1, 1);
      }
    }

    if (generatedCount > 0) notifyListeners();
    return generatedCount;
  }
}