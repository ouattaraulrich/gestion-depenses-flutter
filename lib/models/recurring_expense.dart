class RecurringExpense {
  final int? id;
  final String description;
  final double amount;
  final String category;
  final int dayOfMonth; // jour du mois où la dépense doit être générée (1-28)
  final String startMonth; // 'YYYY-MM', premier mois d'application
  final String? lastGeneratedMonth; // 'YYYY-MM', dernier mois déjà généré

  RecurringExpense({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.dayOfMonth,
    required this.startMonth,
    this.lastGeneratedMonth,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'dayOfMonth': dayOfMonth,
      'startMonth': startMonth,
      'lastGeneratedMonth': lastGeneratedMonth,
    };
  }

  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'] as int?,
      description: map['description'] as String,
      amount: map['amount'] as double,
      category: map['category'] as String,
      dayOfMonth: map['dayOfMonth'] as int,
      startMonth: map['startMonth'] as String,
      lastGeneratedMonth: map['lastGeneratedMonth'] as String?,
    );
  }

  RecurringExpense copyWith({
    int? id,
    String? description,
    double? amount,
    String? category,
    int? dayOfMonth,
    String? startMonth,
    String? lastGeneratedMonth,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startMonth: startMonth ?? this.startMonth,
      lastGeneratedMonth: lastGeneratedMonth ?? this.lastGeneratedMonth,
    );
  }
}