import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  final SupabaseClient _supabase;

  EmailService(this._supabase);

  Future<void> sendTaskAssignedNotification({
    required String userEmail,
    required String userName,
    required String taskTitle,
    required String taskDescription,
    required String assignedById,
    required String assignedByName,
  }) async {
    try {
      await _supabase.from('email_queue').insert({
        'to_email': userEmail,
        'subject': 'New Task Assigned: $taskTitle',
        'body': '''Dear $userName,

A new task has been assigned to you by $assignedByName:

Task: $taskTitle
Description: $taskDescription

Please log in to your Task Manager app to view and manage this task.

Best regards,
Task Manager Team''',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'email_type': 'task_assigned',
        'recipient_id': assignedById,
      });
    } catch (e) {
      // Log error but don't rethrow - notifications shouldn't break the app
      print('Error queuing task assignment email: $e');
    }
  }

  Future<void> sendTaskCompletedNotification({
    required String adminEmail,
    required String adminName,
    required String taskTitle,
    required String userName,
  }) async {
    try {
      await _supabase.from('email_queue').insert({
        'to_email': adminEmail,
        'subject': 'Task Completed: $taskTitle',
        'body': '''Dear $adminName,

The task "$taskTitle" assigned to $userName has been marked as completed.

Task: $taskTitle
Completed by: $userName

Please log in to your Task Manager app to review the task status.

Best regards,
Task Manager Team''',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'email_type': 'task_completed',
        'recipient_id': adminEmail,
      });
    } catch (e) {
      print('Error queuing task completion email: $e');
    }
  }

  Future<void> sendNewUserCredentials({
    required String userEmail,
    required String userName,
    required String password,
    required String role,
  }) async {
    try {
      await _supabase.from('email_queue').insert({
        'to_email': userEmail,
        'subject': 'Welcome to Task Manager - Your Account Credentials',
        'body': '''Dear $userName,

Welcome to Task Manager!

Your account has been created successfully. Here are your login credentials:

Email: $userEmail
Password: $password
Role: $role

Please log in to the Task Manager app using these credentials.

For security reasons, we recommend changing your password after your first login.

Best regards,
Task Manager Team''',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'email_type': 'new_user_credentials',
        'recipient_id': userEmail,
      });
    } catch (e) {
      print('Error queuing new user credentials email: $e');
    }
  }
}
