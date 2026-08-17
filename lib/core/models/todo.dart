class TodoTask {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String time;
  final String? note;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  TodoTask({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.time,
    this.note,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  /// Checks if task is active on a given target date according to multi-day logic:
  /// task appears if targetDate >= startDate AND targetDate <= endDate
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'time': time,
      'note': note,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      time: json['time'] ?? '06:00 PM',
      note: json['note'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  TodoTask copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? time,
    String? note,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      time: time ?? this.time,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
