import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _serviceId = 'service_3y1nds6';
  static const String _publicKey = 'y11o81eLmH4g2vMz9';

  // IMPORTANT: use a NEW regenerated private key (revoke old one)
  static const String _privateKey = 'PM7173zA70l-whTwREr8p';

  static const String _templateWelcome = 'template_ohi2wqp';
  static const String _templateAssigned = 'template_fynocnx';
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
        'user_id': _publicKey,
        'accessToken': _privateKey, // required in strict mode
        'template_params': params,
      };

      final res = await http.post(
        Uri.parse(_emailJsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('📨 EmailJS status: ${res.statusCode}');
      debugPrint('📨 EmailJS response: ${res.body}');

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

  Future<bool> sendNewUserCredentials({
    required String userEmail,
    required String userName,
    required String password,
    required String role,
  }) async {
    return _sendTemplate(
      templateId: _templateWelcome,
      params: {
        'to_email': userEmail, // add if template To uses {{to_email}}
        'user_name': userName,
        'user_email': userEmail,
        'password': password,
        'role': role,
      },
    );
  }

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
        'to_email': userEmail,
        'user_name': userName,
        'task_title': taskTitle,
        'task_description': taskDescription,
        'assigned_by_name': assignedByName,
      },
    );
  }

  Future<bool> sendTaskCompletedNotification({
    required String adminEmail,
    required String adminName,
    required String taskTitle,
    required String userName,
  }) async {
    return _sendTemplate(
      templateId: _templateCompleted,
      params: {
        'to_email': adminEmail,
        'admin_name': adminName,
        'user_name': userName,
        'task_title': taskTitle,
      },
    );
  }
}
