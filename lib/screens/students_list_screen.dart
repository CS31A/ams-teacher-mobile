import 'package:flutter/material.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentView == 'sections') ...[
              Expanded(child: _buildSectionsList()),
            ] else if (_currentView == 'subjects') ...[
              const Text(
                'Select a Subject',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildSubjectsList()),
            ] else if (_currentView == 'students') ...[
              const Text(
                'Students in Subject',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildStudentsList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsList() {
    final sections = Section.getHardcodedSections();
    return ListView.separated(
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final section = sections[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                section.grade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
            title: Text(
              section.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${section.subjects.length} subjects'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToSubjects(section),
          ),
        );
      },
    );
  }

  Widget _buildSubjectsList() {
    if (_selectedSection == null) return const SizedBox();
    
    return ListView.separated(
      itemCount: _selectedSection!.subjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final subject = _selectedSection!.subjects[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(
                Icons.book,
                color: Colors.green[800],
              ),
            ),
            title: Text(
              subject.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${subject.code} • ${subject.enrolledStudents.length} students'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToStudents(subject),
          ),
        );
      },
    );
  }

  Widget _buildStudentsList() {
    if (_selectedSubjectForStudents == null) return const SizedBox();
    
    return ListView.separated(
      itemCount: _selectedSubjectForStudents!.enrolledStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final student = _selectedSubjectForStudents!.enrolledStudents[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Icon(
                Icons.person,
                color: Colors.purple[800],
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${student.email} • Grade ${student.grade}${student.section}'),
            trailing: Icon(
              Icons.check_circle,
              color: Colors.green[600],
            ),
          ),
        );
      },
    );
  }
}
