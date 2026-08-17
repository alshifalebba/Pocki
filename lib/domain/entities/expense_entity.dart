import 'package:cloud_firestore/cloud_firestore.dart';

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

class ExpenseEntity {
  final String id;
  final String userId;
  final ExpenseCategory category;
  final String? description;
  final String? otherDetails;
  final double amount;
  final DateTime dateTime;
  final String timeString;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseEntity({
    required this.id,
    required this.userId,
    required this.category,
    this.description,
    this.otherDetails,
    required this.amount,
    required this.dateTime,
    required this.timeString,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'userId': userId,
      'category': category.name,
      'description': description,
      'otherDetails': otherDetails,
      'amount': amount,
      'dateTime': Timestamp.fromDate(dateTime),
      'timeString': timeString,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// JSON-safe map for SharedPreferences (dates as ISO 8601 strings).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category.name,
      'description': description,
      'otherDetails': otherDetails,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'timeString': timeString,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseEntity.fromJson(Map<String, dynamic> json) {
    return ExpenseEntity(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      description: json['description'],
      otherDetails: json['otherDetails'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : DateTime.now(),
      timeString: json['timeString'] ?? '12:00 PM',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory ExpenseEntity.fromDocument(Map<String, dynamic> doc) {
    return ExpenseEntity(
      id: doc['id'] ?? '',
      userId: doc['userId'] ?? '',
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == doc['category'],
        orElse: () => ExpenseCategory.other,
      ),
      description: doc['description'],
      otherDetails: doc['otherDetails'],
      amount: (doc['amount'] ?? 0.0).toDouble(),
      dateTime: doc['dateTime'] != null
          ? (doc['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
      timeString: doc['timeString'] ?? '12:00 PM',
      createdAt: doc['createdAt'] != null
          ? (doc['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: doc['updatedAt'] != null
          ? (doc['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
