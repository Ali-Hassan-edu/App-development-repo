class Subtask {
  final int? id;
  final int taskId;
  final String title;
  final bool isDone;

  Subtask({
    this.id,
    required this.taskId,
    required this.title,
    required this.isDone,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'taskId': taskId,
    'title': title,
    'isDone': isDone ? 1 : 0,
  };

  factory Subtask.fromMap(Map<String, dynamic> m) => Subtask(
    id: m['id'] as int,
    taskId: m['taskId'] as int,
    title: m['title'] as String,
    isDone: (m['isDone'] as int) == 1,
  );

  Subtask copyWith({int? id, int? taskId, String? title, bool? isDone}) => Subtask(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    isDone: isDone ?? this.isDone,
  );
}