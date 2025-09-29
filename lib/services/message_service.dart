import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/message.dart';

class MessageService {
  static const String _fileName = 'messages.json';

  // Save message to local storage
  static Future<void> saveMessage(Message message) async {
    try {
      final messages = await _loadMessages();
      messages.add(message);
      await _saveMessages(messages);
    } catch (e) {
      print('Error saving message: $e');
      rethrow;
    }
  }

  // Load all messages from local storage
  static Future<List<Message>> loadMessages() async {
    return await _loadMessages();
  }

  // Load messages for a specific student
  static Future<List<Message>> loadMessagesForStudent(String studentId) async {
    final messages = await _loadMessages();
    return messages.where((msg) => msg.studentId == studentId).toList();
  }

  // Mark message as read
  static Future<void> markAsRead(String messageId) async {
    try {
      final messages = await _loadMessages();
      final index = messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(isRead: true);
        await _saveMessages(messages);
      }
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  // Delete message
  static Future<void> deleteMessage(String messageId) async {
    try {
      final messages = await _loadMessages();
      messages.removeWhere((msg) => msg.id == messageId);
      await _saveMessages(messages);
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  // Get unread message count for a student
  static Future<int> getUnreadCount(String studentId) async {
    final messages = await loadMessagesForStudent(studentId);
    return messages.where((msg) => !msg.isRead).length;
  }

  // Send message to multiple absent students
  static Future<void> sendMessageToAbsentStudents({
    required List<String> studentIds,
    required List<String> studentNames,
    required String teacherId,
    required String teacherName,
    required String subject,
    required String content,
    required List<String> tasks,
    String? attachmentPath,
  }) async {
    try {
      for (int i = 0; i < studentIds.length; i++) {
        final message = Message(
          id: '${DateTime.now().millisecondsSinceEpoch}_${studentIds[i]}',
          studentId: studentIds[i],
          studentName: studentNames[i],
          teacherId: teacherId,
          teacherName: teacherName,
          subject: subject,
          content: content,
          tasks: tasks,
          date: DateTime.now(),
          attachmentPath: attachmentPath,
        );
        await saveMessage(message);
      }
    } catch (e) {
      print('Error sending messages to absent students: $e');
      rethrow;
    }
  }

  // Generate sample messages for testing
  static List<Message> generateSampleMessages() {
    final now = DateTime.now();
    return [
      Message(
        id: 'msg_001',
        studentId: 'STU003',
        studentName: 'Bob Johnson',
        teacherId: 'TCH001',
        teacherName: 'Ms. Smith',
        subject: 'Assignment Due to Absence',
        content: 'Dear Bob, I noticed you were absent today. Please complete the following tasks and submit them by tomorrow.',
        tasks: [
          'Read Chapter 5 of the textbook',
          'Complete exercises 1-10 on page 45',
          'Write a summary of the main concepts',
        ],
        date: now.subtract(const Duration(hours: 2)),
      ),
      Message(
        id: 'msg_002',
        studentId: 'STU004',
        studentName: 'Alice Brown',
        teacherId: 'TCH001',
        teacherName: 'Ms. Smith',
        subject: 'Make-up Work Required',
        content: 'Hi Alice, since you missed today\'s class, please review the materials and complete the assigned work.',
        tasks: [
          'Watch the recorded lecture',
          'Complete the lab worksheet',
          'Submit your homework by Friday',
        ],
        date: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Private helper methods
  static Future<List<Message>> _loadMessages() async {
    try {
      final file = await _getMessagesFile();
      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      print('Error loading messages: $e');
      return [];
    }
  }

  static Future<void> _saveMessages(List<Message> messages) async {
    try {
      final file = await _getMessagesFile();
      final jsonList = messages.map((msg) => msg.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving messages: $e');
      rethrow;
    }
  }

  static Future<File> _getMessagesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Export messages to CSV
  static Future<String?> exportMessagesToCSV(List<Message> messages) async {
    try {
      List<List<dynamic>> csvData = [];
      
      // Add header
      csvData.add([
        'Message ID',
        'Student ID',
        'Student Name',
        'Teacher Name',
        'Subject',
        'Content',
        'Tasks',
        'Date',
        'Is Read',
      ]);
      
      // Add data rows
      for (var message in messages) {
        csvData.add([
          message.id,
          message.studentId,
          message.studentName,
          message.teacherName,
          message.subject,
          message.content,
          message.tasks.join('; '),
          message.date.toIso8601String(),
          message.isRead ? 'Yes' : 'No',
        ]);
      }
      
      // Convert to CSV string
      String csvContent = const ListToCsvConverter().convert(csvData);
      
      // Get downloads directory
      Directory? directory = await getDownloadsDirectory();
      if (directory == null) {
        directory = await getApplicationDocumentsDirectory();
      }
      
      // Create filename with timestamp
      String fileName = 'messages_${DateTime.now().millisecondsSinceEpoch}.csv';
      String filePath = '${directory.path}/$fileName';
      
      // Write file
      File file = File(filePath);
      await file.writeAsString(csvContent);
      
      return filePath;
    } catch (e) {
      print('Error exporting messages CSV: $e');
      return null;
    }
  }
}
