import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<AttendanceRecord> _records = [];
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                    : ListView.separated(
                        itemCount: _records.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final rec = _records[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(rec.studentName.isNotEmpty
                                  ? rec.studentName[0]
                                  : '?'),
                            ),
                            title: Text(rec.studentName),
                            subtitle: Text(
                              '${rec.studentId} • ${_formatDate(rec.date)} • In: ${rec.timeIn.isEmpty ? '-' : rec.timeIn} • Out: ${rec.timeOut.isEmpty ? '-' : rec.timeOut}',
                            ),
                            trailing: Text(
                              rec.status,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _statusColor(rec.status, context),
                              ),
                            ),
                          );
                        },
                      ),
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


