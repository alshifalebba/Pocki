import 'package:cloud_firestore/cloud_firestore.dart';

class TodoEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String timeString;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.timeString,
    this.completed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Multi-day logic: today >= startDate AND today <= endDate
  bool isActiveOnDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return (target.isAfter(start) || target.isAtSameMomentAs(start)) &&
        (target.isBefore(end) || target.isAtSameMomentAs(end));
  }

  String get durationBadgeText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (start == end && start == today) {
      return 'Today';
    }

    final days = end.difference(start).inDays + 1;
    if (days == 1) {
      if (start.difference(today).inDays == 1) return 'Tomorrow';
      return '${start.day}/${start.month}';
    }
    return '$days Days';
  }

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'timeString': timeString,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// JSON-safe map for SharedPreferences (dates as ISO 8601 strings).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'timeString': timeString,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TodoEntity.fromJson(Map<String, dynamic> json) {
    return TodoEntity(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.now(),
      timeString: json['timeString'] ?? '06:00 PM',
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory TodoEntity.fromDocument(Map<String, dynamic> doc) {
    return TodoEntity(
      id: doc['id'] ?? '',
      userId: doc['userId'] ?? '',
      title: doc['title'] ?? '',
      description: doc['description'],
      startDate: doc['startDate'] != null
          ? (doc['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: doc['endDate'] != null
          ? (doc['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      timeString: doc['timeString'] ?? '06:00 PM',
      completed: doc['completed'] ?? false,
      createdAt: doc['createdAt'] != null
          ? (doc['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: doc['updatedAt'] != null
          ? (doc['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  TodoEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? timeString,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timeString: timeString ?? this.timeString,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
