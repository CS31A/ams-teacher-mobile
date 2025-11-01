import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedSchedule;
  String _viewMode = 'list'; // 'list' or 'grid'
  
  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // Mock schedules for UI
  final List<Map<String, dynamic>> _schedules = [
    {
      'code': 'CS11A',
      'name': 'Computing Programming 1',
      'days': 'Monday, Thursday',
      'time': '7:30 AM - 10:30 AM',
    },
    {
      'code': 'CS21A',
      'name': 'Data Structures',
      'days': 'Mon, Thu',
      'time': '10:30 AM - 12:30 PM',
    },
    {
      'code': 'IT21B',
      'name': 'Introduction to Programming',
      'days': 'Tue, Fri',
      'time': '12:30 PM - 3:30 PM',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  String _getCurrentDate() {
    final now = DateTime.now();
    final monthName = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];
    return 'Today, ${monthName[now.month - 1]} ${now.day}';
  }

  void _showCalendarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calendar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Calendar
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  Navigator.pop(context);
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  outsideDaysVisible: false,
                  outsideTextStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.week: 'Week',
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  
                  // Session Date Card
                  _buildSessionDateCard(),
                  const SizedBox(height: 24),
                  
                  // View Toggle
                  _buildViewToggle(),
                  const SizedBox(height: 20),
                  
                  // Schedule List
                  _buildScheduleList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            _buildCreateButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'lib/images/aclc_logo.png',
          width: 80,
          height: 80,
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
          'Select a schedule to create a class session.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search sections...',
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
    );
  }

  Widget _buildSessionDateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, color: Colors.blue[900], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentDate(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_calendar_rounded, color: Colors.blue[900]),
            onPressed: () => _showCalendarModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _viewMode = 'list';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _viewMode == 'list' ? Colors.blue[900] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.view_list_rounded,
                      color: _viewMode == 'list' ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'List View',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _viewMode == 'list' ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _viewMode = 'grid';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _viewMode == 'grid' ? Colors.blue[900] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      color: _viewMode == 'grid' ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Grid View',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _viewMode == 'grid' ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_viewMode == 'grid') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          final isSelected = _selectedSchedule == '${schedule['code']} - ${schedule['name']}';
          return Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSchedule = '${schedule['code']} - ${schedule['name']}';
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: isSelected ? Colors.white : Colors.blue[900],
                          size: 24,
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isSelected ? Colors.white : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${schedule['code']} - ${schedule['name']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        '${schedule['days']} ${schedule['time']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Column(
        children: _schedules.map((schedule) {
          final isSelected = _selectedSchedule == '${schedule['code']} - ${schedule['name']}';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSchedule = '${schedule['code']} - ${schedule['name']}';
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Colors.blue[900], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${schedule['code']} - ${schedule['name']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${schedule['days']} ${schedule['time']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: '${schedule['code']} - ${schedule['name']}',
                      groupValue: _selectedSchedule,
                      onChanged: (value) {
                        setState(() {
                          _selectedSchedule = value;
                        });
                      },
                      activeColor: Colors.blue[900],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildCreateButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedSchedule != null ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionDetailsScreen(
                    subject: _selectedSchedule!,
                    scheduleTime: _schedules.firstWhere((s) => 
                      '${s['code']} - ${s['name']}' == _selectedSchedule
                    )['time'],
                  ),
                ),
              );
            } : null,
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

class SessionDetailsScreen extends StatefulWidget {
  final String subject;
  final String scheduleTime;

  const SessionDetailsScreen({
    super.key,
    required this.subject,
    required this.scheduleTime,
  });

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  final TextEditingController _attendanceCutoffController = TextEditingController();
  final List<String> _rooms = [
    'Room 301 (Scheduled)',
    'Room 302',
    'Room 303',
    'Short Course Laboratory',
  ];
  
  String? _selectedActualRoom;
  String _scheduledRoom = 'Room 301 (Scheduled)';
  String _currentRoom = 'Room 301 (Scheduled)';

  @override
  void initState() {
    super.initState();
    _selectedActualRoom = _rooms.first;
  }
  
  bool get _hasRoomChanged => _currentRoom != _scheduledRoom;

  @override
  void dispose() {
    _attendanceCutoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Session Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'lib/images/aclc_logo.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Course Title
                    Center(
                      child: Text(
                        widget.subject,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Session Information
                    _buildInfoRow(
                      icon: Icons.access_time,
                      mainText: widget.scheduleTime,
                      subText: '90 minutes',
                      iconColor: Colors.blue[900]!,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildInfoRow(
                      icon: Icons.location_on,
                      mainText: 'Short Course Laboratory',
                      subText: 'Originally Room 301',
                      iconColor: Colors.blue[900]!,
                      badge: _hasRoomChanged ? 'Room Changed' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildInfoRow(
                      icon: Icons.play_circle,
                      mainText: 'Session Active',
                      subText: 'Status',
                      iconColor: Colors.green[700]!,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildInfoRow(
                      icon: Icons.history,
                      mainText: '9:02 AM',
                      subText: 'Session Start Time',
                      iconColor: Colors.blue[900]!,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildInfoRow(
                      icon: Icons.person,
                      mainText: 'Jovelyn Comaingking',
                      subText: 'Instructor',
                      iconColor: Colors.blue[900]!,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showStartSessionModal(context);
                        },
                        icon: const Icon(Icons.qr_code_2, size: 24),
                        label: const Text(
                          'View Generate QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: End Session
                        },
                        icon: const Icon(Icons.stop_circle_outlined, size: 24),
                        label: const Text(
                          'End Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String mainText,
    required String subText,
    required Color iconColor,
    String? badge,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainText,
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
                    subText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStartSessionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Start Session',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirm session details before starting.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Actual Room Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actual Room (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedActualRoom,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: _rooms.map((room) => DropdownMenuItem<String>(
                      value: room,
                      child: Text(room),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedActualRoom = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Attendance Cutoff Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Cutoff (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _attendanceCutoffController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 15',
                    suffixText: 'minutes',
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Skip & Start session
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Skip & Start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Confirm & Start session
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm & Start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}