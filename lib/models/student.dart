class Student {
  final String id;
  final String name;
  final String email;
  final String grade;
  final String section;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    required this.section,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'grade': grade,
      'section': section,
    };
  }

  static Student fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      grade: json['grade'],
      section: json['section'],
    );
  }

  // Hardcoded student data for demo purposes
  static List<Student> getHardcodedStudents() {
    return [
      Student(
        id: 'STU001',
        name: 'Emma Johnson',
        email: 'emma.johnson@school.edu',
        grade: '10',
        section: 'A',
      ),
      Student(
        id: 'STU002',
        name: 'Liam Smith',
        email: 'liam.smith@school.edu',
        grade: '10',
        section: 'A',
      ),
      Student(
        id: 'STU003',
        name: 'Olivia Brown',
        email: 'olivia.brown@school.edu',
        grade: '10',
        section: 'B',
      ),
      Student(
        id: 'STU004',
        name: 'Noah Davis',
        email: 'noah.davis@school.edu',
        grade: '10',
        section: 'B',
      ),
      Student(
        id: 'STU005',
        name: 'Ava Wilson',
        email: 'ava.wilson@school.edu',
        grade: '11',
        section: 'A',
      ),
      Student(
        id: 'STU006',
        name: 'William Garcia',
        email: 'william.garcia@school.edu',
        grade: '11',
        section: 'A',
      ),
      Student(
        id: 'STU007',
        name: 'Sophia Martinez',
        email: 'sophia.martinez@school.edu',
        grade: '11',
        section: 'B',
      ),
      Student(
        id: 'STU008',
        name: 'James Anderson',
        email: 'james.anderson@school.edu',
        grade: '12',
        section: 'A',
      ),
      Student(
        id: 'STU009',
        name: 'Isabella Taylor',
        email: 'isabella.taylor@school.edu',
        grade: '12',
        section: 'A',
      ),
      Student(
        id: 'STU010',
        name: 'Benjamin Thomas',
        email: 'benjamin.thomas@school.edu',
        grade: '12',
        section: 'B',
      ),
    ];
  }
}
