import 'dart:io';
import 'dart:convert';

class Student {
  String name;
  int age;
  String city;
  List<String> hobbies;
  Set<String> subjects;

  Student(this.name, this.age, this.city, this.hobbies, this.subjects);

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'city': city,
    'hobbies': hobbies,
    'subjects': subjects.toList(),
  };
}

void main() {
  List<Student> students = [];
  bool keepRunning = true;

  while (keepRunning) {
    stdout.writeln("\n--- Student Management ---");
    stdout.writeln("1) Add Student");
    stdout.writeln("2) Display Students");
    stdout.writeln("3) Search by Name");
    stdout.writeln("4) Filter by Hobby/Subject");
    stdout.writeln("5) Export as JSON");
    stdout.writeln("6) Exit");
    stdout.write("Select option: ");
    String? input = stdin.readLineSync();

    switch (input) {
      case "1":
        students.add(createStudent());
        break;

      case "2":
        showStudents(students);
        break;

      case "3":
        searchStudent(students);
        break;

      case "4":
        filterStudents(students);
        break;

      case "5":
        exportJson(students);
        break;

      case "6":
        keepRunning = false;
        stdout.writeln("Goodbye!");
        break;

      default:
        stdout.writeln("Invalid choice. Try again.");
    }
  }
}

// --- Functions --- //

Student createStudent() {
  stdout.write("Enter name: ");
  String name = stdin.readLineSync() ?? "";

  int age;
  try {
    stdout.write("Enter age: ");
    age = int.parse(stdin.readLineSync() ?? "0");
  } catch (_) {
    stdout.writeln("Invalid age, default = 0");
    age = 0;
  }

  stdout.write("Enter city: ");
  String city = stdin.readLineSync() ?? "";

  stdout.write("Enter hobbies (comma separated): ");
  List<String> hobbies =
  (stdin.readLineSync() ?? "").split(",").map((e) => e.trim()).toList();

  stdout.write("Enter subjects (comma separated): ");
  Set<String> subjects =
  (stdin.readLineSync() ?? "").split(",").map((e) => e.trim()).toSet();

  stdout.writeln("Student added successfully.");
  return Student(name, age, city, hobbies, subjects);
}

void showStudents(List<Student> students) {
  if (students.isEmpty) {
    stdout.writeln("No students available.");
  } else {
    for (var s in students) {
      stdout.writeln(
          "Name: ${s.name}, Age: ${s.age}, City: ${s.city}, Hobbies: ${s.hobbies}, Subjects: ${s.subjects}");
    }
  }
}

void searchStudent(List<Student> students) {
  stdout.write("Enter name to search: ");
  String query = (stdin.readLineSync() ?? "").toLowerCase();

  var found = students.where((s) => s.name.toLowerCase() == query);
  if (found.isEmpty) {
    stdout.writeln("No student found.");
  } else {
    for (var s in found) {
      stdout.writeln("Found: ${s.toMap()}");
    }
  }
}

void filterStudents(List<Student> students) {
  stdout.write("Enter keyword to filter: ");
  String keyword = stdin.readLineSync() ?? "";

  var filtered =
  students.where((s) => s.hobbies.contains(keyword) || s.subjects.contains(keyword));
  if (filtered.isEmpty) {
    stdout.writeln("No student matches filter.");
  } else {
    for (var s in filtered) {
      stdout.writeln("Match: ${s.toMap()}");
    }
  }
}

void exportJson(List<Student> students) {
  List<Map<String, dynamic>> data = students.map((s) => s.toMap()).toList();
  String jsonData = jsonEncode(data);
  stdout.writeln("Exported JSON:\n$jsonData");
}