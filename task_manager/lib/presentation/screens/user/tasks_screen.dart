import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/task_operations_provider.dart';
import '../../../core/utils/constants.dart';
import '../../../domain/entities/task_entity.dart';

class UserTasksScreen extends ConsumerWidget {
  const UserTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tasksAsync = ref.watch(userTasksStreamProvider(user.id));
    const primaryColor = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          'MY TASKS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(userTasksStreamProvider(user.id)),
        child: tasksAsync.when(
          data: (tasks) => _buildBody(context, ref, tasks, user.name),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<TaskEntity> tasks, String name) {
    final pendingTasks = tasks.where((t) => t.status != AppConstants.statusCompleted).toList();
    final completedTasks = tasks.where((t) => t.status == AppConstants.statusCompleted).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $name',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Here are your assigned tasks',
                style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Pending Tasks', Icons.pending_actions),
          const SizedBox(height: 16),
          if (pendingTasks.isEmpty)
            _buildEmptyState('No pending tasks. Great job! 🎉')
          else
            ...pendingTasks.map((task) => _TaskCard(task: task)),
          const SizedBox(height: 32),
          _buildSectionHeader('Completed Tasks', Icons.check_circle_outline),
          const SizedBox(height: 16),
          if (completedTasks.isEmpty)
            _buildEmptyState('Finish some tasks to see them here.')
          else
            ...completedTasks.map((task) => _TaskCard(task: task, isCompleted: true)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.1)),
      ),
      child: Text(message, textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final TaskEntity task;
  final bool isCompleted;

  const _TaskCard({required this.task, this.isCompleted = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = _getPriorityColor(task.priority);
    final isOverdue = task.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: isCompleted ? Colors.green : priorityColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.blueGrey : const Color(0xFF0D47A1),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(task.priority, style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF0D47A1),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14,
                              color: isOverdue ? Colors.red : const Color(0xFF0D47A1)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isOverdue ? Colors.red : const Color(0xFF0D47A1),
                            ),
                          ),
                          const Spacer(),
                          if (!isCompleted)
                            InkWell(
                              onTap: () {
                                final isPending = task.status == AppConstants.statusPending;
                                final nextStatus = isPending
                                    ? AppConstants.statusInProgress
                                    : AppConstants.statusCompleted;
                                ref
                                    .read(taskOperationsNotifierProvider.notifier)
                                    .updateTaskStatusWithNotification(task.id, nextStatus, task);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: task.status == AppConstants.statusPending
                                      ? const Color(0xFF0D47A1)
                                      : Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.status == AppConstants.statusPending ? 'Start' : 'Done ✓',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          if (isCompleted)
                            const Icon(Icons.check_circle, color: Colors.green, size: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.blue;
    }
  }
}
