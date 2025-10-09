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

  String? _selectedRoom; // Room numbers and SLAB rooms
  String? _roomFilter; // Filter for rooms (1, 2, 3, SLAB)
  // Preset 1h30m time slots dropdown (e.g., 7:30 AM - 9:00 AM, ... until 12:00 PM)
  late final List<_TimeSlot> _slots = _generateNinetyMinuteSlots();
  int? _selectedSlotIndex; // index into _slots
  bool _showQrOverlay = false;

  // QR History storage
  final List<Map<String, dynamic>> _qrHistory = [];

  @override
  void dispose() {
    _customSubjectController.dispose();
    super.dispose();
  }
  List<String> _rooms() {
    final List<String> rooms = [];
    
    // Add room ranges 101-106, 201-206, 301-306
    for (int floor = 1; floor <= 3; floor++) {
      for (int room = 1; room <= 6; room++) {
        rooms.add('${floor}0$room');
      }
    }
    
    // Add SLAB rooms
    for (int i = 1; i <= 5; i++) {
      rooms.add('SLAB$i');
    }
    
    return rooms;
  }

  List<String> _filteredRooms() {
    if (_roomFilter == null) {
      return _rooms();
    }
    
    if (_roomFilter == 'SLAB') {
      return _rooms().where((room) => room.startsWith('SLAB')).toList();
    }
    
    // Filter by floor number
    return _rooms().where((room) => room.startsWith(_roomFilter!)).toList();
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

  bool _isFormValid() {
    final subject = _effectiveSubject();
    return subject.isNotEmpty && 
           _selectedRoom != null && 
           _selectedSlotIndex != null;
  }

  String? _getSubjectHelperText() {
    if (_selectedSubject == null) {
      return 'Select a subject from the list';
    }
    
    if (_selectedSubject == 'Custom…') {
      if (_customSubjectController.text.trim().isNotEmpty) {
        return '✓ Selected: ${_customSubjectController.text.trim()}';
      }
      return 'Enter custom subject name';
    }
    
    return '✓ Selected: $_selectedSubject';
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

  void _saveToHistory() {
    final String subject = _effectiveSubject();
    final String room = _selectedRoom == null ? '' : 'ROOM $_selectedRoom';
    final String timeSlot = _selectedSlotIndex == null
        ? ''
        : _slots[_selectedSlotIndex!].label;
    
    final Map<String, dynamic> qrEntry = {
      'subject': subject,
      'room': room,
      'timeSlot': timeSlot,
      'timestamp': DateTime.now(),
      'qrData': _buildQrData(),
    };
    
    setState(() {
      _qrHistory.insert(0, qrEntry); // Add to beginning of list
      // Keep only last 10 QR codes
      if (_qrHistory.length > 10) {
        _qrHistory.removeLast();
      }
    });
  }

  void _showQrHistory() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.blue[600], size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'QR Code History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // History List
              Flexible(
                child: _qrHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No QR codes generated yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _qrHistory.length,
                        itemBuilder: (context, index) {
                          final entry = _qrHistory[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.qr_code,
                                  color: Colors.blue[600],
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                entry['subject'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('${entry['room']} • ${entry['timeSlot']}'),
                                  Text(
                                    _formatHistoryDate(entry['timestamp']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.qr_code_scanner),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _showQrOverlay = true;
                                  });
                                },
                                tooltip: 'Regenerate QR',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatHistoryDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? filterValue) {
    final bool isSelected = _roomFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _roomFilter = filterValue;
          _selectedRoom = null; // Clear selection when filter changes
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
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
                          hint: Text(
                            'Select subject',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          isExpanded: true,
                          items: _subjects
                              .map((s) => DropdownMenuItem<String>(
                                value: s, 
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(child: Text(s)),
                                  ],
                                ),
                              ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            labelStyle: TextStyle(
                              color: _selectedSubject == null ? Colors.grey[600] : Colors.blue[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _selectedSubject == null 
                                    ? Colors.grey[300]! 
                                    : Colors.blue[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _selectedSubject == null 
                                    ? Colors.grey[300]! 
                                    : Colors.blue[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue[600]!,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.menu_book_outlined,
                              color: _selectedSubject == null 
                                  ? Colors.grey[600] 
                                  : Colors.blue[600],
                            ),
                            helperText: _getSubjectHelperText(),
                            helperStyle: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 8,
                          onChanged: (v) {
                            setState(() {
                              _selectedSubject = v;
                            });
                          },
                        );
                        
                        // Room filter buttons
                        final Widget roomFilterButtons = Row(
                          children: [
                            Text(
                              'Filter: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildFilterChip('1', '1'),
                                _buildFilterChip('2', '2'),
                                _buildFilterChip('3', '3'),
                                _buildFilterChip('SLAB', 'SLAB'),
                              ],
                            ),
                          ],
                        );
                        
                        final Widget roomField = DropdownButtonFormField<String>(
                          value: _selectedRoom,
                          hint: Text(
                            'Select room',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          isExpanded: true,
                          items: _filteredRooms()
                              .map((r) => DropdownMenuItem<String>(
                                value: r, 
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.meeting_room_outlined,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text('ROOM $r'),
                                  ],
                                ),
                              ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: _selectedRoom == null ? 'Room' : null,
                            labelStyle: TextStyle(
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _selectedRoom == null 
                                    ? Colors.grey[300]! 
                                    : Colors.blue[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _selectedRoom == null 
                                    ? Colors.grey[300]! 
                                    : Colors.blue[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue[600]!,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.meeting_room_outlined,
                              color: _selectedRoom == null 
                                  ? Colors.grey[600] 
                                  : Colors.blue[600],
                            ),
                            helperText: _selectedRoom != null
                                ? '✓ Selected: ROOM $_selectedRoom'
                                : null,
                            helperStyle: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 8,
                          onChanged: (v) {
                            setState(() {
                              _selectedRoom = v;
                            });
                          },
                        );
                        if (narrow) {
                          return Column(
                            children: [
                              subjectField, 
                              const SizedBox(height: 12), 
                              roomFilterButtons,
                              const SizedBox(height: 8),
                              roomField
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Row(children: [
                              Expanded(child: subjectField),
                              const SizedBox(width: 12),
                              Expanded(child: roomField),
                            ]),
                            const SizedBox(height: 12),
                            roomFilterButtons,
                          ],
                        );
                      },
                    ),
                    if (_selectedSubject == 'Custom…') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customSubjectController,
                        decoration: InputDecoration(
                          labelText: 'Custom subject',
                          labelStyle: TextStyle(
                            color: _customSubjectController.text.trim().isEmpty 
                                ? Colors.grey[600] 
                                : Colors.blue[600],
                          ),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.edit_outlined),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          helperText: _customSubjectController.text.trim().isNotEmpty
                              ? 'Custom subject entered'
                              : 'Enter your custom subject name',
                          helperStyle: TextStyle(
                            color: _customSubjectController.text.trim().isNotEmpty
                                ? Colors.blue[600]
                                : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 12),
                        // Time slot dropdown with placeholder
                        DropdownButtonFormField<int>(
                          value: _selectedSlotIndex,
                          hint: Text(
                            'Select time slot',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          isExpanded: true,
                          items: [
                            for (int i = 0; i < _slots.length; i++)
                              DropdownMenuItem<int>(
                                value: i,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(child: Text(_slots[i].label)),
                                  ],
                                ),
                              ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Time slot',
                            labelStyle: TextStyle(
                              color: _selectedSlotIndex == null ? Colors.grey[600] : Colors.blue[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _selectedSlotIndex == null 
                                    ? Colors.grey[300]! 
                                    : Colors.blue[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _selectedSlotIndex == null 
                                    ? Colors.grey[300]! 
                                    : Colors.blue[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue[600]!,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.access_time,
                              color: _selectedSlotIndex == null 
                                  ? Colors.grey[600] 
                                  : Colors.blue[600],
                            ),
                            helperText: _selectedSlotIndex != null 
                                ? '✓ Selected: ${_slots[_selectedSlotIndex!].label}' 
                                : 'Select a time slot for your class',
                            helperStyle: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 8,
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
                  onPressed: _isFormValid() ? () {
                    FocusScope.of(context).unfocus();
                    _saveToHistory(); // Save to history before showing
                    setState(() {
                      _showQrOverlay = true;
                    });
                  } : null,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Generate QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid() ? Colors.blue[600] : Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: Colors.black.withOpacity(0.3)),
                    ),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with close and history buttons
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.qr_code_2,
                                      color: Colors.blue[700],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'QR Code Generated',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                        Text(
                                          'Scan to mark attendance',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // History button
                                  IconButton(
                                    onPressed: _showQrHistory,
                                    icon: Icon(
                                      Icons.history,
                                      color: Colors.blue[600],
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blue[600],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    tooltip: 'View QR History',
                                  ),
                                  const SizedBox(width: 8),
                                  // Close button
                                  IconButton(
                                    onPressed: () => setState(() => _showQrOverlay = false),
                                icon: const Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: Colors.grey[600],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Subject info
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.menu_book_outlined,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Subject',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _effectiveSubject(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // QR Code
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: QrImageView(
                              data: _buildQrData(),
                              version: QrVersions.auto,
                                      size: 280,
                              backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Additional info
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoChip(
                                          Icons.meeting_room_outlined,
                                          _selectedRoom == null ? 'No Room' : 'ROOM $_selectedRoom',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildInfoChip(
                                          Icons.access_time,
                                          _selectedSlotIndex == null 
                                              ? 'No Time Slot' 
                                              : _slots[_selectedSlotIndex!].label,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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



