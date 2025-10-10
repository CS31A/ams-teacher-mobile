import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Student> students = Student.getHardcodedStudents();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
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
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
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


