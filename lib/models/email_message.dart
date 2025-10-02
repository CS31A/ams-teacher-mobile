class EmailMessage {
  final String id;
  final String from;
  final String fromName;
  final String subject;
  final String body;
  final DateTime receivedAt;
  final bool isRead;
  final String priority; // 'High', 'Normal', 'Low'
  final List<String> attachments;
  final String? studentId; // Optional student ID
  final String? studentName; // Optional student name

  EmailMessage({
    required this.id,
    required this.from,
    required this.fromName,
    required this.subject,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
    this.priority = 'Normal',
    this.attachments = const [],
    this.studentId,
    this.studentName,
  });

  EmailMessage copyWith({
    String? id,
    String? from,
    String? fromName,
    String? subject,
    String? body,
    DateTime? receivedAt,
    bool? isRead,
    String? priority,
    List<String>? attachments,
    String? studentId,
    String? studentName,
  }) {
    return EmailMessage(
      id: id ?? this.id,
      from: from ?? this.from,
      fromName: fromName ?? this.fromName,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'fromName': fromName,
      'subject': subject,
      'body': body,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
      'priority': priority,
      'attachments': attachments,
      'studentId': studentId,
      'studentName': studentName,
    };
  }

  static EmailMessage fromJson(Map<String, dynamic> json) {
    return EmailMessage(
      id: json['id'],
      from: json['from'],
      fromName: json['fromName'],
      subject: json['subject'],
      body: json['body'],
      receivedAt: DateTime.parse(json['receivedAt']),
      isRead: json['isRead'] ?? false,
      priority: json['priority'] ?? 'Normal',
      attachments: List<String>.from(json['attachments'] ?? []),
      studentId: json['studentId'],
      studentName: json['studentName'],
    );
  }
}

