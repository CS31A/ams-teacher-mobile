import 'package:flutter/material.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded subjects handled by teacher for demo
    final subjects = <String>[
      'Information Assurance',
      'Programming Language',
      'Software Engineering',
      'Mobile Programming',
      'Automata Theory',
      'Computer Architecture',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final subject = subjects[i];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo[100],
                child: const Icon(Icons.menu_book_outlined, color: Colors.black87),
              ),
              title: Text(subject, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}


