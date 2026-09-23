import 'package:cloud_firestore/cloud_firestore.dart';

class AdditionalAmountEntity {
  final String id;
  final String userId;
  final double amount;
  final String? note;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdditionalAmountEntity({
    required this.id,
    required this.userId,
    required this.amount,
    this.note,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'note': note,
      'month': month,
      'year': year,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AdditionalAmountEntity.fromDocument(Map<String, dynamic> doc) {
    return AdditionalAmountEntity(
      id: doc['id'] ?? '',
      userId: doc['userId'] ?? '',
      amount: (doc['amount'] ?? 0.0).toDouble(),
      note: doc['note'],
      month: (doc['month'] ?? 1) as int,
      year: (doc['year'] ?? DateTime.now().year) as int,
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
      'amount': amount,
      'note': note,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AdditionalAmountEntity.fromJson(Map<String, dynamic> json) {
    return AdditionalAmountEntity(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      note: json['note'],
      month: (json['month'] ?? 1) as int,
      year: (json['year'] ?? DateTime.now().year) as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  AdditionalAmountEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    String? note,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdditionalAmountEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
