import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Move QuizAssignment class outside the state class
class QuizAssignment {
  TextEditingController obtainedController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  double get percentage {
    final obtained = double.tryParse(obtainedController.text) ?? 0;
    final total = double.tryParse(totalController.text) ?? 0;
    return total > 0 ? (obtained / total) * 100 : 0;
  }
}

class GradePredictorScreen extends StatefulWidget {
  const GradePredictorScreen({super.key});

  @override
  State<GradePredictorScreen> createState() => _GradePredictorScreenState();
}

class _GradePredictorScreenState extends State<GradePredictorScreen> {
  // Dynamic lists for inputs - now with obtained and total marks
  List<QuizAssignment> quizData = [QuizAssignment()];
  List<QuizAssignment> assignmentData = [QuizAssignment()];
  List<QuizAssignment> labAssignmentData = [QuizAssignment()];

  // Removed Personality/User Marks Controllers

  final TextEditingController _midTermObtainedController = TextEditingController();
  final TextEditingController _midTermTotalController = TextEditingController();
  final TextEditingController _labMidTermObtainedController = TextEditingController();
  final TextEditingController _labMidTermTotalController = TextEditingController();
  final TextEditingController _finalTotalController = TextEditingController();

  double _predictedGPA = 0.0;
  double _requiredFinalPercentage = 0.0;
  double _requiredFinalMarks = 0.0;
  double _currentTotalPercentage = 0.0;
  bool _hasLabSubject = false;
  String _predictionMessage = '';
  bool _showResults = false;

  // Add more input fields
  void _addQuizField() {
    setState(() {
      quizData.add(QuizAssignment());
    });
  }

  void _removeQuizField(int index) {
    if (quizData.length > 1) {
      setState(() {
        quizData.removeAt(index);
      });
    }
  }

  void _addAssignmentField() {
    setState(() {
      assignmentData.add(QuizAssignment());
    });
  }

  void _removeAssignmentField(int index) {
    if (assignmentData.length > 1) {
      setState(() {
        assignmentData.removeAt(index);
      });
    }
  }

  void _addLabAssignmentField() {
    setState(() {
      labAssignmentData.add(QuizAssignment());
    });
  }

  void _removeLabAssignmentField(int index) {
    if (labAssignmentData.length > 1) {
      setState(() {
        labAssignmentData.removeAt(index);
      });
    }
  }

