import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/widgets/search_filter_bar.dart';
import '../../home/widgets/settings_modal.dart';
import '../../home/widgets/task_card.dart';
import '../../home/widgets/task_detail_modal.dart';
import '../../../data/models/task_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../task_management/providers/task_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SearchFilterState _filter = const SearchFilterState();

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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF),
                      const Color(0xFF00BC8C),
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
                        Icons.checklist_rounded,
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
                            'Task Mania',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Your Ultimate Task Manager',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        themeProv.themeMode == ThemeMode.dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white,
                      ),
                      onPressed: themeProv.toggleTheme,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useSafeArea: true,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const SettingsModal(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchFilterBar(
                  initial: _filter,
                  onChanged: (s) => setState(() => _filter = s),
                ),
              ),
              
              // Scrollable content
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) {
                    final tasks = taskProvider.tasks;
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);

                    final todayTasks = tasks.where((t) {
                      if (t.dueDate == null || t.isCompleted) return false;
                      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
                      return d == today;
                    }).toList();

                    final completedTasks = tasks.where((t) => t.isCompleted).toList();
                    final repeatedTasks = tasks.where((t) => (t.repeatRule ?? '').isNotEmpty).toList();
                    final missedTasks = tasks.where((t) {
                      if (t.dueDate == null || t.isCompleted) return false;
                      if (!t.dueDate!.isBefore(now)) return false;
                      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
                      return d != today;
                    }).toList();

                    // Filter + sort
                    List<Task> filtered = List<Task>.from(tasks);
                    if (_filter.query.isNotEmpty) {
                      filtered = filtered
                          .where((t) =>
                              t.title.toLowerCase().contains(_filter.query.toLowerCase()) ||
                              (t.description ?? '').toLowerCase().contains(_filter.query.toLowerCase()))
                          .toList();
                    }
                    if (_filter.priorities.isNotEmpty) {
                      filtered = filtered.where((t) => _filter.priorities.contains(t.priority)).toList();
                    }
                    switch (_filter.sort) {
                      case TaskSort.dueSoon:
                        filtered.sort((a, b) {
                          final ad = a.dueDate ?? DateTime(2100);
                          final bd = b.dueDate ?? DateTime(2100);
                          return ad.compareTo(bd);
                        });
                        break;
                      case TaskSort.priorityHighFirst:
                        filtered.sort((a, b) =>
                            SearchFilterState.priorityScore(b.priority)
                                .compareTo(SearchFilterState.priorityScore(a.priority)));
                        break;
                      case TaskSort.titleAZ:
                        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
                        break;
                    }

                    final stats = [
                      _StatItem(
                        title: "Today's Tasks",
                        count: todayTasks.length,
                        subtitle: "Due today",
                        color: const Color(0xFF6C63FF),
                        icon: Icons.today_rounded,
                      ),
                      _StatItem(
                        title: "Completed",
                        count: completedTasks.length,
                        subtitle: "All done!",
                        color: const Color(0xFF00BC8C),
                        icon: Icons.check_circle_rounded,
                      ),
                      _StatItem(
                        title: "Repeated",
                        count: repeatedTasks.length,
                        subtitle: "Recurring",
                        color: const Color(0xFFFF6B6B),
                        icon: Icons.autorenew_rounded,
                      ),
                      _StatItem(
                        title: "Missed",
                        count: missedTasks.length,
                        subtitle: "Overdue",
                        color: const Color(0xFFFFB347),
                        icon: Icons.warning_rounded,
                      ),
                    ];

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome message
                          Text(
                            'Hello, Champion! 👋',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Let\'s conquer your tasks today!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white70 : Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 20),

                          // Stats grid with animation
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: stats.length,
                            itemBuilder: (context, index) {
                              return TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                curve: Curves.easeOutCubic,
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Opacity(
                                      opacity: value,
                                      child: _StatsCard(stat: stats[index]),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 32),
                          
                          // All Tasks header
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6C63FF), Color(0xFF00BC8C)],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "All Tasks",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF2D3748),
                                    ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6C63FF), Color(0xFF00BC8C)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${filtered.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (filtered.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 60),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.task_alt_rounded,
                                      size: 80,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No tasks found',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your filters',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...filtered.asMap().entries.map((entry) {
                              final task = entry.value;
                              final index = entry.key;
                              final subs = taskProvider.subtasks[task.id] ?? [];
                              return TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(milliseconds: 100 + (index * 50)),
                                curve: Curves.easeOutCubic,
                                builder: (context, double value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: TaskCard(
                                        task: task,
                                        subtasks: subs,
                                        onToggleComplete: () => taskProvider.toggleComplete(task),
                                        onToggleSubtask: (sub) => taskProvider.toggleSubtaskDone(sub),
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) => TaskDetailModal(
                                              task: task,
                                              subtasks: subs,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          const SizedBox(height: 100),
                        ],
                      ),
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

// ----- helpers -----

class _StatItem {
  final String title;
  final int count;
  final String subtitle;
  final Color color;
  final IconData icon;

  _StatItem({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}

class _StatsCard extends StatelessWidget {
  final _StatItem stat;

  const _StatsCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stat.color.withOpacity(isDark ? 0.3 : 0.1),
            stat.color.withOpacity(isDark ? 0.2 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: stat.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(isDark ? 0.3 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    stat.icon,
                    color: stat.color,
                    size: 24,
                  ),
                ),
                Text(
                  stat.count.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: stat.color,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
