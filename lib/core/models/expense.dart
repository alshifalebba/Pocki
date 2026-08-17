enum ExpenseCategory {
  food,
  petrol,
  dress,
  groceries,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.petrol:
        return 'Petrol';
      case ExpenseCategory.dress:
        return 'Dress';
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.petrol:
        return '⛽';
      case ExpenseCategory.dress:
        return '👗';
      case ExpenseCategory.groceries:
        return '🛒';
      case ExpenseCategory.other:
        return '✨';
    }
  }
}

class Expense {
  final String id;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String time;
  final String? description;
  final String? otherDetails;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.time,
    this.description,
    this.otherDetails,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'category': category.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'time': time,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
    if (category == ExpenseCategory.other && otherDetails != null) {
      map['otherDetails'] = otherDetails;
    }
    return map;
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      time: json['time'] ?? '12:00 PM',
      description: json['description'],
      otherDetails: json['otherDetails'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