  void _predictGPA() {
    double totalWeightedPercentage = 0.0;

    // Quizzes (15% total weight)
    double quizTotalObtained = 0.0;
    double quizTotalMax = 0.0;
    for (var quiz in quizData) {
      final obtained = double.tryParse(quiz.obtainedController.text) ?? 0;
      final total = double.tryParse(quiz.totalController.text) ?? 0;
      if (total > 0) {
        quizTotalObtained += obtained;
        quizTotalMax += total;
      }
    }
    if (quizTotalMax > 0) {
      double quizPercentage = (quizTotalObtained / quizTotalMax) * 100;
      totalWeightedPercentage += quizPercentage * 0.15;
    }

    // Assignments (10% total weight)
    double assignmentTotalObtained = 0.0;
    double assignmentTotalMax = 0.0;
    for (var assignment in assignmentData) {
      final obtained = double.tryParse(assignment.obtainedController.text) ?? 0;
      final total = double.tryParse(assignment.totalController.text) ?? 0;
      if (total > 0) {
        assignmentTotalObtained += obtained;
        assignmentTotalMax += total;
      }
    }
    if (assignmentTotalMax > 0) {
      double assignmentPercentage = (assignmentTotalObtained / assignmentTotalMax) * 100;
      totalWeightedPercentage += assignmentPercentage * 0.10;
    }

    // Theory Mid Term (25% weight)
    final theoryMidTermObtained = double.tryParse(_midTermObtainedController.text) ?? 0;
    final theoryMidTermTotal = double.tryParse(_midTermTotalController.text) ?? 0;
    if (theoryMidTermTotal > 0) {
      double midTermPercentage = (theoryMidTermObtained / theoryMidTermTotal) * 100;
      totalWeightedPercentage += midTermPercentage * 0.25;
    }

    // Lab Components (only if lab subject is enabled) - Weights are unchanged
    if (_hasLabSubject) {
      // Lab Assignments (25% weight)
      double labAssignmentTotalObtained = 0.0;
      double labAssignmentTotalMax = 0.0;
      for (var labAssignment in labAssignmentData) {
        final obtained = double.tryParse(labAssignment.obtainedController.text) ?? 0;
        final total = double.tryParse(labAssignment.totalController.text) ?? 0;
        if (total > 0) {
          labAssignmentTotalObtained += obtained;
          labAssignmentTotalMax += total;
        }
      }
      if (labAssignmentTotalMax > 0) {
        double labAssignmentPercentage = (labAssignmentTotalObtained / labAssignmentTotalMax) * 100;
        totalWeightedPercentage += labAssignmentPercentage * 0.25;
      }

      // Lab Mid Term (25% weight)
      final labMidTermObtained = double.tryParse(_labMidTermObtainedController.text) ?? 0;
      final labMidTermTotal = double.tryParse(_labMidTermTotalController.text) ?? 0;
      if (labMidTermTotal > 0) {
        double labMidTermPercentage = (labMidTermObtained / labMidTermTotal) * 100;
        totalWeightedPercentage += labMidTermPercentage * 0.25;
      }
    }

    // Calculate current weighted percentage
    _currentTotalPercentage = totalWeightedPercentage;

    // Calculate required final marks for A+ (85%)
    final targetPercentage = 85.0;

    // Fixed weights based on original code
    double finalWeight = _hasLabSubject ? 0.15 : 0.50; // 50% for theory-only, 15% for with lab

    if (finalWeight > 0) {
      // Formula: Required_Final_Percentage = (Target - Current_Weighted_Marks) / Final_Weight
      _requiredFinalPercentage = (targetPercentage - (_currentTotalPercentage)) / finalWeight;
      _requiredFinalPercentage = _requiredFinalPercentage.clamp(0.0, 100.0);

      // Calculate actual marks needed based on final exam total marks
      final finalTotalMarks = double.tryParse(_finalTotalController.text) ?? 100;
      _requiredFinalMarks = (_requiredFinalPercentage / 100) * finalTotalMarks;
    }

    // Convert to GPA
    _predictedGPA = _percentageToGPA(_currentTotalPercentage);

    // Generate prediction message
    _generatePredictionMessage(_currentTotalPercentage);

    setState(() {
      _showResults = true;
    });
  }

