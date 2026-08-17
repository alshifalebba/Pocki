import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String uid;
  final String name;
  final String nickname;
  final String email;
  final String phone;
  final String? avatarUrl;
  final double monthlyBudget;
  final String quote;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.uid,
    required this.name,
    required this.nickname,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.monthlyBudget,
    required this.quote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserEntity.defaultUser(String uid, String email) {
    final now = DateTime.now();
    return UserEntity(
      uid: uid,
      name: 'Pocki User',
      nickname: 'pocki_user',
      email: email,
      phone: '',
      avatarUrl: null,
      monthlyBudget: 15000.0,
      quote: 'Stay focused and make it happen. ✨',
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'monthlyBudget': monthlyBudget,
      'quote': quote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Serializes to a JSON-safe map (for SharedPreferences / dart:convert).
  /// Dates are stored as ISO 8601 strings — NOT Firestore Timestamps.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'monthlyBudget': monthlyBudget,
      'quote': quote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Pocki User',
      nickname: json['nickname'] ?? 'user',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'],
      monthlyBudget: (json['monthlyBudget'] ?? 15000.0).toDouble(),
      quote: json['quote'] ?? 'Stay focused and make it happen. ✨',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory UserEntity.fromDocument(Map<String, dynamic> doc) {
    return UserEntity(
      uid: doc['uid'] ?? '',
      name: doc['name'] ?? 'Pocki User',
      nickname: doc['nickname'] ?? 'user',
      email: doc['email'] ?? '',
      phone: doc['phone'] ?? '',
      avatarUrl: doc['avatarUrl'],
      monthlyBudget: (doc['monthlyBudget'] ?? 15000.0).toDouble(),
      quote: doc['quote'] ?? 'Stay focused and make it happen. ✨',
      createdAt: doc['createdAt'] != null
          ? (doc['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: doc['updatedAt'] != null
          ? (doc['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  UserEntity copyWith({
    String? uid,
    String? name,
    String? nickname,
    String? email,
    String? phone,
    String? avatarUrl,
    double? monthlyBudget,
    String? quote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      quote: quote ?? this.quote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
