import 'package:flutter/cupertino.dart';
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
  final TextEditingController _roomController = TextEditingController();
  final List<String> _subjects = <String>[
    'Select Subject',
    'Mathematics 101',
    'Science 201',
    'History 301',
  ];
  String _selectedSubject = 'Select Subject';

  int _startHour = 9;
  int _startMinute = 15;
  int _endHour = 10;
  int _endMinute = 15;

  bool _showResult = false;

  // Validation method to check if all fields are filled
  bool get _isFormValid {
    return _selectedSubject != 'Select Subject' && 
           _roomController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Add listener to room controller to trigger rebuild when text changes
    _roomController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
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
                    // Logo (replaces back button)
                    Image.asset(
                                      'lib/images/aclc_logo.png',

                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _showResult ? 'Attendance QR Code' : 'Generate QR',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the layout
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: _showResult ? _buildResult(context) : _buildForm(context),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSubject,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: _subjects
                    .map((s) => DropdownMenuItem<String>(
                          value: s,
                          child: Text(s),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSubject = v ?? _selectedSubject),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Classroom Number',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _roomController,
            decoration: InputDecoration(
              hintText: 'Enter classroom number',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B82F6)),
              ),
            ),
          ),

          const SizedBox(height: 20),
          _buildTimePickerCard(title: 'Start Time',
              initialHour: _startHour,
              initialMinute: _startMinute,
              onHourChanged: (v) => setState(() => _startHour = v),
              onMinuteChanged: (v) => setState(() => _startMinute = v)),

          const SizedBox(height: 16),
          _buildTimePickerCard(title: 'End Time',
              initialHour: _endHour,
              initialMinute: _endMinute,
              onHourChanged: (v) => setState(() => _endHour = v),
              onMinuteChanged: (v) => setState(() => _endMinute = v)),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid ? const Color(0xFF1E3A8A) : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isFormValid ? () => setState(() => _showResult = true) : null,
              child: const Text('Generate QR Code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerCard({
    required String title,
    required int initialHour,
    required int initialMinute,
    required ValueChanged<int> onHourChanged,
    required ValueChanged<int> onMinuteChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildPicker(
                  controller: FixedExtentScrollController(initialItem: initialHour),
                  count: 24,
                  onChanged: onHourChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPicker(
                  controller: FixedExtentScrollController(initialItem: initialMinute),
                  count: 60,
                  onChanged: onMinuteChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required int count,
    required ValueChanged<int> onChanged,
  }) {
    return Listener(
      onPointerSignal: (_) {},
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 40,
        magnification: 1.15,
        squeeze: 1.05,
        useMagnifier: true,
        // Transparent overlay so item content colors remain visible
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: Colors.transparent,
        ),
        onSelectedItemChanged: onChanged,
        children: List.generate(
          count,
          (i) => Center(child: _wheelItem(i.toString().padLeft(2, '0'))),
        ),
      ),
    );
  }

  Widget _wheelItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 240,
            width: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 180, color: Color(0xFF1F2937)),
            ),
          ),

          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Subject', _selectedSubject == 'Select Subject' ? '—' : _selectedSubject),
                _detailRow('Room', _roomController.text.isEmpty ? '—' : _roomController.text),
                _detailRow('Start Time', _formatTime(_startHour, _startMinute)),
                _detailRow('End Time', _formatTime(_endHour, _endMinute)),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _showSnack('Share tapped'),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _showSnack('Saved to gallery'),
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _showResult = false),
            child: const Text('Generate another QR'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final int h = hour % 24;
    final String amPm = h >= 12 ? 'PM' : 'AM';
    final int std = h % 12 == 0 ? 12 : h % 12;
    final String mm = minute.toString().padLeft(2, '0');
    return '$std:$mm $amPm';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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