  double _percentageToGPA(double percentage) {
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
    if (percentage >= 85) return 'A+';
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

  void _generatePredictionMessage(double currentPercentage) {
    if (currentPercentage >= 85) {
      _predictionMessage = 'Excellent! You are on track for an A+ grade. Maintain your performance.';
    } else if (currentPercentage >= 75) {
      _predictionMessage = 'Good work! You are heading for a B+ or higher. Keep it up!';
    } else if (currentPercentage >= 65) {
      _predictionMessage = 'You are doing well. Focus on improving to reach your target.';
    } else if (currentPercentage >= 50) {
      _predictionMessage = 'You need to work harder. Focus on upcoming assessments.';
    } else {
      _predictionMessage = 'Serious improvement needed. Seek academic support and plan your studies.';
    }
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return const Color(0xFF06D6A0);
    if (gpa >= 3.0) return const Color(0xFFFBBF24);
    if (gpa >= 2.0) return const Color(0xFFFB923C);
    return const Color(0xFFEF4444);
  }

  void _clearAll() {
    setState(() {
      quizData = [QuizAssignment()];
      assignmentData = [QuizAssignment()];
      labAssignmentData = [QuizAssignment()];
      _midTermObtainedController.clear();
      _midTermTotalController.clear();
      _labMidTermObtainedController.clear();
      _labMidTermTotalController.clear();
      _finalTotalController.clear();
      _predictedGPA = 0.0;
      _requiredFinalPercentage = 0.0;
      _requiredFinalMarks = 0.0;
      _currentTotalPercentage = 0.0;
      _predictionMessage = '';
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Grade Predictor',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF06D6A0), Color(0xFF6366F1)],
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
                    // Lab Subject Toggle
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.science, color: Colors.white70),
                            const SizedBox(width: 12),
                            Text(
                              'Has Lab Subject?',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: _hasLabSubject,
                              onChanged: (value) {
                                setState(() {
                                  _hasLabSubject = value;
                                });
                              },
                              activeColor: const Color(0xFF06D6A0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Theory Components Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theory Components (Final 50%)',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Quizzes Section
                            _buildDynamicSection(
                              'Quizzes (15% weight)',
                              quizData,
                              _addQuizField,
                              _removeQuizField,
                              'Q',
                            ),
                            const SizedBox(height: 20),

                            // Assignments Section
                            _buildDynamicSection(
                              'Assignments (10% weight)',
                              assignmentData,
                              _addAssignmentField,
                              _removeAssignmentField,
                              'A',
                            ),
                            const SizedBox(height: 20),

                            // Mid Term
                            _buildMidTermSection(
                              _midTermObtainedController,
                              _midTermTotalController,
                              'Theory Mid Term (25%)',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lab Components (Conditional)
                    if (_hasLabSubject) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lab Components',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Lab Assignments
                              _buildDynamicSection(
                                'Lab Assignments (25% weight)',
                                labAssignmentData,
                                _addLabAssignmentField,
                                _removeLabAssignmentField,
                                'Lab',
                              ),
                              const SizedBox(height: 20),

                              // Lab Mid Term
                              _buildMidTermSection(
                                _labMidTermObtainedController,
                                _labMidTermTotalController,
                                'Lab Mid Term (25%)',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Final Exam Total Marks Input
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Final Exam Details',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enter total marks of final exam (e.g. 50) to calculate exact marks needed:',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMarksTextField(_finalTotalController, 'Final Exam Total Marks'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
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
                            child: const Text('Clear All'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _predictGPA,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Calculate Prediction'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Results Section
                    if (_showResults) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Prediction Results',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Current Performance
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _getGPAColor(_predictedGPA).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getGPAColor(_predictedGPA).withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Current Performance',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_currentTotalPercentage.toStringAsFixed(1)}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: _getGPAColor(_predictedGPA),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'GPA: ${_predictedGPA.toStringAsFixed(2)} | Grade: ${_getGradeLetter(_currentTotalPercentage)}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _predictionMessage,
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Required Final Marks for A+
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'To Achieve A+ Grade (85% Overall)',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Marks Requirement
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF06D6A0).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF06D6A0).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '🎯 You need in Final Exam:',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '${_requiredFinalPercentage.toStringAsFixed(1)}%',
                                            style: GoogleFonts.inter(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF06D6A0),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Which is:',
                                            style: GoogleFonts.inter(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_requiredFinalMarks.toStringAsFixed(1)} out of ${_finalTotalController.text.isEmpty ? '100' : _finalTotalController.text} marks',
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF8B5CF6),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Explanation
                                    Text(
                                      'Based on your current performance of ${_currentTotalPercentage.toStringAsFixed(1)}%, '
                                          'you need ${_requiredFinalPercentage.toStringAsFixed(1)}% in the final exam '
                                          'to achieve 85% overall.',
                                      style: GoogleFonts.inter(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _getStudyAdvice(_requiredFinalPercentage),
                                      style: GoogleFonts.inter(
                                        color: Colors.white54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicSection(
      String title,
      List<QuizAssignment> data,
      VoidCallback onAdd,
      Function(int) onRemove,
      String prefix,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF06D6A0)),
              onPressed: onAdd,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMarksTextField(item.obtainedController, '$prefix${index + 1} Obtained'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMarksTextField(item.totalController, '$prefix${index + 1} Total'),
                  ),
                  if (data.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                      onPressed: () => onRemove(index),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMidTermSection(
      TextEditingController obtainedController,
      TextEditingController totalController,
      String title,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMarksTextField(obtainedController, 'Obtained Marks'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMarksTextField(totalController, 'Total Marks'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarksTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  String _getStudyAdvice(double requiredPercentage) {
    if (requiredPercentage <= 60) return '🎉 You are on track! Maintain your current performance.';
    if (requiredPercentage <= 75) return '👍 Good position! Focus on final exam preparation.';
    if (requiredPercentage <= 85) return '💪 Challenging but achievable! Intensive study needed.';
    return '🚨 Requires excellent performance! Consider seeking academic support.';
  }
}