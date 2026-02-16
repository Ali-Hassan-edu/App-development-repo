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
  ConsumerState<TaskAssignmentScreen> createState() =>
      _TaskAssignmentScreenState();
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
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
    final usersAsync = ref.watch(
      allUsersProvider,
    ); // Changed to allUsersProvider for consistency

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'TASK ASSIGNMENT',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: const Color(0xFF0D47A1),
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
                  // Animated header
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
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
                              Text(
                                'Create New Task',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Assign tasks to team members',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionLabel(context, 'Task Details'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: _buildInputDecoration(
                      context,
                      'Task Title',
                      Icons.title,
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    style: const TextStyle(color: Color(0xFF0D47A1)),
                    decoration: _buildInputDecoration(
                      context,
                      'Description',
                      Icons.description_outlined,
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionLabel(context, 'Assignment & Priority'),
                  const SizedBox(height: 12),
                  usersAsync.when(
                    data: (users) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: DropdownButtonFormField<UserEntity>(
                        value: _selectedUser,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: _buildInputDecoration(
                          context,
                          'Assign To',
                          Icons.person_outline,
                        ),
                        items: users
                            .where((u) => u.role == UserRole.user)
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(
                                  u.name,
                                  style: const TextStyle(
                                    color: Color(0xFF0D47A1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedUser = v),
                        validator: (v) =>
                            v == null ? 'Please select a user' : null,
                      ),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error loading users: $e'),
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: _buildInputDecoration(
                        context,
                        'Priority Level',
                        Icons.priority_high,
                      ),
                      items: ['Low', 'Medium', 'High']
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: const TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPriority = v!),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionLabel(context, 'Timeline'),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Color(0xFF0D47A1),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Select deadline',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF0D47A1),
                          ),
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
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(
                          0xFF0D47A1,
                        ).withValues(alpha: 0.4),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Assign Task',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D47A1),
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF0D47A1),
        fontWeight: FontWeight.w900,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0D47A1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0D47A1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0D47A1)),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Generate a proper UUID for the task
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

        // Create the task
        await ref.read(taskRepositoryProvider).createTask(task);

        // Send notifications
        try {
          final currentUser = ref.read(authStateProvider).user;

          // Send email notification
          await ref
              .read(emailServiceProvider)
              .sendTaskAssignedNotification(
                userEmail: _selectedUser!.email,
                userName: _selectedUser!.name,
                taskTitle: task.title,
                taskDescription: task.description,
                assignedById: currentUser?.id ?? '',
                assignedByName: currentUser?.name ?? 'Admin',
              );

          // Send in-app notification
          final notificationServiceNotifier = ref.read(
            notificationServiceProvider.notifier,
          );

          final notification = NotificationModel(
            id: const Uuid().v4(),
            title: 'New Task Assigned',
            message:
                'You have been assigned a new task: "${task.title}" by ${currentUser?.name ?? 'Admin'}',
            timestamp: DateTime.now(),
            type: NotificationType.taskAssigned,
            userId: _selectedUser!.id,
          );

          notificationServiceNotifier.addNotification(notification);
        } catch (e) {
          print('Error sending notifications: $e');
        }

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Assignment Successful'),
              content: Text(
                'The task "${task.title}" has been successfully assigned to ${task.assignedToName}.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Reset form
                    _titleController.clear();
                    _descController.clear();
                    setState(() {
                      _selectedUser = null;
                      _selectedPriority = 'Medium';
                      _selectedDate = DateTime.now().add(
                        const Duration(days: 1),
                      );
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
}
