import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'qr_screen.dart';
import 'sections_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedSort = 'all'; // Default: show all students
  bool showSortMenu = false;
  bool isHovering = false;
  List<StudentAttendance> attendanceList = [
    StudentAttendance(name: 'John Doe', studentId: '2024-001', status: 'present', time: '08:30 AM'),
    StudentAttendance(name: 'Jane Smith', studentId: '2024-002', status: 'late', time: '09:15 AM'),
    StudentAttendance(name: 'Mike Johnson', studentId: '2024-003', status: 'absent', time: '--'),
    StudentAttendance(name: 'Sarah Wilson', studentId: '2024-004', status: 'present', time: '08:35 AM'),
    StudentAttendance(name: 'David Brown', studentId: '2024-005', status: 'late', time: '09:20 AM'),
    StudentAttendance(name: 'Emily Davis', studentId: '2024-006', status: 'absent', time: '--'),
    StudentAttendance(name: 'Chris Miller', studentId: '2024-007', status: 'present', time: '08:40 AM'),
    StudentAttendance(name: 'Lisa Garcia', studentId: '2024-008', status: 'present', time: '08:25 AM'),
    StudentAttendance(name: 'Tom Anderson', studentId: '2024-009', status: 'absent', time: '--'),
    StudentAttendance(name: 'Amy Taylor', studentId: '2024-010', status: 'late', time: '09:10 AM'),
    StudentAttendance(name: 'Ryan Lee', studentId: '2024-011', status: 'present', time: '08:45 AM'),
    StudentAttendance(name: 'Maya Patel', studentId: '2024-012', status: 'late', time: '09:05 AM'),
  ];

  int get presentCount => attendanceList.where((s) => s.status == 'present').length;
  int get absentCount => attendanceList.where((s) => s.status == 'absent').length;
  int get lateCount => attendanceList.where((s) => s.status == 'late').length;

  List<StudentAttendance> get filteredAttendanceList {
    if (selectedSort == 'all') {
      return attendanceList;
    } else {
      return attendanceList.where((student) => student.status == selectedSort).toList();
    }
  }

  void selectSort(String status) {
    setState(() {
      selectedSort = status;
      showSortMenu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Deep blue
              Color(0xFF3B82F6), // Blue
              Color(0xFF60A5FA), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // ACLC Logo
                    Image.asset(
                'lib/images/aclc_logo.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    // Attendance Title
                    Expanded(
                      child: Text(
                        'Attendance',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    // Notification Bell
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusCard(
                                'Present',
                                presentCount.toString(),
                                Icons.check_circle,
                                const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusCard(
                                'Late',
                                lateCount.toString(),
                                Icons.schedule,
                                const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusCard(
                                'Absent',
                                absentCount.toString(),
                                Icons.cancel,
                                const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Sort Section
                        Row(
                          children: [
                            Text(
                              'Attendance List',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E3A8A),
                                fontSize: 20,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _showSortSheet,
                              icon: const Icon(
                                Icons.sort,
                                color: Color(0xFF1E3A8A),
                                size: 24,
                              ),
                              splashRadius: 22,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Attendance List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredAttendanceList.length,
                          itemBuilder: (context, index) {
                            final student = filteredAttendanceList[index];
                            return _buildStudentCard(student);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: 1, // Attendance tab selected
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardScreen()));
            } else if (index == 2) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const QrScreen()));
            } else if (index == 3) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SectionsScreen()));
            } else if (index == 4) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Sections',
            ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              count,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentAttendance student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(student.status).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(student.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(student.status),
              color: _getStatusColor(student.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student.studentId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Time/Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                student.time,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(student.status),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(student.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(student.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort by',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                ),
                const SizedBox(height: 12),
                _buildSheetOption('All students', 'all', Icons.people_alt),
                _buildSheetOption('Present', 'present', Icons.check_circle),
                _buildSheetOption('Late', 'late', Icons.schedule),
                _buildSheetOption('Absent', 'absent', Icons.cancel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetOption(String label, String value, IconData icon) {
    final bool active = selectedSort == value;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: active ? const Color(0xFF1E3A8A) : Colors.grey[600]),
      title: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF1E3A8A) : Colors.black,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: active
          ? const Icon(Icons.check, color: Color(0xFF1E3A8A))
          : const SizedBox.shrink(),
      onTap: () {
        selectSort(value);
        Navigator.pop(context);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return const Color(0xFF10B981);
      case 'late':
        return const Color(0xFFF59E0B);
      case 'absent':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'late':
        return Icons.schedule;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

class StudentAttendance {
  final String name;
  final String studentId;
  final String status;
  final String time;

  StudentAttendance({
    required this.name,
    required this.studentId,
    required this.status,
    required this.time,
  });
}
