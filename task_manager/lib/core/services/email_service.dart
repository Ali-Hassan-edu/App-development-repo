import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmailService {
  // =========================
  // EmailJS CONFIG
  // =========================
  // Replace these with your real IDs from EmailJS dashboard
  static const String _serviceId = 'service_s6bnh0f';
  static const String _publicKey = '5nFB7T3MwB5hV1hno';

  // Template IDs (you created these)
  static const String _templateWelcome = 'template_wbf4ej5';
  static const String _templateAssigned = 'template_or7z93n';
  static const String _templateCompleted = 'template_task_completed';

  static const String _emailJsUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  Future<bool> _sendTemplate({
    required String templateId,
    required Map<String, dynamic> params,
  }) async {
    try {
      final body = {
        'service_id': _serviceId,
        'template_id': templateId,
        'user_id': _publicKey, // EmailJS public key
        'template_params': params,
      };

      final res = await http.post(
        Uri.parse(_emailJsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        debugPrint('✅ Email sent via EmailJS (template: $templateId)');
        return true;
      } else {
        debugPrint('❌ EmailJS failed [${res.statusCode}] ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ EmailJS error: $e');
      return false;
    }
  }

  /// 1) Welcome credentials email
  Future<bool> sendNewUserCredentials({
    required String userEmail,
    required String userName,
    required String password,
    required String role,
  }) async {
    return _sendTemplate(
      templateId: _templateWelcome,
      params: {
        'user_name': userName,
        'user_email': userEmail,
        'password': password,
        'role': role,
      },
    );
  }

  /// 2) Task assigned email
  Future<bool> sendTaskAssignedNotification({
    required String userEmail,
    required String userName,
    required String taskTitle,
    required String taskDescription,
    required String assignedByName,
  }) async {
    return _sendTemplate(
      templateId: _templateAssigned,
      params: {
        // include this if your EmailJS "to email" comes from template variable
        'to_email': userEmail,
        'user_name': userName,
        'task_title': taskTitle,
        'task_description': taskDescription,
        'assigned_by_name': assignedByName,
      },
    );
  }

  /// 3) Task completed email (to admin)
  Future<bool> sendTaskCompletedNotification({
    required String adminEmail,
    required String adminName,
    required String taskTitle,
    required String userName,
  }) async {
    return _sendTemplate(
      templateId: _templateCompleted,
      params: {
        // include this if your EmailJS "to email" comes from template variable
        'to_email': adminEmail,
        'admin_name': adminName,
        'user_name': userName,
        'task_title': taskTitle,
      },
    );
  }
}
