import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../services/message_service.dart';
import 'message_compose_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<AttendanceRecord> _records = [];
  bool _isLoading = false;
  final String _teacherId = 'TCH001'; // This should come from user authentication
  final String _teacherName = 'Ms. Smith'; // This should come from user profile

  Future<void> _importCSV() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final imported = await AttendanceService.importFromCSV();
      if (imported.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected or file empty.')),
          );
        }
        return;
      }
      setState(() {
        _records
          ..clear()
          ..addAll(imported);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${imported.length} records.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import CSV: $e')),
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

  Future<void> _exportCSV() async {
    if (_records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records to export.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final path = await AttendanceService.exportToCSV(_records);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed.')),
        );
      }
    }
  }

  Future<void> _downloadTemplate() async {
    setState(() {
      _isLoading = true;
    });
    final path = await AttendanceService.saveSampleCSV();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template saved to $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save template.')),
        );
      }
    }
  }

  List<AttendanceRecord> _getAbsentStudents() {
    return _records.where((record) => record.status.toLowerCase() == 'absent').toList();
  }

  Future<void> _sendMessageToAbsentStudents() async {
    final absentStudents = _getAbsentStudents();
    if (absentStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No absent students found.')),
      );
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => MessageComposeScreen(
          absentStudents: absentStudents,
          teacherId: _teacherId,
          teacherName: _teacherName,
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Messages sent to ${absentStudents.length} absent students'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _importCSV,
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Import CSV'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _exportCSV,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Export CSV'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _records
                                    ..clear()
                                    ..addAll(AttendanceService.sampleRecords());
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Loaded sample students.')),
                                );
                              },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Load Sample'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Message button row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _sendMessageToAbsentStudents,
                        icon: const Icon(Icons.message_outlined),
                        label: Text('Message Absent Students (${_getAbsentStudents().length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _downloadTemplate,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Download Template'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _records.clear();
                            });
                          },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear List'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const _EmptyState()
                    : _GroupedByStudentList(records: _records),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Color _statusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green[700]!;
      case 'late':
        return Colors.orange[700]!;
      case 'absent':
        return Colors.red[700]!;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No attendance records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Import a CSV file or download a template to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedByStudentList extends StatelessWidget {
  final List<AttendanceRecord> records;

  const _GroupedByStudentList({required this.records});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<AttendanceRecord>> byStudent = {};
    for (final r in records) {
      byStudent.putIfAbsent('${r.studentName}__${r.studentId}', () => []).add(r);
    }

    final entries = byStudent.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final key = entries[index].key;
        final parts = key.split('__');
        final name = parts.first;
        final id = parts.last;
        final studentRecords = entries[index].value
          ..sort((a, b) => a.date.compareTo(b.date));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              id,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Color(0xFF1565C0))
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...studentRecords.map((r) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F6FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF1565C0)),
                          title: Text(_formatDate(r.date)),
                          subtitle: Text('Arrival ${r.timeIn.isEmpty ? '-' : r.timeIn}   •   Departure ${r.timeOut.isEmpty ? '-' : r.timeOut}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(r.status, context).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              r.status,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _statusColor(r.status, context),
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Color _statusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green[700]!;
      case 'late':
        return Colors.orange[700]!;
      case 'absent':
        return Colors.red[700]!;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}


