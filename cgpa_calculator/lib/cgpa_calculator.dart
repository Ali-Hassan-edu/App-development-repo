import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/semester.dart';
import 'models/subject.dart';

typedef RemoveSemester = void Function(int index);
typedef AddManualSemester = void Function(Semester semester);

class CgpaCalculatorScreen extends StatefulWidget {
  final List<Semester> savedSemesters;
  final RemoveSemester onRemoveSemester;
  final AddManualSemester onAddManualSemester;

  const CgpaCalculatorScreen({
    super.key,
    required this.savedSemesters,
    required this.onRemoveSemester,
    required this.onAddManualSemester,
  });

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
  // Manual CGPA Calculation
  final TextEditingController _previousCGPAController = TextEditingController();
  final TextEditingController _previousCreditsController = TextEditingController();
  final TextEditingController _currentGPAController = TextEditingController();
  final TextEditingController _currentCreditsController = TextEditingController();

  // Manual Semester Input
  final TextEditingController _manualGPAController = TextEditingController();
  final TextEditingController _manualCreditsController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();

  double _predictedCGPA = 0.0;
  bool _showManualInput = false;
  bool _showPrediction = false;

  double calculateCGPA() {
    if (widget.savedSemesters.isEmpty) return 0.0;

    double totalCredits = 0;
    double weightedSum = 0;

    for (var s in widget.savedSemesters) {
      weightedSum += s.gpa * s.totalCredits;
      totalCredits += s.totalCredits;
    }

    return totalCredits == 0 ? 0 : weightedSum / totalCredits;
  }

  void _calculatePredictedCGPA() {
    final previousCGPA = double.tryParse(_previousCGPAController.text) ?? 0;
    final previousCredits = double.tryParse(_previousCreditsController.text) ?? 0;
    final currentGPA = double.tryParse(_currentGPAController.text) ?? 0;
    final currentCredits = double.tryParse(_currentCreditsController.text) ?? 0;

    if (previousCredits > 0 && currentCredits > 0) {
      final totalWeighted = (previousCGPA * previousCredits) + (currentGPA * currentCredits);
      final totalCredits = previousCredits + currentCredits;
      setState(() {
        _predictedCGPA = totalWeighted / totalCredits;
        _showPrediction = true;
      });
    }
  }

  void _addManualSemester() {
    final gpa = double.tryParse(_manualGPAController.text) ?? 0;
    final credits = double.tryParse(_manualCreditsController.text) ?? 0;
    final name = _manualNameController.text.isEmpty ? 'Manual Semester' : _manualNameController.text;

    if (gpa > 0 && credits > 0) {
      widget.onAddManualSemester(Semester(
        gpa: gpa,
        totalCredits: credits,
        savedAt: DateTime.now(),
      ));

      // Clear manual input fields
      _manualGPAController.clear();
      _manualCreditsController.clear();
      _manualNameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name added: GPA ${gpa.toStringAsFixed(2)}'),
          backgroundColor: const Color(0xFF06D6A0),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid GPA and credits'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _clearPrediction() {
    setState(() {
      _previousCGPAController.clear();
      _previousCreditsController.clear();
      _currentGPAController.clear();
      _currentCreditsController.clear();
      _predictedCGPA = 0.0;
      _showPrediction = false;
    });
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return const Color(0xFF06D6A0);
    if (gpa >= 3.0) return const Color(0xFFFBBF24);
    if (gpa >= 2.0) return const Color(0xFFFB923C);
    return const Color(0xFFEF4444);
  }

  String _getCGPAStatus(double cgpa) {
    if (cgpa >= 3.7) return 'Excellent!';
    if (cgpa >= 3.3) return 'Very Good!';
    if (cgpa >= 3.0) return 'Good!';
    if (cgpa >= 2.5) return 'Satisfactory';
    if (cgpa >= 2.0) return 'Needs Improvement';
    return 'Critical - Seek Help';
  }

  @override
  Widget build(BuildContext context) {
    final currentCGPA = calculateCGPA();
    final gpaColor = _getGPAColor(currentCGPA);
    final predictedColor = _getGPAColor(_predictedCGPA);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'CGPA Calculator',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Current CGPA Card
                    Card(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Current CGPA',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentCGPA.toStringAsFixed(2),
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: gpaColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getCGPAStatus(currentCGPA),
                              style: GoogleFonts.inter(
                                color: gpaColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Based on ${widget.savedSemesters.length} semester${widget.savedSemesters.length == 1 ? '' : 's'}',
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CGPA Prediction Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'CGPA Prediction',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    _showPrediction ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPrediction = !_showPrediction;
                                    });
                                  },
                                ),
                              ],
                            ),

                            if (_showPrediction) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Enter your previous academic record and current semester details:',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Previous Semester Inputs
                              _buildInputRow(
                                _previousCGPAController,
                                _previousCreditsController,
                                'Previous CGPA',
                                'Total Credits',
                              ),
                              const SizedBox(height: 16),

                              // Current Semester Inputs
                              _buildInputRow(
                                _currentGPAController,
                                _currentCreditsController,
                                'Current GPA',
                                'Current Credits',
                              ),
                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _clearPrediction,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white70,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Clear'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _calculatePredictedCGPA,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF06D6A0),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Calculate CGPA'),
                                    ),
                                  ),
                                ],
                              ),

                              if (_predictedCGPA > 0) ...[
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: predictedColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: predictedColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Predicted CGPA',
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _predictedCGPA.toStringAsFixed(2),
                                        style: GoogleFonts.inter(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: predictedColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getCGPAStatus(_predictedCGPA),
                                        style: GoogleFonts.inter(
                                          color: predictedColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Manual Semester Input Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Add Manual Semester',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    _showManualInput ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showManualInput = !_showManualInput;
                                    });
                                  },
                                ),
                              ],
                            ),

                            if (_showManualInput) ...[
                              const SizedBox(height: 16),
                              _buildManualInputRow(),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _addManualSemester,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text('Add Semester to History'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Semesters History
                    Row(
                      children: [
                        Text(
                          'Semester History',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.savedSemesters.length} total',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (widget.savedSemesters.isEmpty)
                      Card(
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.history_edu,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No semesters recorded yet',
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add semesters using GPA calculator or manual input above',
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...widget.savedSemesters.reversed.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final s = entry.value;
                        final semesterGpaColor = _getGPAColor(s.gpa);
                        final actualIndex = widget.savedSemesters.length - 1 - index;

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: semesterGpaColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: semesterGpaColor.withOpacity(0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'S${actualIndex + 1}',
                                  style: GoogleFonts.inter(
                                    color: semesterGpaColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              'GPA: ${s.gpa.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Credits: ${s.totalCredits.toStringAsFixed(1)}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Added: ${s.savedAt.day}/${s.savedAt.month}/${s.savedAt.year}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                              ),
                              onPressed: () => widget.onRemoveSemester(actualIndex),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(
      TextEditingController gpaController,
      TextEditingController creditsController,
      String gpaLabel,
      String creditsLabel,
      ) {
    return Row(
      children: [
        Expanded(
          child: _buildPredictionTextField(gpaController, gpaLabel),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPredictionTextField(creditsController, creditsLabel),
        ),
      ],
    );
  }

  Widget _buildManualInputRow() {
    return Column(
      children: [
        _buildPredictionTextField(_manualNameController, 'Semester Name (Optional)'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPredictionTextField(_manualGPAController, 'GPA'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPredictionTextField(_manualCreditsController, 'Credits'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPredictionTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}