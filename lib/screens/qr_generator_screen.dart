import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  // Inputs
  final List<String> _subjects = const [
    'INFORMATION ASSURANCE',
    'PAGSASALING PAMPANITIKAN',
    'SOCIAL AND PROFESSION',
    'COMPUTER ARCHITECTURE',
    'SOFTWARE ENGINEERING',
    'MOBILE PROGRAMMING',
    'AUTOMATA THEORY AND COMPUTATION',
    'PROGRAMMMING LANGUAGE',
  ];

  String? _selectedSubject;
  final TextEditingController _customSubjectController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _selectedRoom; // numeric room (e.g. 103)

  @override
  void dispose() {
    _customSubjectController.dispose();
    super.dispose();
  }

  List<int> _generateRooms() {
    // Rooms 101 to 310 inclusive
    final List<int> rooms = [];
    for (int room = 101; room <= 310; room++) {
      rooms.add(room);
    }
    return rooms;
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
    final String start = _formatTime(_startTime);
    final String end = _formatTime(_endTime);

    // Encode a simple JSON-like payload so the scanner can parse fields easily
    // Example: {"type":"attendance","subject":"Math","room":"ROOM 103","start":"9:00 AM","end":"10:00 AM","ts":1690000000000}
    return '{"type":"attendance","subject":"$subject","room":"$room","start":"$start","end":"$end","ts":${DateTime.now().millisecondsSinceEpoch}}';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay initial = isStart
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? TimeOfDay.now());
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Generate a QR Code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: QrImageView(
                    data: _buildQrData(),
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Controls BELOW the QR
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    items: _subjects
                        .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _selectedSubject = v;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedRoom,
                    items: _generateRooms()
                        .map((r) => DropdownMenuItem<int>(
                              value: r,
                              child: Text('ROOM $r'),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Room',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _selectedRoom = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_selectedSubject == 'Custom…') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customSubjectController,
                decoration: const InputDecoration(
                  labelText: 'Custom subject',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: true),
                    icon: const Icon(Icons.schedule),
                    label: Text(_startTime == null ? 'Start time' : _formatTime(_startTime)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: false),
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(_endTime == null ? 'End time' : _formatTime(_endTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() {}); // rebuild QR with latest selections
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('Update QR'),
            ),
          ],
        ),
      ),
    );
  }
}



