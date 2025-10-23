import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple client-side sender for SMS (Twilio) and Email (SendGrid).
/// In production, proxy these through **your backend** so API keys are not in the app.
class OtpSender {
  /// Send OTP SMS via Twilio REST API
  static Future<void> sendOtpSmsTwilio({
    required String accountSid,
    required String authToken,
    required String fromNumber, // e.g. "+15005550006" (Twilio number)
    required String toNumber,   // e.g. "+923001234567"
    required String otp,
  }) async {
    final uri = Uri.parse(
      'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json',
    );

    final authHeader =
        'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}';

    final res = await http.post(
      uri,
      headers: {'Authorization': authHeader},
      body: {
        'From': fromNumber,
        'To': toNumber,
        'Body': 'Your POS OTP is $otp (valid 10 minutes).',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Twilio SMS failed: ${res.statusCode} - ${res.body}');
    }
  }

  /// Send OTP Email via SendGrid
  static Future<void> sendOtpEmailSendgrid({
    required String apiKey,            // keep on backend ideally
    required String toEmail,
    required String fromEmail,         // verified sender in SendGrid
    required String otp,
  }) async {
    final uri = Uri.parse('https://api.sendgrid.com/v3/mail/send');
    final payload = {
      "personalizations": [
        {
          "to": [
            {"email": toEmail}
          ],
          "subject": "Your POS OTP"
        }
      ],
      "from": {"email": fromEmail},
      "content": [
        {
          "type": "text/plain",
          "value": "Your POS OTP is $otp (valid 10 minutes)."
        }
      ]
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('SendGrid email failed: ${res.statusCode} - ${res.body}');
    }
  }
}
