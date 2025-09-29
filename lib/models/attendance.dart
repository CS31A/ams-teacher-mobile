class AttendanceRecord {
  final String studentId;
  final String studentName;
  final DateTime date;
  final String timeIn;
  final String timeOut;
  final String status; // 'Present', 'Late', 'Absent'

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.status,
  });

  // Convert to CSV row
  List<String> toCSVRow() {
    return [
      studentId,
      studentName,
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      timeIn,
      timeOut,
      status,
    ];
  }

  // Create from CSV row
  static AttendanceRecord fromCSVRow(List<String> row) {
    if (row.length < 6) {
      throw Exception('Invalid CSV row: insufficient columns');
    }

    final dateParts = row[2].split('-');
    final date = DateTime(
      int.parse(dateParts[0]), // year
      int.parse(dateParts[1]), // month
      int.parse(dateParts[2]), // day
    );

    return AttendanceRecord(
      studentId: row[0],
      studentName: row[1],
      date: date,
      timeIn: row[3],
      timeOut: row[4],
      status: row[5],
    );
  }

  // Convert to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'date': date.toIso8601String(),
      'timeIn': timeIn,
      'timeOut': timeOut,
      'status': status,
    };
  }

  // Create from Map (JSON deserialization)
  static AttendanceRecord fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: json['studentId'],
      studentName: json['studentName'],
      date: DateTime.parse(json['date']),
      timeIn: json['timeIn'],
      timeOut: json['timeOut'],
      status: json['status'],
    );
  }

  // Copy with method for updates
  AttendanceRecord copyWith({
    String? studentId,
    String? studentName,
    DateTime? date,
    String? timeIn,
    String? timeOut,
    String? status,
  }) {
    return AttendanceRecord(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'AttendanceRecord(studentId: $studentId, studentName: $studentName, date: $date, timeIn: $timeIn, timeOut: $timeOut, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceRecord &&
        other.studentId == studentId &&
        other.studentName == studentName &&
        other.date == date &&
        other.timeIn == timeIn &&
        other.timeOut == timeOut &&
        other.status == status;
  }

  @override
  int get hashCode {
    return studentId.hashCode ^
        studentName.hashCode ^
        date.hashCode ^
        timeIn.hashCode ^
        timeOut.hashCode ^
        status.hashCode;
  }
}

