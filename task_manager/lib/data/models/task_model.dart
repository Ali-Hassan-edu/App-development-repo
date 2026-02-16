import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priority,
    required super.dueDate,
    required super.status,
    required super.assignedToId,
    super.assignedToName,
    super.completedAt,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      priority: entity.priority,
      dueDate: entity.dueDate,
      status: entity.status,
      assignedToId: entity.assignedToId,
      assignedToName: entity.assignedToName,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
    );
  }
}
