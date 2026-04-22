import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreens extends StatefulWidget {
  final VoidCallback onFinish;

  const IntroScreens({super.key, required this.onFinish});

  @override
  State<IntroScreens> createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  Future<void> _completeIntro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch', false);
      debugPrint('✅ first_launch set to false in SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error saving first_launch: $e');
    }

    if (mounted) {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D47A1),
              const Color(0xFF1565C0),
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildScreen1(context),
                _buildScreen2(context),
              ],
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage == 0
                      ? TextButton(
                          onPressed: _completeIntro,
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : const SizedBox(width: 60),
                  Row(
                    children: List.generate(
                      2,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  _currentPage == 1
                      ? ElevatedButton(
                          onPressed: _completeIntro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0D47A1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black26,
                          ),
                          child: Text('Get Started',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold)),
                        )
                      : TextButton(
                          onPressed: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Next',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen1(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.admin_panel_settings,
              size: 120, color: Colors.white),
          const SizedBox(height: 40),
          Text(
            'Admin Setup',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Create an admin account to manage your team. You can continue with Google or email.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () async {
              await _completeIntro();
              if (mounted) {
                Navigator.pushNamed(context, '/admin-signup');
              }
            },
            icon: const Icon(Icons.person_add_alt_1_rounded,
                color: Color(0xFF0D47A1)),
            label: Text('Create Admin Account',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D47A1))),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch_rounded,
              size: 120, color: Colors.white),
          const SizedBox(height: 40),
          Text(
            'App Workflow',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStep(context, '1', 'Admin creates an account.'),
                const SizedBox(height: 12),
                _buildStep(
                    context, '2', 'Admin adds multiple Users to the team.'),
                const SizedBox(height: 12),
                _buildStep(context, '3', 'Admin assigns tasks to Users.'),
                const SizedBox(height: 12),
                _buildStep(context, '4',
                    'Users complete tasks and Admin tracks progress!'),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D47A1),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
