class Task {
  final int? id;
  final String title;
  final String? description;
  final String priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? repeatRule;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    this.dueDate,
    required this.isCompleted,
    this.repeatRule,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority,
    'dueDate': dueDate?.millisecondsSinceEpoch,
    'isCompleted': isCompleted ? 1 : 0,
    'repeatRule': repeatRule,
  };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'] as int,
    title: m['title'] as String,
    description: m['description'] as String?,
    priority: m['priority'] as String,
    dueDate: m['dueDate'] == null ? null : DateTime.fromMillisecondsSinceEpoch(m['dueDate'] as int),
    isCompleted: (m['isCompleted'] as int) == 1,
    repeatRule: m['repeatRule'] as String?,
  );

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
    String? repeatRule,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatRule: repeatRule ?? this.repeatRule,
    );
  }
}