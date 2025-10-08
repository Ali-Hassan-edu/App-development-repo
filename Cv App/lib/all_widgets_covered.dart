import 'package:flutter/material.dart';

void main() => runApp(ProfileApp());

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String name = 'ALI hassan';
  final String email = 'waqaranjum@gmail.com';
  final String phone = '03211532010';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'ALI hassan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 4,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              Card(
                margin: EdgeInsets.all(20),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Profile Image
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 80,
                                                backgroundImage: AssetImage('images/123.jpeg'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(height: 25),

                    // Name
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 10),

                    // Title with Animated Text
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Fullstack Web & Android Developer',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Stats Row with Glass Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGlassStat('5+', 'Years\nExperience'),
                        _buildGlassStat('50+', 'Projects\nDelivered'),
                        _buildGlassStat('100%', 'Client\nSatisfaction'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

              // Skills Section - Horizontal Cards
              _buildSectionHeader('Core Technologies', Icons.code),
              Container(
                height: 120,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSkillChip('Flutter', Colors.blue, Icons.flutter_dash),
                    _buildSkillChip('React', Colors.cyan, Icons.code),
                    _buildSkillChip('Node.js', Colors.green, Icons.developer_mode),
                    _buildSkillChip('Python', Colors.yellow.shade700, Icons.language),
                    _buildSkillChip('Firebase', Colors.orange, Icons.cloud),
                    _buildSkillChip('MongoDB', Colors.green.shade600, Icons.storage),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Contact Section - Modern Cards
              _buildSectionHeader('Get In Touch', Icons.contact_mail),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModernContactCard(
                        Icons.email,
                        email,
                        'Email',
                        Colors.purpleAccent,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: _buildModernContactCard(
                        Icons.phone,
                        phone,
                        'Phone',
                        Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModernContactCard(
                        Icons.location_on,
                        'Lahore, Pakistan',
                        'Location',
                        Colors.greenAccent,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: _buildModernContactCard(
                        Icons.language,
                        'English, Urdu',
                        'Languages',
                        Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Experience Section - Timeline Style
              _buildSectionHeader('Experience Journey', Icons.work),
              _buildExperienceTimeline(),

              SizedBox(height: 30),

              // Education Section
              _buildSectionHeader('Education', Icons.school),
              _buildEducationTimeline(),

              SizedBox(height: 30),

              // Social Links - Floating Action Buttons Style
              _buildSectionHeader('Connect With Me', Icons.share),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFloatingSocialButton(Icons.facebook, Colors.blue.shade600),
                    _buildFloatingSocialButton(Icons.camera_alt, Colors.pink.shade400),
                    _buildFloatingSocialButton(Icons.link, Colors.teal.shade400),
                    _buildFloatingSocialButton(Icons.code, Colors.purple.shade400),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Education Section
              _buildSectionHeader('Education', Icons.school),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.amberAccent,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bachelor of Computer Science',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'University of Lahore',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '2015 - 2019 • GPA: 3.8/4.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Footer
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Built with ❤️ using Flutter',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '© 2025 ALI hassan. All rights reserved.',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }







  Widget _buildGlassStat(String number, String label) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.cyanAccent,
              size: 20,
            ),
          ),
          SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill, Color color, IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 15),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 10),
          Text(
            skill,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContactCard(IconData icon, String text, String label, Color accentColor) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
          color: accentColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTimeline() {
    List<Map<String, dynamic>> experiences = [
      {
        'title': 'Senior Flutter Developer',
        'company': 'Tech Solutions Inc.',
        'period': '2022 - Present',
        'description': 'Leading mobile app development projects and mentoring junior developers.',
        'color': Colors.blueAccent,
        'icon': Icons.work,
      },
      {
        'title': 'Fullstack Web Developer',
        'company': 'Digital Agency',
        'period': '2020 - 2022',
        'description': 'Developed responsive web applications using React and Node.js.',
        'color': Colors.greenAccent,
        'icon': Icons.web,
      },
      {
        'title': 'Mobile App Developer',
        'company': 'Startup Hub',
        'period': '2019 - 2020',
        'description': 'Built cross-platform mobile applications for various clients.',
        'color': Colors.orangeAccent,
        'icon': Icons.phone_android,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: experiences.map((exp) => _buildTimelineItem(exp)).toList(),
      ),
    );
  }

  Widget _buildEducationTimeline() {
    List<Map<String, dynamic>> educations = [
      {
        'title': 'Bachelor of Science in Computer Science',
        'institution': 'University of Lahore',
        'period': '2016 - 2020',
        'description': 'Focused on software development, algorithms, and data structures.',
        'color': Colors.blueAccent,
        'icon': Icons.school,
      },
      {
        'title': 'Intermediate in Pre-Engineering',
        'institution': 'Punjab College',
        'period': '2014 - 2016',
        'description': 'Mathematics, Physics, and Computer Science foundation.',
        'color': Colors.greenAccent,
        'icon': Icons.book,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: educations.map((edu) => _buildTimelineItem(edu)).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> experience) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: experience['color'].withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                experience['icon'],
                color: experience['color'],
                size: 20,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    experience['company'],
                    style: TextStyle(
                      fontSize: 16,
                      color: experience['color'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    experience['period'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    experience['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
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

  Widget _buildFloatingSocialButton(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class AnimatedContactCard extends StatefulWidget {
  final IconData icon;
  final String text;
  final String label;

  const AnimatedContactCard({required this.icon, required this.text, required this.label});

  @override
  _AnimatedContactCardState createState() => _AnimatedContactCardState();
}

class _AnimatedContactCardState extends State<AnimatedContactCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: InkWell(
              onTap: () {
                _controller.forward().then((_) => _controller.reverse());
                // Add contact action here (copy to clipboard, open dialer, etc.)
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 28),
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedSocialButton extends StatefulWidget {
  final IconData icon;
  final Color color;

  const AnimatedSocialButton({required this.icon, required this.color});

  @override
  _AnimatedSocialButtonState createState() => _AnimatedSocialButtonState();
}

class _AnimatedSocialButtonState extends State<AnimatedSocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: InkWell(
              onTap: () {
                _controller.forward().then((_) => _controller.reverse());
                // Add your social media action here
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedListItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;

  const AnimatedListItem({required this.title, required this.icon, required this.color});

  @override
  _AnimatedListItemState createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: widget.color.withOpacity(0.05),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: () {
              _controller.forward().then((_) => _controller.reverse());
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: widget.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.color.withOpacity(0.2), widget.color.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: widget.color.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}