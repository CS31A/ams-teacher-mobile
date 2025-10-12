import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';
import '../models/section.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  // Navigation state
  String _currentView = 'sections'; // 'sections', 'subjects', 'students'
  Section? _selectedSection;
  Subject? _selectedSubjectForStudents;
  late List<Section> _sections;

  // ✅ Add this list to fix the error
  late List<Student> students;

  @override
  void initState() {
    super.initState();
    _sections = Section.getHardcodedSections();

    // ✅ Initialize with hardcoded or fetched data
    students = Student.getHardcodedStudents();
  }

  void _navigateToSubjects(Section section) {
    setState(() {
      _currentView = 'subjects';
      _selectedSection = section;
    });
  }

  void _navigateToStudents(Subject subject) {
    setState(() {
      _currentView = 'students';
      _selectedSubjectForStudents = subject;
    });
  }

  void _navigateBack() {
    setState(() {
      if (_currentView == 'students') {
        _currentView = 'subjects';
        _selectedSubjectForStudents = null;
      } else if (_currentView == 'subjects') {
        _currentView = 'sections';
        _selectedSection = null;
      }
    });
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case 'sections':
        return 'Sections';
      case 'subjects':
        return _selectedSection?.name ?? 'Subjects';
      case 'students':
        return _selectedSubjectForStudents?.name ?? 'Students';
      default:
        return 'Sections';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        leading: _currentView != 'sections'
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              )
            : null,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final s = students[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.person, color: Colors.black87),
              ),
              title: Text(
                s.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${s.email} • Grade ${s.grade}${s.section}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
