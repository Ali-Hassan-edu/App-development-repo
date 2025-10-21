import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gpa_calculator.dart';
import 'cgpa_calculator.dart';
import 'grade_predictor.dart';
import 'models/semester.dart';
import 'models/subject.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6366F1);
    const Color secondaryColor = Color(0xFF8B5CF6);
    const Color accentColor = Color(0xFF06D6A0);
    const Color backgroundColor = Color(0xFF0F172A);
    const Color surfaceColor = Color(0xFF1E293B);

    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor.withOpacity(0.8),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryColor.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        iconTheme: MaterialStateProperty.all(
          const IconThemeData(color: Colors.white70),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Pro Suite',
      theme: theme,
      home: const HomeScreenWrapper(),
    );
  }
}

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  bool _loading = true;
  List<Semester> _savedSemesters = [];

  @override
  void initState() {
    super.initState();
    _loadSavedSemesters();
  }

  Future<void> _loadSavedSemesters() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('saved_semesters') ?? [];
    final loaded = data.map((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return Semester.fromJson(map);
      } catch (_) {
        return null;
      }
    }).whereType<Semester>().toList();

    setState(() {
      _savedSemesters = loaded;
      _loading = false;
    });
  }

  Future<void> _saveSemesters() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _savedSemesters.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('saved_semesters', data);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading Academic Data...',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return HomeScreen(
      initialSemesters: _savedSemesters,
      onSemestersUpdate: _saveSemesters,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<Semester> initialSemesters;
  final VoidCallback onSemestersUpdate;

  const HomeScreen({
    super.key,
    required this.initialSemesters,
    required this.onSemestersUpdate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  late List<Semester> savedSemesters;

  @override
  void initState() {
    super.initState();
    savedSemesters = List.from(widget.initialSemesters);
  }

  void addSemester(Semester sem) {
    setState(() {
      savedSemesters.add(sem);
      widget.onSemestersUpdate();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Semester GPA ${sem.gpa.toStringAsFixed(2)} saved!'),
        backgroundColor: const Color(0xFF06D6A0),
      ),
    );
  }

  void addManualSemester(Semester sem) {
    setState(() {
      savedSemesters.add(sem);
      widget.onSemestersUpdate();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Manual semester added: GPA ${sem.gpa.toStringAsFixed(2)}'),
        backgroundColor: const Color(0xFF06D6A0),
      ),
    );
  }

  void removeSemester(int index) {
    setState(() {
      savedSemesters.removeAt(index);
      widget.onSemestersUpdate();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semester removed'),
        backgroundColor: Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      GPACalculatorScreen(onSaveSemester: addSemester),
      CgpaCalculatorScreen(
        savedSemesters: savedSemesters,
        onRemoveSemester: removeSemester,
        onAddManualSemester: addManualSemester,
      ),
      const GradePredictorScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Academic Pro Suite',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (selectedIndex == 1 && savedSemesters.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Semesters'),
                    content: const Text('Are you sure you want to delete all saved semesters?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            savedSemesters.clear();
                            widget.onSemestersUpdate();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Delete All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: screens[selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) => setState(() => selectedIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate),
              label: 'GPA Calculator',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'CGPA Tracker',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Grade Predictor',
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.8),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '📧 raoali2438@gmail.com | 📞 03270196155',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Developed by Rao Ali',
              style: GoogleFonts.inter(
                color: const Color(0xFF8B5CF6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}