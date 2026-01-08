import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'receipt_share_service.dart';

class MessageLauncher {
  static Future<bool> openWhatsApp({
    required String phoneWithPlus,
    required String message,
  }) async {
    final digits = ReceiptShareService.toWhatsAppDigits(phoneWithPlus);
    final url = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      return launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<bool> openSms({
    required String phoneWithPlus,
    required String message,
  }) async {
    final sep = Platform.isIOS ? '&' : '?';
    final url = Uri.parse('sms:$phoneWithPlus${sep}body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      return launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
