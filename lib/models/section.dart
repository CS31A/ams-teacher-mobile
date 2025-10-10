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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'enrolledStudents': enrolledStudents.map((s) => s.toJson()).toList(),
    };
  }

  static Subject fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      enrolledStudents: (json['enrolledStudents'] as List)
          .map((s) => Student.fromJson(s))
          .toList(),
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'subjects': subjects.map((s) => s.toJson()).toList(),
    };
  }

  static Section fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      grade: json['grade'],
      subjects: (json['subjects'] as List)
          .map((s) => Subject.fromJson(s))
          .toList(),
    );
  }

  // Hardcoded section data for demo purposes
  static List<Section> getHardcodedSections() {
    final students = Student.getHardcodedStudents();
    
    return [
      // Computer Science Sections
      Section(
        id: 'SEC001',
        name: 'CS31A',
        grade: '3',
        subjects: [
          Subject(
            id: 'SUB001',
            name: 'Software Engineering',
            code: 'CS301',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB002',
            name: 'Database Management',
            code: 'CS302',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB003',
            name: 'Web Development',
            code: 'CS303',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'A').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC002',
        name: 'CS31B',
        grade: '3',
        subjects: [
          Subject(
            id: 'SUB004',
            name: 'Software Engineering',
            code: 'CS301',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB005',
            name: 'Data Structures',
            code: 'CS304',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB006',
            name: 'Computer Networks',
            code: 'CS305',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'B').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC003',
        name: 'CS21A',
        grade: '2',
        subjects: [
          Subject(
            id: 'SUB007',
            name: 'Advanced Programming',
            code: 'CS201',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB008',
            name: 'Data Structures & Algorithms',
            code: 'CS202',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB009',
            name: 'Computer Organization',
            code: 'CS203',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'A').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC004',
        name: 'CS21B',
        grade: '2',
        subjects: [
          Subject(
            id: 'SUB010',
            name: 'Advanced Programming',
            code: 'CS201',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB011',
            name: 'Object-Oriented Programming',
            code: 'CS204',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB012',
            name: 'Operating Systems',
            code: 'CS205',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'B').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC005',
        name: 'CS11A',
        grade: '1',
        subjects: [
          Subject(
            id: 'SUB013',
            name: 'Programming Fundamentals',
            code: 'CS101',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB014',
            name: 'Introduction to Computing',
            code: 'CS102',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB015',
            name: 'Discrete Mathematics',
            code: 'CS103',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'A').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC006',
        name: 'CS11B',
        grade: '1',
        subjects: [
          Subject(
            id: 'SUB016',
            name: 'Programming Fundamentals',
            code: 'CS101',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB017',
            name: 'Computer Literacy',
            code: 'CS104',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB018',
            name: 'Logic Design',
            code: 'CS105',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'B').toList(),
          ),
        ],
      ),
      
      // Information Technology Sections
      Section(
        id: 'SEC007',
        name: 'IT31A',
        grade: '3',
        subjects: [
          Subject(
            id: 'SUB019',
            name: 'IT Project Management',
            code: 'IT301',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB020',
            name: 'Network Administration',
            code: 'IT302',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB021',
            name: 'System Administration',
            code: 'IT303',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'A').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC008',
        name: 'IT31B',
        grade: '3',
        subjects: [
          Subject(
            id: 'SUB022',
            name: 'IT Project Management',
            code: 'IT301',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB023',
            name: 'Cybersecurity Fundamentals',
            code: 'IT304',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB024',
            name: 'Cloud Computing',
            code: 'IT305',
            enrolledStudents: students.where((s) => s.grade == '12' && s.section == 'B').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC009',
        name: 'IT21A',
        grade: '2',
        subjects: [
          Subject(
            id: 'SUB025',
            name: 'Database Systems',
            code: 'IT201',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB026',
            name: 'Web Technologies',
            code: 'IT202',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB027',
            name: 'IT Infrastructure',
            code: 'IT203',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'A').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC010',
        name: 'IT21B',
        grade: '2',
        subjects: [
          Subject(
            id: 'SUB028',
            name: 'Database Systems',
            code: 'IT201',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB029',
            name: 'Mobile Application Development',
            code: 'IT204',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB030',
            name: 'IT Support Services',
            code: 'IT205',
            enrolledStudents: students.where((s) => s.grade == '11' && s.section == 'B').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC011',
        name: 'IT11A',
        grade: '1',
        subjects: [
          Subject(
            id: 'SUB031',
            name: 'Introduction to Information Technology',
            code: 'IT101',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB032',
            name: 'Computer Hardware & Software',
            code: 'IT102',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'A').toList(),
          ),
          Subject(
            id: 'SUB033',
            name: 'Basic Programming',
            code: 'IT103',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'A').toList(),
          ),
        ],
      ),
      Section(
        id: 'SEC012',
        name: 'IT11B',
        grade: '1',
        subjects: [
          Subject(
            id: 'SUB034',
            name: 'Introduction to Information Technology',
            code: 'IT101',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB035',
            name: 'Digital Literacy',
            code: 'IT104',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'B').toList(),
          ),
          Subject(
            id: 'SUB036',
            name: 'Computer Networks Basics',
            code: 'IT105',
            enrolledStudents: students.where((s) => s.grade == '10' && s.section == 'B').toList(),
          ),
        ],
      ),
    ];
  }
}
