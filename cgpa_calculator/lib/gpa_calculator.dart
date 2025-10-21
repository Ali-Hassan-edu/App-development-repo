import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/subject.dart' hide Subject;
import 'models/semester.dart';

typedef OnSaveSemester = void Function(Semester semester);

class GPACalculatorScreen extends StatefulWidget {
  final OnSaveSemester onSaveSemester;

  const GPACalculatorScreen({super.key, required this.onSaveSemester});

  @override
  State<GPACalculatorScreen> createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Subject> _subjects = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  final TextEditingController _obtainedController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  double _gpa = 0.0;
  double _totalCredits = 0.0;

  void _addSubject() {
    if (_formKey.currentState!.validate()) {
      final newSubj = Subject(
        name: _nameController.text,
        credit: double.parse(_creditController.text),
        obtained: double.parse(_obtainedController.text),
        total: double.parse(_totalController.text),
      );
      setState(() {
        _subjects.add(newSubj);
        _nameController.clear();
        _creditController.clear();
        _obtainedController.clear();
        _totalController.clear();
      });
      _calculateGPA();
    }
  }

  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
    _calculateGPA();
  }

  double _getGradePoint(double percentage) {
    if (percentage >= 85) return 4.0;
    if (percentage >= 80) return 3.7;
    if (percentage >= 75) return 3.3;
    if (percentage >= 70) return 3.0;
    if (percentage >= 65) return 2.7;
    if (percentage >= 61) return 2.3;
    if (percentage >= 58) return 2.0;
    if (percentage >= 55) return 1.7;
    if (percentage >= 50) return 1.0;
    return 0.0;
  }

  String _getGradeLetter(double percentage) {
    if (percentage >= 85) return 'A';
    if (percentage >= 80) return 'A-';
    if (percentage >= 75) return 'B+';
    if (percentage >= 70) return 'B';
    if (percentage >= 65) return 'B-';
    if (percentage >= 61) return 'C+';
    if (percentage >= 58) return 'C';
    if (percentage >= 55) return 'C-';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return const Color(0xFF06D6A0);
    if (gpa >= 3.0) return const Color(0xFFFBBF24);
    if (gpa >= 2.0) return const Color(0xFFFB923C);
    return const Color(0xFFEF4444);
  }

  void _calculateGPA() {
    double totalPoints = 0.0;
    double totalCredits = 0.0;

    for (var s in _subjects) {
      double percentage = (s.obtained / s.total) * 100;
      double gp = _getGradePoint(percentage);
      totalPoints += gp * s.credit;
      totalCredits += s.credit;
    }

    setState(() {
      _gpa = totalCredits == 0 ? 0 : totalPoints / totalCredits;
      _totalCredits = totalCredits;
    });
  }

  void _saveSemester() {
    if (_subjects.isNotEmpty) {
      widget.onSaveSemester(Semester(
        gpa: _gpa,
        totalCredits: _totalCredits,
        savedAt: DateTime.now(),
      ));
      setState(() {
        _subjects.clear();
        _gpa = 0.0;
        _totalCredits = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semester saved with GPA: ${_gpa.toStringAsFixed(2)}'),
          backgroundColor: const Color(0xFF06D6A0),
        ),
      );
    }
  }

  void _clearAll() {
    setState(() {
      _subjects.clear();
      _gpa = 0.0;
      _totalCredits = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverAppBar(
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'GPA Calculator',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Content Section
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Form
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(_nameController, 'Subject Name'),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      _creditController,
                                      'Credit Hours',
                                      isNumber: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      _obtainedController,
                                      'Obtained Marks',
                                      isNumber: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      _totalController,
                                      'Total Marks',
                                      isNumber: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _addSubject,
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Add Subject'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Subjects List
                    if (_subjects.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            'Subjects (${_subjects.length})',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _clearAll,
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear All'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._subjects.asMap().entries.map((entry) {
                        final index = entry.key;
                        final s = entry.value;
                        final percentage = (s.obtained / s.total) * 100;
                        final gradeLetter = _getGradeLetter(percentage);
                        final gradePoint = _getGradePoint(percentage);

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  gradeLetter,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF6366F1),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              s.name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Credit: ${s.credit} | Marks: ${s.obtained.toStringAsFixed(0)}/${s.total.toStringAsFixed(0)} | ${percentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  gradePoint.toStringAsFixed(1),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF06D6A0),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                  ),
                                  onPressed: () => _removeSubject(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],

                    // GPA Result and Actions
                    if (_subjects.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Semester GPA',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _gpa.toStringAsFixed(2),
                                style: GoogleFonts.inter(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: _getGPAColor(_gpa),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total Credits: ${_totalCredits.toStringAsFixed(1)}',
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _clearAll,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white70,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: const BorderSide(color: Colors.white24),
                                      ),
                                      child: const Text('Reset'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _saveSemester,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF06D6A0),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: const Text('Save Semester'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Empty State
                    if (_subjects.isEmpty) ...[
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.subject_outlined,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No subjects added yet',
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first subject to calculate GPA',
                              style: GoogleFonts.inter(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 80), // Extra space for scrolling
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool isNumber = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Enter $label' : null,
    );
  }
}