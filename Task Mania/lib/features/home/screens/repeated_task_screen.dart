import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../task_management/providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_modal.dart';
import '../../../core/theme/theme_provider.dart';

class RepeatedTaskScreen extends StatelessWidget {
  const RepeatedTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final isDark = themeProv.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF0F4FF),
                    const Color(0xFFE8F5E9),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with gradient
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6C63FF),
                      Color(0xFF00BC8C),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.autorenew,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Repeating Tasks',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Recurring activities',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    final repeatedTasks = taskProvider.tasks
                        .where((task) =>
                    task.repeatRule != null &&
                        task.repeatRule!.isNotEmpty)
                        .toList();

                    return repeatedTasks.isEmpty
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.autorenew, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No repeating tasks',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: repeatedTasks.length,
          itemBuilder: (context, index) {
            final task = repeatedTasks[index];
            final subtasks = taskProvider.subtasks[task.id] ?? [];
            return TaskCard(
              task: task,
              subtasks: subtasks,
              onToggleComplete: () => taskProvider.toggleComplete(task),
              onToggleSubtask: taskProvider.toggleSubtaskDone,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => TaskDetailModal(
                    task: task,
                    subtasks: subtasks,
                  ),
                );
              },
            );
          },
        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
