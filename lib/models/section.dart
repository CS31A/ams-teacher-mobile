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
  final String grade; // year level indicator where applicable
  final List<Subject> subjects;

  Section({
    required this.id,
    required this.name,
    required this.grade,
    required this.subjects,
  });

  static List<Section> getHardcodedSections() {
    final students = Student.getHardcodedStudents();
    List<Student> by(String grade, String sec) =>
        students.where((s) => s.grade == grade && s.section == sec).toList();

    return [
      Section(
        id: 'SEC001',
        name: 'CS31A',
        grade: '3',
        subjects: [
          Subject(
            id: 'CS301',
            name: 'Software Engineering',
            code: 'CS301',
            enrolledStudents: by('12', 'A'),
          ),
        ],
      ),
      Section(
        id: 'SEC002',
        name: 'CS31B',
        grade: '3',
        subjects: [
          Subject(
            id: 'CS302',
            name: 'Database Management',
            code: 'CS302',
            enrolledStudents: by('12', 'B'),
          ),
        ],
      ),
      Section(
        id: 'SEC003',
        name: 'CS21A',
        grade: '2',
        subjects: [
          Subject(
            id: 'CS201',
            name: 'Advanced Programming',
            code: 'CS201',
            enrolledStudents: by('11', 'A'),
          ),
        ],
      ),
      Section(
        id: 'SEC004',
        name: 'IT21A',
        grade: '2',
        subjects: [
          Subject(
            id: 'IT201',
            name: 'Database Systems',
            code: 'IT201',
            enrolledStudents: by('11', 'A'),
          ),
        ],
      ),
      Section(
        id: 'SEC005',
        name: 'CS21B',
        grade: '2',
        subjects: [
          Subject(
            id: 'CS205',
            name: 'Operating Systems',
            code: 'CS205',
            enrolledStudents: by('11', 'B'),
          ),
        ],
      ),
      Section(
        id: 'SEC006',
        name: 'CS11A',
        grade: '1',
        subjects: [
          Subject(
            id: 'CS101',
            name: 'Programming Fundamentals',
            code: 'CS101',
            enrolledStudents: by('10', 'A'),
          ),
        ],
      ),
    ];
  }
}


