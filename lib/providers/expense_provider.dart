import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  String _searchQuery = '';
  String? _selectedCategory;

  double? _globalBudget;
  Map<String, double> _categoryBudgets = {};

  List<Expense> get expenses {
    List<Expense> filtered = _expenses;

    if (_selectedCategory != null) {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((e) => e.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<Expense> get allExpensesUnfiltered => _expenses;

  double get total => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get totalThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> loadExpenses() async {
    _expenses = await DatabaseHelper.instance.readAllExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    final created = await DatabaseHelper.instance.create(expense);
    _expenses.insert(0, created);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await DatabaseHelper.instance.update(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.delete(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Map<String, double> get totalsByCategory {
    final Map<String, double> totals = {};
    for (var e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  // ---- BUDGETS ----

  double? get globalBudget => _globalBudget;
  Map<String, double> get categoryBudgets => _categoryBudgets;

  String get currentMonthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> loadBudgets() async {
    _globalBudget = await DatabaseHelper.instance.getGlobalBudget(currentMonthKey);
    _categoryBudgets = await DatabaseHelper.instance.getCategoryBudgets(currentMonthKey);
    notifyListeners();
  }

  Future<void> setGlobalBudget(double amount) async {
    await DatabaseHelper.instance.setBudget(amount: amount, month: currentMonthKey);
    await loadBudgets();
  }

  Future<void> setCategoryBudget(String category, double amount) async {
    await DatabaseHelper.instance.setBudget(category: category, amount: amount, month: currentMonthKey);
    await loadBudgets();
  }

  double get globalBudgetProgress {
    if (_globalBudget == null || _globalBudget == 0) return 0;
    return (totalThisMonth / _globalBudget!).clamp(0.0, 2.0);
  }

  double categoryBudgetProgress(String category) {
    final budget = _categoryBudgets[category];
    if (budget == null || budget == 0) return 0;
    final spent = totalsByCategory[category] ?? 0;
    return (spent / budget).clamp(0.0, 2.0);
  }
}