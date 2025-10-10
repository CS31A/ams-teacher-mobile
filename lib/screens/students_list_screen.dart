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

  @override
  void initState() {
    super.initState();
    _sections = Section.getHardcodedSections();
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
        actions: _currentView == 'subjects' && _selectedSection != null
            ? [
                IconButton(
                  tooltip: 'Export to Excel (CSV)',
                  icon: const Icon(Icons.file_download),
                  onPressed: _exportSelectedSectionToCsv,
                ),
                IconButton(
                  tooltip: 'Import from Excel (CSV)',
                  icon: const Icon(Icons.file_upload),
                  onPressed: _importIntoSelectedSectionFromCsv,
                ),
              ]
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
    return ListView.separated(
      itemCount: _sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final section = _sections[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: _buildProgramBadge(section.name),
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

  // Small text-based badge showing CS or IT
  Widget _buildProgramBadge(String sectionName) {
    final isIT = sectionName.toUpperCase().startsWith('IT');
    final label = isIT ? 'IT' : 'CS';
    final Color bg = isIT ? Colors.orange.shade100 : Colors.blue.shade100;
    final Color fg = isIT ? Colors.orange.shade800 : Colors.blue.shade800;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _exportSelectedSectionToCsv() async {
    final section = _selectedSection;
    if (section == null) return;

    final rows = <List<dynamic>>[];
    rows.add(['Section', section.name]);
    rows.add(['Subject', 'Student ID', 'Student Name', 'Email']);
    for (final subject in section.subjects) {
      if (subject.enrolledStudents.isEmpty) {
        rows.add([subject.name, '', '', '']);
        continue;
      }
      for (final student in subject.enrolledStudents) {
        rows.add([
          subject.name,
          student.id,
          student.name,
          student.email,
        ]);
      }
    }

    final csv = const ListToCsvConverter().convert(rows);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filename = 'section_${section.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${dir.path}/$filename');
      await file.writeAsString(csv);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _importIntoSelectedSectionFromCsv() async {
    final section = _selectedSection;
    if (section == null) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final fileBytes = result.files.single.bytes;
      if (fileBytes == null) return;

      final content = String.fromCharCodes(fileBytes);
      final rows = const CsvToListConverter().convert(content);
      // Expect header rows: ['Section', name] then ['Subject','Student ID','Student Name','Email']
      final List<Subject> subjects = [];
      final Map<String, List<dynamic>> subjectKeyToStudents = {};

      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;
        if (row.length >= 2 && i == 0 && (row[0] as String).toLowerCase() == 'section') {
          // Section name row – optional; ignore for now
          continue;
        }
        if (row.length >= 4 && (row[0] as String).toLowerCase() == 'subject') {
          // header row – skip
          continue;
        }
        if (row.length >= 1) {
          final subjectName = (row[0] ?? '').toString();
          if (subjectName.isEmpty) continue;
          subjectKeyToStudents.putIfAbsent(subjectName, () => []);
          subjectKeyToStudents[subjectName]!.add(row);
        }
      }

      subjectKeyToStudents.forEach((subjectName, studentRows) {
        final enrolled = studentRows
            .where((r) => r.length >= 4)
            .map((r) => Student(
                  id: r[1]?.toString() ?? '',
                  name: r[2]?.toString() ?? '',
                  email: r[3]?.toString() ?? '',
                  grade: '',
                  section: '',
                ))
            .toList();
        subjects.add(Subject(
          id: 'IMP_${subjectName.hashCode}',
          name: subjectName,
          code: '',
          enrolledStudents: enrolled,
        ));
      });

      final updatedSection = Section(
        id: section.id,
        name: section.name,
        grade: section.grade,
        subjects: subjects,
      );

      final index = _sections.indexWhere((s) => s.id == section.id);
      if (index >= 0) {
        setState(() {
          _sections[index] = updatedSection;
          _selectedSection = updatedSection;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import completed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
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
