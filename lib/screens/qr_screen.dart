import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'sections_screen.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  // Form state
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  bool _scheduleSelected = false;
  
  // Mock schedules for UI
  final List<String> _schedules = [
    'Software Engineering 1',
    'Computing Programming 1',
    'Information Assurance',
    'Data Structures',
    'Database Systems',
  ];
  
  // Mock upcoming sessions
  final List<Map<String, dynamic>> _upcomingSessions = [
    {
      'subject': 'Software Engineering 1',
      'time': '10:00 AM',
      'date': 'Today',
      'duration': '45 min',
    },
    {
      'subject': 'Computing Programming 1',
      'time': '1:30 PM',
      'date': 'Wed, Oct 25',
      'duration': '90 min',
    },
    {
      'subject': 'Information Assurance',
      'time': '9:15 AM',
      'date': 'Thu, Oct 26',
      'duration': '60 min',
    },
  ];

  @override
  void dispose() {
    _scheduleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 32),
          
          // Assigned Schedule Section
          _buildAssignedScheduleSection(),
          const SizedBox(height: 32),
          
          // Upcoming Sessions Section
          _buildUpcomingSessionsSection(),
          const SizedBox(height: 32),
          
          // Create Session Button
          _buildCreateButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.school_rounded,
            size: 48,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create Session',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a schedule to begin.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignedScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Assigned Schedule',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            TextField(
              controller: _scheduleController,
              readOnly: true,
              onTap: () => _showSchedulePicker(),
              decoration: InputDecoration(
                hintText: 'Select schedule',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            if (_scheduleSelected)
              Positioned(
                right: 50,
                top: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'View Full Calendar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSessionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Sessions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search sessions...',
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        ..._upcomingSessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['subject'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      session['date'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (session['duration'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        session['duration'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            session['time'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement create session action
          _showSnackBar('Session created successfully!');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Create Session',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSchedulePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._schedules.map((schedule) => ListTile(
              title: Text(schedule),
              onTap: () {
                setState(() {
                  _scheduleController.text = schedule;
                  _scheduleSelected = true;
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[900],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
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
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardScreen()));
          } else if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AttendanceScreen()));
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
    );
  }
}
