class Semester {
  final double gpa;
  final double totalCredits;
  final DateTime savedAt;

  Semester({
    required this.gpa,
    required this.totalCredits,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'gpa': gpa,
      'totalCredits': totalCredits,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      gpa: (json['gpa'] as num).toDouble(),
      totalCredits: (json['totalCredits'] as num).toDouble(),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}