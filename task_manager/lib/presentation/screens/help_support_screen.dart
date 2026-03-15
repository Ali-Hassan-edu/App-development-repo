import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const primaryColor = Color(0xFF0D47A1);
  static const supportEmail = 'taskmanager637@gmail.com';

  final List<_FAQItem> _faqs = [
    _FAQItem('How do I get notifications?', 'You will receive in-app notifications automatically when tasks are assigned to you or completed. Make sure notifications are enabled in your device settings.'),
    _FAQItem('Why am I not receiving email notifications?', 'Check your spam/junk folder. Emails are sent from taskmanager637@gmail.com when tasks are assigned to you and when tasks are completed. Contact support if the issue persists.'),
    _FAQItem('How do I update my profile name?', 'Go to Settings → Edit Profile → enter your new name and tap Save. The change applies immediately across the app.'),
    _FAQItem('Can I use the app offline?', 'Basic viewing may be available offline. Creating tasks, updating statuses, and notifications require an active internet connection.'),
    _FAQItem('How do I reset my password?', 'On the login screen, tap "Forgot Password" and enter your registered email. You will receive a password reset link.'),
    _FAQItem('How are tasks assigned?', 'Only admin users can assign tasks. Admins use the Task Assignment screen to create tasks and select a team member. The assigned user is notified immediately via in-app notification and email.'),
    _FAQItem('What does each task status mean?', '"Pending" – task not yet started.\n"In Progress" – task is actively being worked on.\n"Completed" – task is finished. The admin is notified upon completion.'),
    _FAQItem('How do I mark a task as complete?', 'Open the My Tasks screen, find your task, and tap "Mark Done". A confirmation dialog will appear. Confirm to mark it complete and notify the admin.'),
    _FAQItem('Who can add new users?', 'Only administrators can add new users. The new user receives their login credentials via email automatically when their account is created.'),
  ];

  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner — no quick action buttons (removed live chat, tutorials, report bug)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text('How can we help?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text('Browse the FAQs below or email us directly for support.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // FAQ section
            const Text('FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: primaryColor, letterSpacing: 1.4)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: _faqs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final faq = entry.value;
                  final isLast = i == _faqs.length - 1;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() {
                          if (_expanded.contains(i)) { _expanded.remove(i); } else { _expanded.add(i); }
                        }),
                        borderRadius: BorderRadius.vertical(
                          top: i == 0 ? const Radius.circular(18) : Radius.zero,
                          bottom: isLast && !_expanded.contains(i) ? const Radius.circular(18) : Radius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.help_outline, color: primaryColor, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), fontSize: 14))),
                              Icon(_expanded.contains(i) ? Icons.expand_less : Icons.expand_more, color: primaryColor),
                            ],
                          ),
                        ),
                      ),
                      if (_expanded.contains(i))
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(52, 0, 16, 16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.03),
                            borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(18)) : BorderRadius.zero,
                          ),
                          child: Text(faq.answer, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.6)),
                        ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // Contact information — only email, support hours
            const Text('CONTACT INFORMATION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: primaryColor, letterSpacing: 1.4)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  // Email support with YOUR email
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.email_outlined, color: primaryColor, size: 22),
                    ),
                    title: const Text('Email Support', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), fontSize: 15)),
                    subtitle: const Text(supportEmail, style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: 1),
                  // Support hours only
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.schedule, color: primaryColor, size: 22),
                    ),
                    title: Text('Response Time', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), fontSize: 15)),
                    subtitle: Text('We reply within 24 hours on business days', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Center(
              child: Text('Version 1.0.0 • Task Manager',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FAQItem {
  final String question;
  final String answer;
  _FAQItem(this.question, this.answer);
}
