import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'sections_screen.dart';

class QrScreen extends StatefulWidget {
  final Map<String, dynamic>? currentClass;
  final DateTime? currentClassEnd;
  
  const QrScreen({
    super.key,
    this.currentClass,
    this.currentClassEnd,
  });

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> with SingleTickerProviderStateMixin {
  // Session state
  bool _sessionStarted = false;
  Duration _classTimeLeft = Duration.zero;
  
  // Animation
  late AnimationController _animationController;
  
  // Form state
  final TextEditingController _roomController = TextEditingController();
  final FocusNode _roomFocusNode = FocusNode();
  List<String> _filteredRooms = [];
  bool _showRoomSuggestions = false;
  
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
  
  // Generate all available rooms
  List<String> _getAllRooms() {
    List<String> rooms = [];
    // 100 series (101-110)
    for (int i = 101; i <= 110; i++) {
      rooms.add(i.toString());
    }
    // 200 series (201-210)
    for (int i = 201; i <= 210; i++) {
      rooms.add(i.toString());
    }
    // 300 series (301-310)
    for (int i = 301; i <= 310; i++) {
      rooms.add(i.toString());
    }
    // SLAB rooms
    for (int i = 1; i <= 5; i++) {
      rooms.add('SLAB $i');
    }
    return rooms;
  }

  // Validation method to check if all fields are filled
  bool get _isFormValid {
    return _selectedSubject != 'Select Subject' && 
           _roomController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for logo
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Add listener to room controller to filter suggestions
    _roomController.addListener(_filterRooms);
    
    // Initialize with current class data if available
    if (widget.currentClass != null) {
      _selectedSubject = widget.currentClass!['subjectName'] ?? 'Select Subject';
      _roomController.text = widget.currentClass!['room'] ?? '';
    }
  }
  
  void _filterRooms() {
    final query = _roomController.text.trim().toUpperCase();
    
    if (query.isEmpty) {
      setState(() {
        _showRoomSuggestions = false;
        _filteredRooms = [];
      });
      return;
    }
    
    final allRooms = _getAllRooms();
    final filtered = allRooms.where((room) {
      return room.toUpperCase().startsWith(query);
    }).toList();
    
    setState(() {
      _filteredRooms = filtered;
      _showRoomSuggestions = filtered.isNotEmpty;
    });
  }
  
  void _selectRoom(String room) {
    _roomController.text = room;
    setState(() {
      _showRoomSuggestions = false;
      _filteredRooms = [];
    });
    _roomFocusNode.unfocus();
  }
  
  void _startSession() {
    setState(() {
      _sessionStarted = true;
    });
    _startCountdown();
  }
  
  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _sessionStarted) {
        final now = DateTime.now();
        
        if (widget.currentClassEnd != null && now.isBefore(widget.currentClassEnd!)) {
          _classTimeLeft = widget.currentClassEnd!.difference(now);
        } else {
          _classTimeLeft = Duration.zero;
        }
        
      setState(() {});
        _startCountdown();
      }
    });
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _roomController.dispose();
    _roomFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show start session screen if session hasn't started
    if (!_sessionStarted) {
      return _buildStartSessionScreen(context);
    }
    
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
                  child: _showResult ? _buildResult(context) : _buildSessionContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildStartSessionScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with Animated Light Effect
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer rotating light circles
                      Transform.rotate(
                        angle: _animationController.value * 2 * 3.14159,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Second rotating light (opposite direction)
                      Transform.rotate(
                        angle: -_animationController.value * 2 * 3.14159,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Logo container
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'lib/images/aclc_logo.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Current Class Info
              if (widget.currentClass != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.currentClass!['subjectName'] ?? 'Current Class',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.currentClass!['subjectCode'] ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.currentClass!['room'] ?? 'TBA'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
              
              // Start Session Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _startSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Start Session',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Back to Dashboard
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
                child: Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSessionContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer Card
          if (widget.currentClass != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Class Time Remaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDuration(_classTimeLeft),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.currentClass!['subjectName'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.currentClass!['room'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Generate QR Form
          _buildForm(context),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _roomController,
                focusNode: _roomFocusNode,
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
              // Room suggestions dropdown
              if (_showRoomSuggestions && _filteredRooms.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = _filteredRooms[index];
                      return InkWell(
                        onTap: () => _selectRoom(room),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.meeting_room,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                room,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
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


