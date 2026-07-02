import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/recurring_expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('depenses.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        amount REAL NOT NULL,
        month TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE recurring_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        dayOfMonth INTEGER NOT NULL,
        startMonth TEXT NOT NULL,
        lastGeneratedMonth TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT,
          amount REAL NOT NULL,
          month TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE recurring_expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          dayOfMonth INTEGER NOT NULL,
          startMonth TEXT NOT NULL,
          lastGeneratedMonth TEXT
        )
      ''');
    }
  }

  // ---- EXPENSES ----

  // CREATE
  Future<Expense> create(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap()..remove('id'));
    return expense.copyWith(id: id);
  }

  // READ - toutes les dépenses
  Future<List<Expense>> readAllExpenses() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('expenses', orderBy: orderBy);
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  // READ - une dépense
  Future<Expense?> readExpense(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'expenses',
      columns: ['id', 'description', 'amount', 'category', 'date'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE
  Future<int> update(Expense expense) async {
    final db = await instance.database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Filtrer par catégorie
  Future<List<Expense>> readByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  // Recherche par description
  Future<List<Expense>> search(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'description LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  // Total des dépenses
  Future<double> getTotal() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    final total = result.first['total'];
    return total == null ? 0.0 : total as double;
  }

  // ---- BUDGETS ----

  // month au format 'YYYY-MM'. category = null pour le budget global.
  Future<void> setBudget({String? category, required double amount, required String month}) async {
    final db = await instance.database;
    final existing = await db.query(
      'budgets',
      where: category == null ? 'category IS NULL AND month = ?' : 'category = ? AND month = ?',
      whereArgs: category == null ? [month] : [category, month],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'budgets',
        {'amount': amount},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert('budgets', {
        'category': category,
        'amount': amount,
        'month': month,
      });
    }
  }

  Future<double?> getGlobalBudget(String month) async {
    final db = await instance.database;
    final result = await db.query(
      'budgets',
      where: 'category IS NULL AND month = ?',
      whereArgs: [month],
    );
    if (result.isEmpty) return null;
    return result.first['amount'] as double;
  }

  Future<Map<String, double>> getCategoryBudgets(String month) async {
    final db = await instance.database;
    final result = await db.query(
      'budgets',
      where: 'category IS NOT NULL AND month = ?',
      whereArgs: [month],
    );
    final Map<String, double> map = {};
    for (var row in result) {
      map[row['category'] as String] = row['amount'] as double;
    }
    return map;
  }

  // ---- RECURRING EXPENSES ----

  Future<RecurringExpense> createRecurring(RecurringExpense recurring) async {
    final db = await instance.database;
    final id = await db.insert('recurring_expenses', recurring.toMap()..remove('id'));
    return recurring.copyWith(id: id);
  }

  Future<List<RecurringExpense>> readAllRecurring() async {
    final db = await instance.database;
    final result = await db.query('recurring_expenses', orderBy: 'dayOfMonth ASC');
    return result.map((map) => RecurringExpense.fromMap(map)).toList();
  }

  Future<int> updateRecurring(RecurringExpense recurring) async {
    final db = await instance.database;
    return db.update(
      'recurring_expenses',
      recurring.toMap(),
      where: 'id = ?',
      whereArgs: [recurring.id],
    );
  }

  Future<int> deleteRecurring(int id) async {
    final db = await instance.database;
    return db.delete('recurring_expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markRecurringGenerated(int id, String month) async {
    final db = await instance.database;
    await db.update(
      'recurring_expenses',
      {'lastGeneratedMonth': month},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}