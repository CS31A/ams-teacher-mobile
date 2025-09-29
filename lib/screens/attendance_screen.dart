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
  List<AttendanceRecord> _records = [];
  bool _isLoading = false;
  final String _teacherId = 'TCH001'; // This should come from user authentication
  final String _teacherName = 'Ms. Smith'; // This should come from user profile

  @override
  void initState() {
    super.initState();
    // Automatically load attendance data when screen loads
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading time for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Load sample data (in real app, this would come from QR scanning)
    setState(() {
      _records = AttendanceService.sampleRecords();
      _isLoading = false;
    });
  }

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Action Buttons Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Main refresh button
                _RefreshButton(
                  onPressed: _isLoading ? null : _loadAttendanceData,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                // Message button
                _MessageButton(
                  onPressed: _isLoading ? null : _sendMessageToAbsentStudents,
                  absentCount: _getAbsentStudents().length,
                ),
                const SizedBox(height: 16),
                // Optional import/export buttons
                Row(
                  children: [
                    Expanded(
                      child: _SecondaryButton(
                        onPressed: _isLoading ? null : _importCSV,
                        icon: Icons.file_upload_outlined,
                        label: 'Import CSV',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryButton(
                        onPressed: _isLoading ? null : _exportCSV,
                        icon: Icons.file_download_outlined,
                        label: 'Export CSV',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Additional options
                Row(
                  children: [
                    Expanded(
                      child: _SecondaryButton(
                        onPressed: _isLoading ? null : _downloadTemplate,
                        icon: Icons.description_outlined,
                        label: 'Download Template',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _records.clear();
                                });
                              },
                        icon: Icons.clear_all,
                        label: 'Clear List',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading attendance records...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
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
              'Students will appear here after scanning the QR code.',
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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              children: [
                // Student Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            id,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                // Attendance Records
                ...studentRecords.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(r.date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Arrival ${r.timeIn.isEmpty ? '-' : r.timeIn} • Departure ${r.timeOut.isEmpty ? '-' : r.timeOut}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(r.status, context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _statusColor(r.status, context).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              r.status,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _statusColor(r.status, context),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
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

// Custom Refresh Button Widget
class _RefreshButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _RefreshButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.refresh, size: 20),
        label: Text(
          isLoading ? 'Loading Attendance...' : 'Refresh Attendance',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// Custom Message Button Widget
class _MessageButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final int absentCount;

  const _MessageButton({
    required this.onPressed,
    required this.absentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.message_outlined, size: 20),
        label: Text(
          'Message Absent Students ($absentCount)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// Custom Secondary Button Widget
class _SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const _SecondaryButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue[600],
        side: BorderSide(color: Colors.blue[300]!),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}