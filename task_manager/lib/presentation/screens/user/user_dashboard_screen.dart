import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/task_operations_provider.dart';
import '../../../domain/entities/task_entity.dart';

class UserDashboardScreen extends ConsumerWidget {
  final String userId;
  const UserDashboardScreen({super.key, required this.userId});

  static const primaryColor = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final tasksAsync = ref.watch(userTasksStreamProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: tasksAsync.when(
        data: (tasks) {
          final pending = tasks.where((t) => t.status == 'Pending').toList();
          final inProgress =
              tasks.where((t) => t.status == 'In Progress').toList();
          final completed =
              tasks.where((t) => t.status == 'Completed').toList();
          final overdue = tasks.where((t) => t.isOverdue).toList();

          final headerCardWidth = (MediaQuery.of(context).size.width - 58) / 2;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 290,
                pinned: true,
                backgroundColor: primaryColor,
                elevation: 0,
                titleSpacing: 16,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final topPadding = MediaQuery.of(context).padding.top;
                    final isCollapsed = constraints.biggest.height <=
                        kToolbarHeight + topPadding + 20;

                    return AnimatedOpacity(
                      opacity: isCollapsed ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text(
                        'My Dashboard',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            const Text(
                              'My Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (user?.name.isNotEmpty == true)
                                          ? user!.name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Welcome back,',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        user?.name ?? 'User',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: headerCardWidth,
                                  child: _MiniStat(
                                    '${tasks.length}',
                                    'Total',
                                    Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: headerCardWidth,
                                  child: _MiniStat(
                                    '${pending.length}',
                                    'Pending',
                                    Colors.orange.shade200,
                                  ),
                                ),
                                SizedBox(
                                  width: headerCardWidth,
                                  child: _MiniStat(
                                    '${inProgress.length}',
                                    'Active',
                                    Colors.lightBlue.shade200,
                                  ),
                                ),
                                SizedBox(
                                  width: headerCardWidth,
                                  child: _MiniStat(
                                    '${completed.length}',
                                    'Done',
                                    Colors.green.shade200,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (overdue.isNotEmpty)
                      _OverdueAlert(count: overdue.length),
                    if (inProgress.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _SectionHeader(
                        icon: Icons.play_circle_rounded,
                        label: 'In Progress',
                        color: const Color(0xFF1565C0),
                        count: inProgress.length,
                      ),
                      const SizedBox(height: 10),
                      ...inProgress.map(
                        (t) => _TaskCard(
                          task: t,
                          userId: userId,
                          onStatusChange: (newStatus) =>
                              _changeStatus(context, ref, t, newStatus),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (pending.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.pending_actions_rounded,
                        label: 'Pending Tasks',
                        color: const Color(0xFFE65100),
                        count: pending.length,
                      ),
                      const SizedBox(height: 10),
                      ...pending.map(
                        (t) => _TaskCard(
                          task: t,
                          userId: userId,
                          onStatusChange: (newStatus) =>
                              _changeStatus(context, ref, t, newStatus),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (completed.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.check_circle_rounded,
                        label: 'Completed',
                        color: const Color(0xFF2E7D32),
                        count: completed.length,
                      ),
                      const SizedBox(height: 10),
                      ...completed.take(3).map(
                            (t) => _TaskCard(
                              task: t,
                              userId: userId,
                              onStatusChange: (_) {},
                            ),
                          ),
                      const SizedBox(height: 20),
                    ],
                    if (tasks.isEmpty) const _EmptyState(),
                    const SizedBox(height: 80),
                  ]),
                ),
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
              const SizedBox(height: 16),
              Text(
                'Failed to load tasks:\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
    String newStatus,
  ) async {
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
              ? 'Mark "${task.title}" as completed? The admin will be notified.'
              : 'Start working on "${task.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'Completed' ? Colors.green : primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus == 'Completed' ? 'Mark Done' : 'Start'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(taskOperationsNotifierProvider.notifier)
          .updateTaskStatusWithNotification(task.id, newStatus, task);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'Completed'
                  ? '🎉 Task marked as complete!'
                  : '▶ Task started!',
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _MiniStat extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  const _MiniStat(this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverdueAlert extends StatelessWidget {
  final int count;
  const _OverdueAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count task${count > 1 ? 's are' : ' is'} overdue! Please update them.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 80,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your assigned tasks will appear here.',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  final String userId;
  final ValueChanged<String> onStatusChange;

  const _TaskCard({
    required this.task,
    required this.userId,
    required this.onStatusChange,
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

  Color get _statusColor {
    switch (task.status) {
      case 'Completed':
        return const Color(0xFF2E7D32);
      case 'In Progress':
        return primaryColor;
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: overdue ? Colors.red.shade200 : Colors.grey.shade100,
        ),
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
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: TextStyle(
                      color: _priorityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                if (overdue)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isCompleted
                    ? Colors.grey.shade400
                    : const Color(0xFF1A1A2E),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: overdue ? Colors.red : Colors.grey.shade500,
                        fontWeight: overdue ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (!isCompleted) ...[
                  if (!isInProgress)
                    _ActionButton(
                      label: 'Start',
                      icon: Icons.play_arrow_rounded,
                      color: primaryColor,
                      onTap: () => onStatusChange('In Progress'),
                    ),
                  if (isInProgress)
                    _ActionButton(
                      label: 'Mark Done',
                      icon: Icons.check_rounded,
                      color: Colors.green,
                      onTap: () => onStatusChange('Completed'),
                    )
                  else
                    _ActionButton(
                      label: 'Done',
                      icon: Icons.check_rounded,
                      color: Colors.green,
                      onTap: () => onStatusChange('Completed'),
                    ),
                ] else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
