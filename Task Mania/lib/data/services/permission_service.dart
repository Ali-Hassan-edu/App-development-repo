import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PermissionService {
  static const MethodChannel _channel = MethodChannel('com.taskmania.permissions');

  /// Request battery optimization exemption to ensure notifications work when app is killed
  static Future<void> requestBatteryOptimization() async {
    try {
      await _channel.invokeMethod('requestBatteryOptimization');
      debugPrint('✅ Battery optimization permission requested');
    } catch (e) {
      debugPrint('❌ Failed to request battery optimization: $e');
    }
  }

  /// Request exact alarm permission for Android 12+
  static Future<void> requestExactAlarmPermission() async {
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
      debugPrint('✅ Exact alarm permission requested');
    } catch (e) {
      debugPrint('❌ Failed to request exact alarm permission: $e');
    }
  }

  /// Check if the app can schedule exact alarms
  static Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ Failed to check exact alarm permission: $e');
      return false;
    }
  }

  /// Request all necessary permissions for background notifications
  static Future<void> requestAllPermissions() async {
    debugPrint('📱 Requesting all permissions for persistent notifications...');
    
    await requestBatteryOptimization();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await requestExactAlarmPermission();
    await Future.delayed(const Duration(milliseconds: 500));
    
    final canSchedule = await canScheduleExactAlarms();
    if (canSchedule) {
      debugPrint('✅ App can schedule exact alarms - notifications will work even when app is killed');
    } else {
      debugPrint('⚠️ App cannot schedule exact alarms yet - user may need to grant permission');
    }
  }
}
