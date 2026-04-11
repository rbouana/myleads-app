/// Reminder entity for the local SQLite database.
class Reminder {
  final String id;
  final String contactId;
  String title;
  String? description;
  DateTime dueDate;
  bool isCompleted;
  String priority; // 'urgent', 'soon', 'later'
  DateTime createdAt;
  String ownerId;

  Reminder({
    required this.id,
    required this.contactId,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 'soon',
    DateTime? createdAt,
    this.ownerId = '',
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dueDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dueDate.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  Reminder copyWith({
    String? id,
    String? contactId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? priority,
    String? ownerId,
  }) {
    return Reminder(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
