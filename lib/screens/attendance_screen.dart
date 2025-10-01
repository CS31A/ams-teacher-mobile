import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../services/message_service.dart';
import 'message_compose_screen.dart';
import 'attendance_detail_screen.dart';

// Separate Attendance Status Classes
class AbsentStudents {
  final List<AttendanceRecord> students;
  final Color color = Colors.red;

  AbsentStudents({required this.students});

  bool get isEmpty => students.isEmpty;
  int get count => students.length;
  String get title => 'Absent Students';
}

class LateStudents {
  final List<AttendanceRecord> students;
  final Color color = Colors.orange;

  LateStudents({required this.students});

  bool get isEmpty => students.isEmpty;
  int get count => students.length;
  String get title => 'Late Students';
}

class PresentStudents {
  final List<AttendanceRecord> students;
  final Color color = Colors.green;

  PresentStudents({required this.students});

  bool get isEmpty => students.isEmpty;
  int get count => students.length;
  String get title => 'Present Students';
}

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
      backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          centerTitle: true,
          title: const Text(
            '📱',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
      body: Column(
        children: [
          // Mobile Phone Style Action Section
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: _PhoneStyleButton(
                          onPressed: _isLoading ? null : _loadAttendanceData,
                          icon: Icons.refresh,
                          label: 'Refresh',
                          color: Colors.blue,
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PhoneStyleButton(
                          onPressed: _isLoading ? null : _sendMessageToAbsentStudents,
                          icon: Icons.message,
                          label: 'Message',
                          color: Colors.orange,
                          badge: _getAbsentStudents().length,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // More Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: _PhoneStyleButton(
                          onPressed: _isLoading ? null : _importCSV,
                          icon: Icons.upload,
                          label: 'Import',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PhoneStyleButton(
                          onPressed: _isLoading ? null : _exportCSV,
                          icon: Icons.download,
                          label: 'Export',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
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
                    : _AttendanceStatusCards(records: _records),
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

class _AttendanceStatusCards extends StatelessWidget {
  final List<AttendanceRecord> records;

  const _AttendanceStatusCards({required this.records});

  @override
  Widget build(BuildContext context) {
    final absentStudents = _createAbsentStudents();
    final lateStudents = _createLateStudents();
    final presentStudents = _createPresentStudents();
    
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Absent Students Card
        if (!absentStudents.isEmpty) ...[
          _StatusCard(
            title: absentStudents.title,
            count: absentStudents.count,
            color: absentStudents.color,
            students: absentStudents.students,
            onTap: () => _navigateToDetail(context, 'Absent', absentStudents.students, absentStudents.color),
          ),
          const SizedBox(height: 16),
        ],
        
        // Late Students Card
        if (!lateStudents.isEmpty) ...[
          _StatusCard(
            title: lateStudents.title,
            count: lateStudents.count,
            color: lateStudents.color,
            students: lateStudents.students,
            onTap: () => _navigateToDetail(context, 'Late', lateStudents.students, lateStudents.color),
          ),
          const SizedBox(height: 16),
        ],
        
        // Present Students Card
        if (!presentStudents.isEmpty) ...[
          _StatusCard(
            title: presentStudents.title,
            count: presentStudents.count,
            color: presentStudents.color,
            students: presentStudents.students,
            onTap: () => _navigateToDetail(context, 'Present', presentStudents.students, presentStudents.color),
          ),
        ],
      ],
    );
  }

  void _navigateToDetail(BuildContext context, String status, List<AttendanceRecord> students, Color color) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttendanceDetailScreen(
          status: status,
          students: students,
          statusColor: color,
        ),
      ),
    );
  }

  AbsentStudents _createAbsentStudents() {
    final students = _getStudentsByStatus('absent');
    return AbsentStudents(students: students);
  }

  LateStudents _createLateStudents() {
    final students = _getStudentsByStatus('late');
    return LateStudents(students: students);
  }

  PresentStudents _createPresentStudents() {
    final students = _getStudentsByStatus('present');
    return PresentStudents(students: students);
  }

  List<AttendanceRecord> _getStudentsByStatus(String status) {
    // Group students by their latest status
    final Map<String, AttendanceRecord> latestRecords = {};
    for (final record in records) {
      final key = '${record.studentName}__${record.studentId}';
      if (!latestRecords.containsKey(key) || 
          record.date.isAfter(latestRecords[key]!.date)) {
        latestRecords[key] = record;
      }
    }

    // Filter by status and sort alphabetically
    final students = latestRecords.values
        .where((record) => record.status.toLowerCase() == status)
        .toList();
    
    students.sort((a, b) => a.studentName.compareTo(b.studentName));
    return students;
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

// Status Section Widget for grouping students
class _StatusSection extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final List<AttendanceRecord> students;

  const _StatusSection({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile-optimized Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Students List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: students.map((student) => _StudentCard(
                student: student,
                statusColor: color,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Individual Student Card
class _StudentCard extends StatelessWidget {
  final AttendanceRecord student;
  final Color statusColor;

  const _StudentCard({
    required this.student,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mobile-optimized avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: statusColor.withOpacity(0.1),
            child: Text(
              student.studentName.isNotEmpty ? student.studentName[0] : '?',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Student info - mobile optimized
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
                const SizedBox(height: 4),
                Text(
                  student.studentId,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                // Mobile-friendly time display
                if (student.timeIn.isNotEmpty || student.timeOut.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${student.timeIn.isEmpty ? '-' : student.timeIn} • ${student.timeOut.isEmpty ? '-' : student.timeOut}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Date badge - mobile optimized
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatDate(student.date),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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
}

// Mobile Action Grid Widget
class _MobileActionGrid extends StatelessWidget {
  final VoidCallback? onImport;
  final VoidCallback? onExport;
  final VoidCallback? onTemplate;
  final VoidCallback? onClear;

  const _MobileActionGrid({
    required this.onImport,
    required this.onExport,
    required this.onTemplate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(
              child: _MobileActionButton(
                onPressed: onImport,
                icon: Icons.file_upload_outlined,
                label: 'Import CSV',
                color: Colors.blue[600]!,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MobileActionButton(
                onPressed: onExport,
                icon: Icons.file_download_outlined,
                label: 'Export CSV',
                color: Colors.green[600]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row
        Row(
          children: [
            Expanded(
              child: _MobileActionButton(
                onPressed: onTemplate,
                icon: Icons.description_outlined,
                label: 'Template',
                color: Colors.purple[600]!,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MobileActionButton(
                onPressed: onClear,
                icon: Icons.clear_all,
                label: 'Clear',
                color: Colors.red[600]!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Mobile Action Button Widget
class _MobileActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _MobileActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
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
      height: 52,
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
          isLoading ? 'Loading...' : 'Refresh Attendance',
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

// Phone Style Button Widget
class _PhoneStyleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final int? badge;

  const _PhoneStyleButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.isLoading = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // Increased height to prevent overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                Stack(
                  children: [
                    Icon(
                      isLoading ? Icons.hourglass_empty : icon,
                      color: Colors.white,
                      size: 22, // Slightly smaller icon
                    ),
                    if (badge != null && badge! > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$badge',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Flexible( // Use Flexible to prevent overflow
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Clickable Status Card Widget
class _StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final List<AttendanceRecord> students;
  final VoidCallback onTap;

  const _StatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.students,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${students.length} student${students.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Phone Style Section Widget
class _PhoneStyleSection extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final List<AttendanceRecord> students;

  const _PhoneStyleSection({
    required this.title,
    required this.count,
    required this.color,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Enhanced Section Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Enhanced Students List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: students.map((student) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PhoneStyleStudentCard(
                  student: student,
                  statusColor: color,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Phone Style Student Card
class _PhoneStyleStudentCard extends StatelessWidget {
  final AttendanceRecord student;
  final Color statusColor;

  const _PhoneStyleStudentCard({
    required this.student,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Enhanced avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                student.studentName.isNotEmpty ? student.studentName[0] : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  student.studentId,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                // Time info
                if (student.timeIn.isNotEmpty || student.timeOut.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${student.timeIn.isEmpty ? '-' : student.timeIn} • ${student.timeOut.isEmpty ? '-' : student.timeOut}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Enhanced date badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              _formatDate(student.date),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$mm/$dd';
  }
}