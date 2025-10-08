import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:qr_flutter/qr_flutter.dart';
import 'root_scaffold.dart';

class _TimeSlot {
  final DateTime start;
  final DateTime end;
  final String label;

  const _TimeSlot({required this.start, required this.end, required this.label});
}

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  // Subject dropdown with a custom entry option
  final List<String> _subjects = const [
    'Information Assurance',
    'Programming Language',
    'Pagpapahalagang Pampanitikan',
    'Social and Professional Issues',
    'Computer Architecture',
    'Software Engineering',
    'Automata Theory',
    'Mobile Programming',
    'Custom…',
  ];
  String? _selectedSubject;
  final TextEditingController _customSubjectController = TextEditingController();

  int? _selectedRoom; // 101..310
  // Preset 1h30m time slots dropdown (e.g., 7:30 AM - 9:00 AM, ... until 12:00 PM)
  late final List<_TimeSlot> _slots = _generateNinetyMinuteSlots();
  int? _selectedSlotIndex; // index into _slots
  bool _showQrOverlay = false;

  @override
  void dispose() {
    _customSubjectController.dispose();
    super.dispose();
  }
  List<int> _rooms() {
    final List<int> r = [];
    for (int i = 101; i <= 310; i++) {
      r.add(i);
    }
    return r;
  }

  String _formatHm(int hour24, int minute) {
    final bool isPm = hour24 >= 12;
    final int hour12 = ((hour24 % 12) == 0) ? 12 : (hour24 % 12);
    final String mm = minute.toString().padLeft(2, '0');
    final String period = isPm ? 'PM' : 'AM';
    return '$hour12:$mm $period';
  }

  List<_TimeSlot> _generateNinetyMinuteSlots() {
    final List<_TimeSlot> slots = [];
    
    // Add hourly slots starting at 7:00, 8:00, 9:00, 10:00, 11:00 AM
    for (int hour = 7; hour <= 11; hour++) {
      final DateTime start = DateTime(2000, 1, 1, hour, 0); // Start at top of hour
      final DateTime end = start.add(const Duration(minutes: 60));
      final String label = '${_formatHm(start.hour, start.minute)} - ${_formatHm(end.hour, end.minute)}';
      slots.add(_TimeSlot(start: start, end: end, label: label));
    }
    
    // Add 1-hour slots starting from 7:30 AM
    DateTime start = DateTime(2000, 1, 1, 7, 30); // 7:30 AM
    final DateTime lastEnd = DateTime(2000, 1, 1, 12, 0); // 12:00 PM
    
    // Generate 1-hour slots (7:30-8:30, 8:30-9:30, etc.)
    while (true) {
      final DateTime end = start.add(const Duration(minutes: 60));
      if (end.isAfter(lastEnd)) break;
      final String label = '${_formatHm(start.hour, start.minute)} - ${_formatHm(end.hour, end.minute)}';
      slots.add(_TimeSlot(start: start, end: end, label: label));
      start = end;
    }
    
    // Add 90-minute slots starting from 7:30 AM
    start = DateTime(2000, 1, 1, 7, 30); // Reset to 7:30 AM
    while (true) {
      final DateTime end = start.add(const Duration(minutes: 90));
      if (end.isAfter(lastEnd)) break;
      final String label = '${_formatHm(start.hour, start.minute)} - ${_formatHm(end.hour, end.minute)}';
      slots.add(_TimeSlot(start: start, end: end, label: label));
      start = end;
    }
    
    // Add 2-hour slots starting from 7:30 AM
    start = DateTime(2000, 1, 1, 7, 30); // Reset to 7:30 AM
    while (true) {
      final DateTime end = start.add(const Duration(minutes: 120));
      if (end.isAfter(lastEnd)) break;
      final String label = '${_formatHm(start.hour, start.minute)} - ${_formatHm(end.hour, end.minute)}';
      slots.add(_TimeSlot(start: start, end: end, label: label));
      start = end;
    }
    
    // Sort slots by start time
    slots.sort((a, b) => a.start.compareTo(b.start));
    
    return slots;
  }

  String _effectiveSubject() {
    if (_selectedSubject == 'Custom…') {
      return _customSubjectController.text.trim().isEmpty
          ? 'Custom'
          : _customSubjectController.text.trim();
    }
    return _selectedSubject ?? '';
  }

  String _buildQrData() {
    final String subject = _effectiveSubject();
    final String room = _selectedRoom == null ? '' : 'ROOM $_selectedRoom';
    final String start = _selectedSlotIndex == null
        ? ''
        : _formatHm(_slots[_selectedSlotIndex!].start.hour, _slots[_selectedSlotIndex!].start.minute);
    final String end = _selectedSlotIndex == null
        ? ''
        : _formatHm(_slots[_selectedSlotIndex!].end.hour, _slots[_selectedSlotIndex!].end.minute);

    // Encode a simple JSON-like payload so the scanner can parse fields easily
    // Example: {"type":"attendance","subject":"Math","room":"ROOM 103","start":"9:00 AM","end":"10:00 AM","ts":1690000000000}
    return '{"type":"attendance","subject":"$subject","room":"$room","start":"$start","end":"$end","ts":${DateTime.now().millisecondsSinceEpoch}}';
  }

  // Date and time pickers removed as requested

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Generator'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Generate a QR Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Controls inside a clean card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool narrow = constraints.maxWidth < 520;
                        final Widget subjectField = DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          items: _subjects
                              .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                              .toList(),
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.menu_book_outlined),
                          ),
                          onChanged: (v) {
                            setState(() {
                              _selectedSubject = v;
                            });
                          },
                        );
                        final Widget roomField = DropdownButtonFormField<int>(
                          value: _selectedRoom,
                          items: _rooms()
                              .map((r) => DropdownMenuItem<int>(value: r, child: Text('ROOM $r')))
                              .toList(),
                          decoration: const InputDecoration(
                            labelText: 'Room',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                          ),
                          onChanged: (v) {
                            setState(() {
                              _selectedRoom = v;
                            });
                          },
                        );
                        if (narrow) {
                          return Column(
                            children: [subjectField, const SizedBox(height: 12), roomField],
                          );
                        }
                        return Row(children: [
                          Expanded(child: subjectField),
                          const SizedBox(width: 12),
                          Expanded(child: roomField),
                        ]);
                      },
                    ),
                    if (_selectedSubject == 'Custom…') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customSubjectController,
                        decoration: const InputDecoration(
                          labelText: 'Custom subject',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 12),
                        // Time slot dropdown with placeholder
                        DropdownButtonFormField<int>(
                          value: _selectedSlotIndex,
                          hint: const Text('Select time slot'),
                          items: [
                            for (int i = 0; i < _slots.length; i++)
                              DropdownMenuItem<int>(
                                value: i,
                                child: Text(_slots[i].label),
                              ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Time slot',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          onChanged: (v) {
                            setState(() {
                              _selectedSlotIndex = v;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showQrOverlay = true;
                    });
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Generate QR'),
                ),
              ],
            ),
          ),
          if (_showQrOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showQrOverlay = false),
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _showQrOverlay = false),
                              ),
                            ),
                            QrImageView(
                              data: _buildQrData(),
                              version: QrVersions.auto,
                              size: 260,
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0, // highlight Home by default
        onDestinationSelected: (i) {
          // Replace this screen with the main scaffold at the chosen tab
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => RootScaffold(initialIndex: i)),
            (route) => false,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}



