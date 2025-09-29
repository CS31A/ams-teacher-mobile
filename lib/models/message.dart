class Message {
  final String id;
  final String studentId;
  final String studentName;
  final String teacherId;
  final String teacherName;
  final String subject;
  final String content;
  final List<String> tasks;
  final DateTime date;
  final bool isRead;
  final String? attachmentPath;

  Message({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.content,
    required this.tasks,
    required this.date,
    this.isRead = false,
    this.attachmentPath,
  });

  // Convert to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subject': subject,
      'content': content,
      'tasks': tasks,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'attachmentPath': attachmentPath,
    };
  }

  // Create from Map (JSON deserialization)
  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      teacherId: json['teacherId'],
      teacherName: json['teacherName'],
      subject: json['subject'],
      content: json['content'],
      tasks: List<String>.from(json['tasks'] ?? []),
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
      attachmentPath: json['attachmentPath'],
    );
  }

  // Copy with method for updates
  Message copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? teacherId,
    String? teacherName,
    String? subject,
    String? content,
    List<String>? tasks,
    DateTime? date,
    bool? isRead,
    String? attachmentPath,
  }) {
    return Message(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      tasks: tasks ?? this.tasks,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      attachmentPath: attachmentPath ?? this.attachmentPath,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, studentId: $studentId, studentName: $studentName, subject: $subject, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.studentId == studentId &&
        other.teacherId == teacherId &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studentId.hashCode ^
        teacherId.hashCode ^
        date.hashCode;
  }
}
