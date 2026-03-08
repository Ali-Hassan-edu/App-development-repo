import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../providers/user_provider.dart';
import '../../providers/providers.dart';
import '../../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/user_entity.dart';

class TaskAssignmentScreen extends ConsumerStatefulWidget {
  const TaskAssignmentScreen({super.key});

  @override
  ConsumerState<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends ConsumerState<TaskAssignmentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedPriority = 'Medium';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  UserEntity? _selectedUser;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    const primaryColor = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'TASK ASSIGNMENT',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.assignment, color: Colors.white, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Create New Task', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                              SizedBox(height: 4),
                              Text('Assign tasks to team members', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionLabel('Task Details'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    decoration: _buildInputDecoration('Task Title', Icons.title),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    style: const TextStyle(color: primaryColor),
                    decoration: _buildInputDecoration('Description', Icons.description_outlined),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionLabel('Assignment & Priority'),
                  const SizedBox(height: 12),
                  usersAsync.when(
                    data: (users) {
                      final regularUsers = users.where((u) => u.role == UserRole.user).toList();
                      return DropdownButtonFormField<UserEntity>(
                        initialValue: _selectedUser,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        decoration: _buildInputDecoration('Assign To', Icons.person_outline),
                        items: regularUsers.map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u.name, style: const TextStyle(color: primaryColor)),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedUser = v),
                        validator: (v) => v == null ? 'Please select a user' : null,
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error loading users: $e'),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    decoration: _buildInputDecoration('Priority Level', Icons.priority_high),
                    items: ['Low', 'Medium', 'High'].map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p, style: const TextStyle(color: primaryColor)),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedPriority = v!),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionLabel('Timeline'),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, color: primaryColor),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Due Date', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Assign Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1), letterSpacing: 1.2),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    const primaryColor = Color(0xFF0D47A1);
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900),
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 2)),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0D47A1)),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final taskId = const Uuid().v4();
      final task = TaskEntity(
        id: taskId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDate,
        status: 'Pending',
        assignedToId: _selectedUser!.id,
        assignedToName: _selectedUser!.name,
        createdAt: DateTime.now(),
      );

      await ref.read(taskRepositoryProvider).createTask(task);

      final currentUser = ref.read(authStateProvider).user;

      // Send email notification to assigned user
      await ref.read(emailServiceProvider).sendTaskAssignedNotification(
        userEmail: _selectedUser!.email,
        userName: _selectedUser!.name,
        taskTitle: task.title,
        taskDescription: task.description,
        assignedById: currentUser?.id ?? '',
        assignedByName: currentUser?.name ?? 'Admin',
      );

      // Send in-app notification to assigned user
      ref.read(notificationServiceProvider.notifier).addNotification(
        NotificationModel(
          id: const Uuid().v4(),
          title: 'New Task Assigned',
          message: 'You have been assigned: "${task.title}" by ${currentUser?.name ?? 'Admin'}',
          timestamp: DateTime.now(),
          type: NotificationType.taskAssigned,
          userId: _selectedUser!.id,
        ),
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Task Assigned!'),
              ],
            ),
            content: Text(
              '"${task.title}" has been assigned to ${task.assignedToName}.\n\nThey will receive an email + in-app notification.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _titleController.clear();
                  _descController.clear();
                  setState(() {
                    _selectedUser = null;
                    _selectedPriority = 'Medium';
                    _selectedDate = DateTime.now().add(const Duration(days: 1));
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
