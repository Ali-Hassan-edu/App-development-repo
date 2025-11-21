import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/models/subtask_model.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subtaskController = TextEditingController();

  DateTime? _dueDate;
  String _priority = 'Medium';
  String _repeatRule = '';
  final List<Subtask> _subtasks = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task?.description ?? '';
      _dueDate = widget.task?.dueDate;
      _priority = widget.task?.priority ?? 'Medium';
      _repeatRule = widget.task?.repeatRule ?? '';

      final provider = context.read<TaskProvider>();
      final existing = provider.subtasks[widget.task!.id] ?? [];
      _subtasks.addAll(existing);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              entryModeIconColor: Colors.transparent,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );
    if (time == null) return;

    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _subtasks.add(
        Subtask(
          taskId: widget.task?.id ?? -1,
          title: text,
          isDone: false,
        ),
      );
      _subtaskController.clear();
    });
  }

  void _removeSubtask(int index) {
    setState(() => _subtasks.removeAt(index));
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        isCompleted: widget.task?.isCompleted ?? false,
        repeatRule: _repeatRule.isEmpty ? null : _repeatRule,
      );

      final provider = context.read<TaskProvider>();

      if (widget.task == null) {
        await provider.addTask(task, subs: _subtasks);
      } else {
        await provider.updateTask(task, subs: _subtasks);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF0F4FF),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF00BC8C)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.task == null ? 'Create New Task' : 'Edit Task',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.task != null)
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Colors.white),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Delete Task?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && mounted) {
                            await context.read<TaskProvider>().deleteTask(widget.task!.id!);
                            Navigator.pop(context);
                          }
                        },
                      ),
                  ],
                ),
              ),
              
              // Form Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Saving your task...',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Task Title
                              _buildSectionLabel('Task Title', Icons.title_rounded, context),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _titleController,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'Enter task title',
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6C63FF),
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFF6C63FF)),
                                ),
                                validator: (v) => v?.trim().isEmpty == true ? 'Please enter a title' : null,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Description
                              _buildSectionLabel('Description', Icons.description_rounded, context),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _descController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Add a description (optional)',
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6C63FF),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Due Date
                              _buildSectionLabel('Due Date & Time', Icons.calendar_today_rounded, context),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: _pickDateTime,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.access_time_rounded,
                                          color: Color(0xFF6C63FF),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Due Date',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.white60 : Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _dueDate == null
                                                  ? 'Not set'
                                                  : DateFormat('MMM d, yyyy • h:mm a').format(_dueDate!),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Priority
                              _buildSectionLabel('Priority Level', Icons.flag_rounded, context),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildPriorityChip('Low', Colors.green, isDark),
                                  const SizedBox(width: 12),
                                  _buildPriorityChip('Medium', Colors.orange, isDark),
                                  const SizedBox(width: 12),
                                  _buildPriorityChip('High', Colors.red, isDark),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Repeat Rule
                              _buildSectionLabel('Repeat Task', Icons.autorenew_rounded, context),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _repeatRule.isEmpty ? null : _repeatRule,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.repeat_rounded, color: Color(0xFF00BC8C)),
                                  ),
                                  hint: Text(
                                    'Select repeat frequency',
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : Colors.grey[600],
                                    ),
                                  ),
                                  dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text(
                                        'No Repeat',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Daily',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.today, size: 18, color: Color(0xFF6C63FF)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Daily',
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Weekly',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.view_week, size: 18, color: Color(0xFF00BC8C)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Weekly',
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Monthly',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_month, size: 18, color: Color(0xFFFFB347)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Monthly',
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _repeatRule = value ?? '';
                                    });
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Subtasks
                              _buildSectionLabel('Subtasks', Icons.checklist_rounded, context),
                              const SizedBox(height: 8),
                              Text(
                                'Break this task into smaller steps',
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _subtaskController,
                                      decoration: InputDecoration(
                                        hintText: 'Add a subtask...',
                                        filled: true,
                                        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF6C63FF),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      onFieldSubmitted: (_) => _addSubtask(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6C63FF), Color(0xFF00BC8C)],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add_rounded),
                                      color: Colors.white,
                                      onPressed: _addSubtask,
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (_subtasks.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                ..._subtasks.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final subtask = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Checkbox(
                                        value: subtask.isDone,
                                        onChanged: (v) {
                                          setState(() {
                                            _subtasks[index] = subtask.copyWith(isDone: v ?? false);
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      title: Text(
                                        subtask.title,
                                        style: TextStyle(
                                          decoration: subtask.isDone ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                        onPressed: () => _removeSubtask(index),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              
                              const SizedBox(height: 32),
                              
                              // Save Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6C63FF), Color(0xFF00BC8C)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C63FF).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _saveTask,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save Task',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String priority, Color color, bool isDark) {
    final isSelected = _priority == priority;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priority = priority),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                priority,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
