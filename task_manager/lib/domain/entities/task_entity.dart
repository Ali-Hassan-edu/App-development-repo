class TaskEntity {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime dueDate;
  final String status;
  final String assignedToId;
  final String? assignedToName;
  final DateTime? completedAt;
  final DateTime createdAt;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
    required this.assignedToId,
    this.assignedToName,
    this.completedAt,
    required this.createdAt,
  });

  bool get isOverdue =>
      DateTime.now().isAfter(dueDate) && status != 'Completed';
}
