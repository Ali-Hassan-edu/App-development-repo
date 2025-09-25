import 'dart:convert';
import 'dart:io';

class Student {
  String name;
  int age;
  String city;
  List<String> hobbies;
  Set<String> subjects;

  Student(this.name, this.age, this.city, this.hobbies, this.subjects);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'city': city,
      'hobbies': hobbies,
      'subjects': subjects.toList(),
    };
  }

  void showData() {
    print("Name: $name, Age: $age, City: $city");
    print("Hobbies: $hobbies");
    print("Subjects: $subjects");
  }
}

void main() {
  List<Student> students = [];
  int choice;

  do {
    print("\n--- Student Menu ---");
    print("1. Add Student");
    print("2. Show Data");
    print("3. Export as JSON");
    print("4. Filter Hobbies");
    print("5. Search Student by Name");
    print("6. Exit");

    stdout.write("Enter your choice: ");
    choice = int.tryParse(stdin.readLineSync() ?? "") ?? 0;

    switch (choice) {
      case 1:
      // Error handling with try-catch for age
        stdout.write("Enter name: ");
        String name = stdin.readLineSync() ?? "";

        int age = 0;
        while (true) {
          try {
            stdout.write("Enter age: ");
            age = int.parse(stdin.readLineSync()!);
            break;
          } catch (e) {
            print("Invalid input! Please enter an integer for age.");
          }
        }

        stdout.write("Enter city: ");
        String city = stdin.readLineSync() ?? "";

        stdout.write("Enter hobbies (comma separated): ");
        List<String> hobbies = (stdin.readLineSync() ?? "")
            .split(",")
            .map((e) => e.trim())
            .toList();

        stdout.write("Enter subjects (comma separated): ");
        Set<String> subjects =
        (stdin.readLineSync() ?? "").split(",").map((e) => e.trim()).toSet();

        students.add(Student(name, age, city, hobbies, subjects));
        print("Student added successfully!");
        break;

      case 2:
        print("\n--- All Students Data ---");
        for (var student in students) {
          student.showData();
        }
        break;

      case 3:
        print("\n--- Export Data as JSON ---");
        String jsonData =
        jsonEncode(students.map((s) => s.toMap()).toList());
        print(jsonData);
        break;

      case 4:
        stdout.write("Enter hobby to filter: ");
        String filter = stdin.readLineSync() ?? "";
        var filtered = students.where((s) => s.hobbies.contains(filter));
        for (var s in filtered) {
          s.showData();
        }
        break;

      case 5:
        stdout.write("Enter name to search: ");
        String searchName = stdin.readLineSync() ?? "";
        var found = students.where((s) => s.name == searchName);
        if (found.isEmpty) {
          print("No student found with name $searchName");
        } else {
          for (var s in found) {
            s.showData();
          }
        }
        break;

      case 6:
        print("Exiting program...");
        break;

      default:
        print("Invalid choice! Try again.");
    }
  } while (choice != 6);
}




























// void fun( {int num=0, String name=" "}){
//   print("sdfadsfasd $num   name $name");
// }
// void main(){
//
//
//   // fun();
//   //named parameters
//   //Positional parameters
//
//
//   // List <String> fruits = ['Apple', 'Banana', 'Mango'];
//   // Map<int, List> student = {
//   //   // 'name': 'Ali',
//   //   // 'roll': '101',
//   //   1: fruits
//   // };
//   //print(student[1]); // Ali
//
//
//   // List <String> fruits = ['Apple', 'Banana', 'Mango'];
//   // print(fruits); // Apple
// }