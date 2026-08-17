import 'package:cloud_firestore/cloud_firestore.dart';

class FixedExpenseEntity {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  FixedExpenseEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory FixedExpenseEntity.fromDocument(Map<String, dynamic> doc) {
    return FixedExpenseEntity(
      id: doc['id'] ?? '',
      userId: doc['userId'] ?? '',
      name: doc['name'] ?? '',
      amount: (doc['amount'] ?? 0.0).toDouble(),
      category: doc['category'] ?? 'Other',
      createdAt: doc['createdAt'] != null
          ? (doc['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: doc['updatedAt'] != null
          ? (doc['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FixedExpenseEntity.fromJson(Map<String, dynamic> json) {
    return FixedExpenseEntity(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'Other',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  FixedExpenseEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FixedExpenseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
