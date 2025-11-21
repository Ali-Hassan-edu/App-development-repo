import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/task_model.dart';
import '../../../data/models/subtask_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final List<Subtask> subtasks;
  final VoidCallback onToggleComplete;
  final Function(Subtask) onToggleSubtask;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.subtasks,
    required this.onToggleComplete,
    required this.onToggleSubtask,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = subtasks.isEmpty
        ? 0.0
        : subtasks.where((s) => s.isDone).length / subtasks.length;
    
    final priorityColor = _getPriorityColor(task.priority);
    final isOverdue = task.dueDate != null && 
                      task.dueDate!.isBefore(DateTime.now()) && 
                      !task.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: task.isCompleted
              ? [
                  Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
                  Colors.grey.withOpacity(isDark ? 0.15 : 0.05),
                ]
              : [
                  priorityColor.withOpacity(isDark ? 0.15 : 0.08),
                  priorityColor.withOpacity(isDark ? 0.1 : 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isCompleted 
              ? Colors.grey.withOpacity(0.3)
              : priorityColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (task.isCompleted ? Colors.grey : priorityColor).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom checkbox
                    GestureDetector(
                      onTap: onToggleComplete,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: task.isCompleted
                              ? LinearGradient(
                                  colors: [priorityColor, priorityColor.withOpacity(0.7)],
                                )
                              : null,
                          color: task.isCompleted ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: task.isCompleted ? Colors.transparent : priorityColor,
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? Colors.grey
                                  : (isDark ? Colors.white : const Color(0xFF2D3748)),
                            ),
                          ),
                          if (task.description != null &&
                              task.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              task.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: task.isCompleted
                                    ? Colors.grey
                                    : (isDark ? Colors.white70 : Colors.grey[700]),
                                fontSize: 14,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Complete/Reopen Button
                    GestureDetector(
                      onTap: () {
                        onToggleComplete();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: task.isCompleted
                                ? [Colors.orange, Colors.orange.withOpacity(0.7)]
                                : [const Color(0xFF00BC8C), const Color(0xFF00BC8C).withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (task.isCompleted ? Colors.orange : const Color(0xFF00BC8C)).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          task.isCompleted ? Icons.restart_alt : Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                // Due date and repeat info
                if (task.dueDate != null || task.repeatRule != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Priority Badge
                      _PriorityBadge(priority: task.priority),
                      if (task.dueDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? Colors.red.withOpacity(0.15)
                                : const Color(0xFF6C63FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOverdue ? Colors.red : const Color(0xFF6C63FF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOverdue ? Icons.warning_rounded : Icons.access_time_rounded,
                                size: 14,
                                color: isOverdue ? Colors.red : const Color(0xFF6C63FF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, h:mm a').format(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isOverdue ? Colors.red : const Color(0xFF6C63FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (task.repeatRule != null && task.repeatRule!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BC8C).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00BC8C),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.autorenew_rounded,
                                size: 14,
                                color: Color(0xFF00BC8C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.repeatRule!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00BC8C),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],

                // Progress bar for subtasks
                if (subtasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.checklist_rounded,
                        size: 16,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${subtasks.where((s) => s.isDone).length}/${subtasks.length} subtasks',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(priorityColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFF6B6B);
      case 'medium':
        return const Color(0xFFFFB347);
      case 'low':
        return const Color(0xFF00BC8C);
      default:
        return const Color(0xFF6C63FF);
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            priority,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFF6B6B);
      case 'medium':
        return const Color(0xFFFFB347);
      case 'low':
        return const Color(0xFF00BC8C);
      default:
        return Colors.grey;
    }
  }
}
