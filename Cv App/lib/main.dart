import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(ProfileApp());

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String name = 'ALI HASSAN';
  final String email = 'raoali2438@gmail.com';
  final String phone = '03270196156';
  final String tagline = 'Fullstack Web & Android App Developer';

  // Multiple profile images
  final List<String> profileImages = [
    'images/123.jpeg',
    'images/1234.jpeg',
    'images/12345.jpeg',
  ];
  int currentImageIndex = 0;

  int selectedTheme = 0; // 0: default, 1: gradient, 2: color scheme

  final List<Color> themeColors = [Colors.indigo, Colors.deepPurple, Colors.teal];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional CV'),
        backgroundColor: themeColors[selectedTheme],
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: _getBackgroundDecoration(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
            child: Column(
              children: [
                // Theme Selection Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGradientButton('Classic', [Colors.blue.shade400, Colors.indigo.shade400], 0),
                    _buildGradientButton('Modern', [Colors.purple.shade400, Colors.pink.shade400], 1),
                    _buildGradientButton('Creative', [Colors.teal.shade400, Colors.green.shade400], 2),
                  ],
                ),
                SizedBox(height: 24),
                // Profile Header Card
                _buildProfileCard(),
                SizedBox(height: 24),
                // About Section Card
                _buildAboutCard(),
                SizedBox(height: 24),
                // Skills Section Card
                _buildSkillsCard(),
                SizedBox(height: 24),
                // Experience Section Card
                _buildExperienceCard(),
                SizedBox(height: 24),
                // Projects Section Card
                _buildProjectsCard(),
                SizedBox(height: 24),
                // Contact Section Card
                _buildContactCard(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => _showImagePopup(context),
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < 0) {
                      // Swipe left (next)
                      setState(() {
                        currentImageIndex = (currentImageIndex + 1) % profileImages.length;
                      });
                    } else if (details.primaryVelocity! > 0) {
                      // Swipe right (back)
                      setState(() {
                        currentImageIndex = (currentImageIndex - 1 + profileImages.length) % profileImages.length;
                      });
                    }
                  }
                },
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Hero(
                    tag: 'profileImage',
                    key: ValueKey(profileImages[currentImageIndex]),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: Image.asset(
                          profileImages[currentImageIndex],
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Back arrow button
              if (profileImages.length > 1)
                Positioned(
                  left: -40,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: themeColors[selectedTheme], size: 28),
                    onPressed: () {
                      setState(() {
                        currentImageIndex = (currentImageIndex - 1 + profileImages.length) % profileImages.length;
                      });
                    },
                  ),
                ),
              // Next arrow button
              if (profileImages.length > 1)
                Positioned(
                  right: -40,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: themeColors[selectedTheme], size: 28),
                    onPressed: () {
                      setState(() {
                        currentImageIndex = (currentImageIndex + 1) % profileImages.length;
                      });
                    },
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                mini: true,
                backgroundColor: themeColors[selectedTheme],
                onPressed: () {
                  setState(() {
                    currentImageIndex = (currentImageIndex - 1 + profileImages.length) % profileImages.length;
                  });
                },
                child: Icon(Icons.arrow_back),
                tooltip: 'Previous Image',
              ),
              SizedBox(width: 20),
              FloatingActionButton(
                mini: true,
                backgroundColor: themeColors[selectedTheme],
                onPressed: () {
                  setState(() {
                    currentImageIndex = (currentImageIndex + 1) % profileImages.length;
                  });
                },
                child: Icon(Icons.arrow_forward),
                tooltip: 'Next Image',
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(profileImages.length, (index) => GestureDetector(
              onTap: () {
                setState(() {
                  currentImageIndex = index;
                });
                _showImagePopup(context);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentImageIndex == index ? themeColors[selectedTheme] : Colors.grey[300],
                ),
              ),
            )),
          ),
          SizedBox(height: 15),
          Text(
            name,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          SizedBox(height: 5),
          Text(
            tagline,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  void _showImagePopup(BuildContext context) {
    int localIndex = currentImageIndex;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    setState(() {
                      if (details.primaryVelocity! < 0) {
                        // Swipe left (next)
                        localIndex = (localIndex + 1) % profileImages.length;
                      } else if (details.primaryVelocity! > 0) {
                        // Swipe right (back)
                        localIndex = (localIndex - 1 + profileImages.length) % profileImages.length;
                      }
                    });
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: 'popupImage',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            profileImages[localIndex],
                            fit: BoxFit.cover,
                            width: 350,
                            height: 350,
                          ),
                        ),
                      ),
                    ),
                    if (profileImages.length > 1) ...[
                      // Back arrow button
                      Positioned(
                        left: 10,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 40),
                          onPressed: () {
                            setState(() {
                              localIndex = (localIndex - 1 + profileImages.length) % profileImages.length;
                            });
                          },
                        ),
                      ),
                      // Next arrow button
                      Positioned(
                        right: 10,
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40),
                          onPressed: () {
                            setState(() {
                              localIndex = (localIndex + 1) % profileImages.length;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        currentImageIndex = localIndex;
      });
    });
  }

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Header
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'About Me',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          // Content with Image and Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image with Glow Effect
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('images/123.jpeg'),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passionate Developer & Innovator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'I am ALI hassan, a Fullstack Web and Android App Developer. I specialize in building beautiful, modern, and classic digital experiences. My expertise covers Flutter, Android, React, Node.js, and more. I am passionate about creating advanced, user-friendly solutions with elegant UI and powerful features.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 15),
                    // Skills Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSkillChip('Flutter'),
                        _buildSkillChip('React'),
                        _buildSkillChip('Node.js'),
                        _buildSkillChip('AI/ML'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    List<Map<String, dynamic>> skills = [
      {'name': 'AI Development', 'icon': Icons.psychology_alt, 'color': Colors.purple, 'level': 85},
      {'name': 'Flutter App Development', 'icon': Icons.flutter_dash, 'color': Colors.blue, 'level': 95},
      {'name': 'Web Development', 'icon': Icons.language, 'color': Colors.green, 'level': 90},
      {'name': 'Android Development', 'icon': Icons.android, 'color': Colors.teal, 'level': 88},
      {'name': 'React & Node.js', 'icon': Icons.developer_mode, 'color': Colors.indigo, 'level': 92},
      {'name': 'Python Development', 'icon': Icons.code, 'color': Colors.orange, 'level': 80},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(-20 * (1 - value), 0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(Icons.star, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Core Skills',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          // Skills Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.7,
            ),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 800 + (index * 100)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: _buildSkillItem(skills[index]),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkillItem(Map<String, dynamic> skill) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [skill['color'].withOpacity(0.1), skill['color'].withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: skill['color'].withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: skill['color'].withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with Glow
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [skill['color'], skill['color'].shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: skill['color'].withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              skill['icon'],
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: 12),
          Text(
            skill['name'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          // Progress Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: skill['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: skill['level'] / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [skill['color'], skill['color'].shade300],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${skill['level']}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: skill['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard() {
    List<Map<String, dynamic>> experiences = [
      {
        'title': 'Senior Flutter Developer',
        'company': 'Tech Solutions Inc.',
        'period': '2022 - Present',
        'description': 'Leading development of cross-platform mobile applications using Flutter. Implemented advanced UI/UX designs and integrated with REST APIs.',
        'color': Colors.blue,
      },
      {
        'title': 'AI Development Specialist',
        'company': 'Innovation Labs',
        'period': '2021 - 2022',
        'description': 'Developed AI-powered applications and machine learning models. Worked on natural language processing and computer vision projects.',
        'color': Colors.purple,
      },
      {
        'title': 'WordPress Developer',
        'company': 'Digital Agency',
        'period': '2020 - 2021',
        'description': 'Created custom WordPress themes and plugins. Managed e-commerce sites and optimized performance for better user experience.',
        'color': Colors.green,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(-20 * (1 - value), 0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.indigo],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(Icons.work, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Professional Experience',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          // Timeline Experience List
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: experiences.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 800 + (index * 150)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: _buildTimelineItem(experiences[index], index, experiences.length),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.cyan.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Header
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.code,
                          color: Colors.teal.shade700,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Projects',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          // Projects List
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              List<Map<String, String>> projects = [
                {
                  'title': 'E-Commerce App',
                  'description': 'Full-stack Flutter app with Firebase backend',
                  'tech': 'Flutter, Firebase, Dart'
                },
                {
                  'title': 'Task Management System',
                  'description': 'Web application for project management',
                  'tech': 'React, Node.js, MongoDB'
                },
                {
                  'title': 'Portfolio Website',
                  'description': 'Responsive personal website with animations',
                  'tech': 'HTML, CSS, JavaScript'
                },
              ];
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 800 + (index * 150)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              projects[index]['title']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              projects[index]['description']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Tech: ${projects[index]['tech']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.teal.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> experience, int index, int total) {
    bool isLast = index == total - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Indicator
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [experience['color'], experience['color'].shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: experience['color'].withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.work_outline,
                color: Colors.white,
                size: 12,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [experience['color'].withOpacity(0.5), experience['color'].withOpacity(0.2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 20),
        // Experience Card
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, experience['color'].withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: experience['color'].withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: experience['color'].withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: experience['color'],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  experience['company'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: experience['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    experience['period'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: experience['color'],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  experience['description'],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildContactCard() {
    List<Map<String, dynamic>> contacts = [
      {
        'icon': Icons.email,
        'label': 'Email',
        'value': email,
        'color': Colors.red,
        'gradient': [Colors.red.shade400, Colors.pink.shade400],
      },
      {
        'icon': Icons.phone,
        'label': 'Phone',
        'value': phone,
        'color': Colors.green,
        'gradient': [Colors.green.shade400, Colors.teal.shade400],
      },
      {
        'icon': Icons.location_on,
        'label': 'Location',
        'value': 'Lahore, Pakistan',
        'color': Colors.blue,
        'gradient': [Colors.blue.shade400, Colors.indigo.shade400],
      },
      {
        'icon': Icons.language,
        'label': 'Website',
        'value': 'waqaranjum.dev',
        'color': Colors.purple,
        'gradient': [Colors.purple.shade400, Colors.deepPurple.shade400],
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(-20 * (1 - value), 0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.cyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(Icons.contact_mail, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Get In Touch',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          // Contact Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.6,
            ),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 800 + (index * 100)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: _buildAdvancedContactItem(contacts[index]),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 20),
          // Social Links Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(Icons.facebook, Colors.blue),
              SizedBox(width: 15),
              _buildSocialButton(Icons.link, Colors.blue.shade700),
              SizedBox(width: 15),
              _buildSocialButton(Icons.camera_alt, Colors.pink),
              SizedBox(width: 15),
              _buildSocialButton(Icons.code, Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedContactItem(Map<String, dynamic> contact) {
    return GestureDetector(
      onTap: () {
        // Handle contact action (e.g., launch email, phone, etc.)
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: contact['gradient'],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: contact['color'].withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                contact['icon'],
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(height: 12),
            Text(
              contact['label'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              contact['value'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Handle social media action
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }



  Widget _buildGradientButton(String text, List<Color> colors, int themeIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTheme = themeIndex;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBackgroundDecoration() {
    switch (selectedTheme) {
      case 1: // Modern theme
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.pink.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 2: // Creative theme
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.green.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      default: // Classic theme
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ProfilePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade400, Colors.orange.shade400, Colors.amber.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: 2),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_cafe,
                        size: 100,
                        color: Colors.white,
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Welcome to My CV',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'ALI hassan',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Fullstack Web & Android App Developer',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}