import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  static const String _projectRef = 'xzbljwikiygxxozijqfy';
  static const String _anonKey =
      'sb_publishable_u5r9zigh79peRXHp0Wuoig_E2WTotB0';

  static String get _url =>
      'https://$_projectRef.supabase.co/functions/v1/send-email';

  Future<bool> _send({
    required String to,
    required String subject,
    required String htmlBody,
  }) async {
    try {
      final token =
          Supabase.instance.client.auth.currentSession?.accessToken ?? _anonKey;

      debugPrint('📧 Email → $to | $subject');

      final res = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'html': htmlBody,
        }),
      );

      if (res.statusCode == 200) {
        debugPrint('✅ Email sent to $to');
        return true;
      }

      debugPrint('❌ Email failed [${res.statusCode}]: ${res.body}');
      return false;
    } catch (e) {
      debugPrint('❌ Email error: $e');
      return false;
    }
  }

  Future<void> sendNewUserCredentials({
    required String userEmail,
    required String userName,
    required String password,
    required String role,
  }) async {
    await _send(
      to: userEmail,
      subject: 'Welcome to Task Manager — Your Login Credentials',
      htmlBody: _credentialsHtml(
        userName: userName,
        userEmail: userEmail,
        password: password,
        role: role,
      ),
    );
  }

  Future<void> sendTaskAssignedNotification({
    required String userEmail,
    required String userName,
    required String taskTitle,
    required String taskDescription,
    required String assignedByName,
  }) async {
    await _send(
      to: userEmail,
      subject: 'New Task Assigned: $taskTitle',
      htmlBody: _taskAssignedHtml(
        userName: userName,
        taskTitle: taskTitle,
        taskDescription: taskDescription,
        assignedByName: assignedByName,
      ),
    );
  }

  Future<void> sendTaskCompletedNotification({
    required String adminEmail,
    required String adminName,
    required String taskTitle,
    required String userName,
  }) async {
    await _send(
      to: adminEmail,
      subject: 'Task Completed: $taskTitle',
      htmlBody: _taskCompletedHtml(
        adminName: adminName,
        taskTitle: taskTitle,
        userName: userName,
      ),
    );
  }

  static String _credentialsHtml({
    required String userName,
    required String userEmail,
    required String password,
    required String role,
  }) =>
      '''<!DOCTYPE html><html><body style="font-family:Arial,sans-serif;background:#f4f4f4;padding:30px;">
<div style="max-width:520px;margin:auto;background:#fff;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,.08);">
  <h2 style="color:#0D47A1;margin-top:0">Welcome to Task Manager 👋</h2>
  <p style="color:#333">Hello <strong>$userName</strong>,</p>
  <p style="color:#333">Your account has been created. Here are your login credentials:</p>
  <table style="width:100%;border-collapse:collapse;margin:20px 0">
    <tr><td style="padding:10px;background:#f0f4ff;font-weight:bold;color:#555;border-radius:8px 8px 0 0">Email</td>
        <td style="padding:10px;background:#f0f4ff;color:#0D47A1;border-radius:8px 8px 0 0">$userEmail</td></tr>
    <tr><td style="padding:10px;background:#e8f0fe;font-weight:bold;color:#555">Password</td>
        <td style="padding:10px;background:#e8f0fe;color:#0D47A1">$password</td></tr>
    <tr><td style="padding:10px;background:#f0f4ff;font-weight:bold;color:#555;border-radius:0 0 8px 8px">Role</td>
        <td style="padding:10px;background:#f0f4ff;color:#0D47A1;border-radius:0 0 8px 8px">$role</td></tr>
  </table>
  <p style="color:#888;font-size:13px">Please change your password after your first login.</p>
  <hr style="border:none;border-top:1px solid #eee;margin:24px 0">
  <p style="color:#aaa;font-size:12px;text-align:center">Task Manager App</p>
</div></body></html>''';

  static String _taskAssignedHtml({
    required String userName,
    required String taskTitle,
    required String taskDescription,
    required String assignedByName,
  }) =>
      '''<!DOCTYPE html><html><body style="font-family:Arial,sans-serif;background:#f4f4f4;padding:30px;">
<div style="max-width:520px;margin:auto;background:#fff;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,.08);">
  <h2 style="color:#0D47A1;margin-top:0">📋 New Task Assigned</h2>
  <p style="color:#333">Hello <strong>$userName</strong>,</p>
  <p style="color:#333"><strong>$assignedByName</strong> has assigned you a new task:</p>
  <div style="background:#f0f4ff;border-left:4px solid #0D47A1;border-radius:8px;padding:16px;margin:20px 0">
    <p style="margin:0 0 8px;font-weight:bold;color:#0D47A1;font-size:16px">$taskTitle</p>
    <p style="margin:0;color:#555;font-size:14px">$taskDescription</p>
  </div>
  <p style="color:#555;font-size:14px">Log in to the app to view details and update the task status.</p>
  <hr style="border:none;border-top:1px solid #eee;margin:24px 0">
  <p style="color:#aaa;font-size:12px;text-align:center">Task Manager App</p>
</div></body></html>''';

  static String _taskCompletedHtml({
    required String adminName,
    required String taskTitle,
    required String userName,
  }) =>
      '''<!DOCTYPE html><html><body style="font-family:Arial,sans-serif;background:#f4f4f4;padding:30px;">
<div style="max-width:520px;margin:auto;background:#fff;border-radius:12px;padding:32px;box-shadow:0 2px 12px rgba(0,0,0,.08);">
  <h2 style="color:#2E7D32;margin-top:0">✅ Task Completed</h2>
  <p style="color:#333">Hello <strong>$adminName</strong>,</p>
  <p style="color:#333"><strong>$userName</strong> has marked this task as complete:</p>
  <div style="background:#f0fff4;border-left:4px solid #2E7D32;border-radius:8px;padding:16px;margin:20px 0">
    <p style="margin:0;font-weight:bold;color:#2E7D32;font-size:16px">$taskTitle</p>
  </div>
  <hr style="border:none;border-top:1px solid #eee;margin:24px 0">
  <p style="color:#aaa;font-size:12px;text-align:center">Task Manager App</p>
</div></body></html>''';
}
