import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/attendance.dart';
import '../services/message_service.dart';

class MessageComposeScreen extends StatefulWidget {
  final List<AttendanceRecord> absentStudents;
  final String teacherId;
  final String teacherName;

  const MessageComposeScreen({
    super.key,
    required this.absentStudents,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<MessageComposeScreen> createState() => _MessageComposeScreenState();
}

class _MessageComposeScreenState extends State<MessageComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  final _taskController = TextEditingController();
  
  List<String> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectController.text = 'Assignment Due to Absence';
    _contentController.text = 'Dear student, I noticed you were absent today. Please complete the following tasks and submit them as soon as possible.';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.trim().isNotEmpty) {
      setState(() {
        _tasks.add(_taskController.text.trim());
        _taskController.clear();
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  Future<void> _sendMessages() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one task.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final studentIds = widget.absentStudents.map((s) => s.studentId).toList();
      final studentNames = widget.absentStudents.map((s) => s.studentName).toList();

      await MessageService.sendMessageToAbsentStudents(
        studentIds: studentIds,
        studentNames: studentNames,
        teacherId: widget.teacherId,
        teacherName: widget.teacherName,
        subject: _subjectController.text.trim(),
        content: _contentController.text.trim(),
        tasks: _tasks,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Messages sent to ${widget.absentStudents.length} absent students'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Send Message to Absent Students',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _sendMessages,
              style: TextButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey[300] : Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _isLoading ? 'Sending...' : 'Send',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Absent Students List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.people_outline, color: Colors.red[600], size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Absent Students',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${widget.absentStudents.length}',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...widget.absentStudents.map((student) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.red[100],
                              child: Text(
                                student.studentName.isNotEmpty ? student.studentName[0] : '?',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.studentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    student.studentId,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.schedule, color: Colors.grey[400], size: 16),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Subject Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          hintText: 'Enter message subject',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[400]!),
                          ),
                          prefixIcon: Icon(Icons.subject, color: Colors.grey[600]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a subject';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Content Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message Content',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: 'Write your message here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[400]!),
                          ),
                          prefixIcon: Icon(Icons.message, color: Colors.grey[600]),
                          alignLabelWithHint: true,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter message content';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tasks Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.assignment, color: Colors.blue[600], size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tasks to Complete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Add Task Field
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _taskController,
                              decoration: InputDecoration(
                                hintText: 'Add a task for students to complete',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.blue[400]!),
                                ),
                                prefixIcon: Icon(Icons.add_task, color: Colors.grey[600]),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onFieldSubmitted: (_) => _addTask(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _addTask,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tasks List
                      if (_tasks.isNotEmpty) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: _tasks.asMap().entries.map((entry) {
                              final index = entry.key;
                              final task = entry.value;
                              return Container(
                                decoration: BoxDecoration(
                                  border: index < _tasks.length - 1 
                                    ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                                    : null,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    task,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.red[400], size: 20),
                                    onPressed: () => _removeTask(index),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.task_alt, color: Colors.grey[400], size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'No tasks added yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add tasks for students to complete',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Send Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendMessages,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, size: 20),
                  label: Text(
                    _isLoading ? 'Sending Messages...' : 'Send Messages',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
