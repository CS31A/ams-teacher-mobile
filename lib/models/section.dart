import 'package:flutter/foundation.dart';
import 'student.dart';

class Subject {
  final String id;
  final String name;
  final String code;
  final List<Student> enrolledStudents;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.enrolledStudents,
  });
}

class Section {
  final String id;
  final String name;
  final String grade;
  final List<Subject> subjects;

  Section({
    required this.id,
    required this.name,
    required this.grade,
    required this.subjects,
  });

  // Helper method to generate sample data
  static List<Section> getHardcodedSections() {
    return [
      Section(
        id: 'cs101',
        name: 'CS 101',
        grade: '1',
        subjects: [
          Subject(
            id: 'prog1',
            name: 'Programming 1',
            code: 'CS101',
            enrolledStudents: [
              Student(
                id: '2023-0001',
                name: 'John Doe',
                email: 'john.doe@example.com',
                grade: '1',
                section: 'A',
              ),
              Student(
                id: '2023-0002',
                name: 'Jane Smith',
                email: 'jane.smith@example.com',
                grade: '1',
                section: 'A',
              ),
            ],
          ),
          Subject(
            id: 'math1',
            name: 'Mathematics 1',
            code: 'MATH101',
            enrolledStudents: [
              Student(
                id: '2023-0001',
                name: 'John Doe',
                email: 'john.doe@example.com',
                grade: '1',
                section: 'A',
              ),
              Student(
                id: '2023-0003',
                name: 'Bob Johnson',
                email: 'bob.johnson@example.com',
                grade: '1',
                section: 'A',
              ),
            ],
          ),
        ],
      ),
      Section(
        id: 'it101',
        name: 'IT 101',
        grade: '1',
        subjects: [
          Subject(
            id: 'intro_it',
            name: 'Introduction to IT',
            code: 'IT101',
            enrolledStudents: [
              Student(
                id: '2023-0004',
                name: 'Alice Brown',
                email: 'alice.brown@example.com',
                grade: '1',
                section: 'B',
              ),
              Student(
                id: '2023-0005',
                name: 'Charlie Davis',
                email: 'charlie.davis@example.com',
                grade: '1',
                section: 'B',
              ),
            ],
          ),
          Subject(
            id: 'web_dev',
            name: 'Web Development',
            code: 'IT102',
            enrolledStudents: [
              Student(
                id: '2023-0004',
                name: 'Alice Brown',
                email: 'alice.brown@example.com',
                grade: '1',
                section: 'B',
              ),
              Student(
                id: '2023-0006',
                name: 'Diana Evans',
                email: 'diana.evans@example.com',
                grade: '1',
                section: 'B',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}