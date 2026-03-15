import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../providers/task_operations_provider.dart';
import '../../../domain/entities/task_entity.dart';

class UserTasksScreen extends ConsumerStatefulWidget {
  final String userId;
  const UserTasksScreen({super.key, required this.userId});

  @override
  ConsumerState<UserTasksScreen> createState() => _UserTasksScreenState();
}

class _UserTasksScreenState extends ConsumerState<UserTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const primaryColor = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(userTasksStreamProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(userTasksStreamProvider(widget.userId)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final pending = tasks.where((t) => t.status == 'Pending').toList();
          final inProgress =
              tasks.where((t) => t.status == 'In Progress').toList();
          final completed =
              tasks.where((t) => t.status == 'Completed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _TaskList(
                tasks: pending,
                emptyMessage: 'No pending tasks 🎉',
                userId: widget.userId,
                onStatusChange: _updateStatus,
              ),
              _TaskList(
                tasks: inProgress,
                emptyMessage: 'No tasks in progress',
                userId: widget.userId,
                onStatusChange: _updateStatus,
              ),
              _TaskList(
                tasks: completed,
                emptyMessage: 'No completed tasks yet',
                userId: widget.userId,
                onStatusChange: _updateStatus,
                isCompletedTab: true,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 12),
              Text('Failed to load: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(userTasksStreamProvider(widget.userId)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, foregroundColor: Colors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, TaskEntity task, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          newStatus == 'Completed' ? '✅ Mark as Done?' : '▶ Start Task?',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          newStatus == 'Completed'
              ? 'Mark "${task.title}" as completed?\nThe admin will be notified.'
              : 'Start working on "${task.title}"?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'Completed' ? Colors.green : primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
            ),
            child: Text(newStatus == 'Completed' ? 'Mark Done' : 'Start'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(taskOperationsNotifierProvider.notifier)
          .updateTaskStatusWithNotification(task.id, newStatus, task);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'Completed' ? '🎉 Task marked complete!' : '▶ Task started!',
            ),
            backgroundColor:
                newStatus == 'Completed' ? Colors.green : primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskEntity> tasks;
  final String emptyMessage;
  final String userId;
  final Future<void> Function(BuildContext, TaskEntity, String) onStatusChange;
  final bool isCompletedTab;

  const _TaskList({
    required this.tasks,
    required this.emptyMessage,
    required this.userId,
    required this.onStatusChange,
    this.isCompletedTab = false,
  });

  static const primaryColor = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompletedTab
                  ? Icons.hourglass_empty_rounded
                  : Icons.task_alt_rounded,
              size: 72,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _FullTaskCard(
          task: task,
          onStatusChange: (s) => onStatusChange(context, task, s),
          isCompletedTab: isCompletedTab,
        );
      },
    );
  }
}

class _FullTaskCard extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<String> onStatusChange;
  final bool isCompletedTab;

  const _FullTaskCard({
    required this.task,
    required this.onStatusChange,
    this.isCompletedTab = false,
  });

  static const primaryColor = Color(0xFF0D47A1);

  Color get _priorityColor {
    switch (task.priority) {
      case 'High':
        return const Color(0xFFC62828);
      case 'Low':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'Completed';
    final isInProgress = task.status == 'In Progress';
    final overdue = task.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: overdue ? Colors.red.shade100 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _priorityColor,
                    borderRadius: BorderRadius.circular(4),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isCompleted
                              ? Colors.grey.shade400
                              : const Color(0xFF1A1A2E),
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${task.priority} Priority',
                        style: TextStyle(
                            fontSize: 11,
                            color: _priorityColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                if (overdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('OVERDUE',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                task.description,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13,
                    color: overdue ? Colors.red : Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: overdue ? Colors.red : Colors.grey.shade500,
                    fontWeight:
                        overdue ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (!isCompletedTab) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!isInProgress)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onStatusChange('In Progress'),
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Start'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (!isInProgress) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onStatusChange('Completed'),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Mark Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Completed${task.completedAt != null ? ' on ${DateFormat('MMM dd').format(task.completedAt!)}' : ''}',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
