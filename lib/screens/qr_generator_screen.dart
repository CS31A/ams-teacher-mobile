import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'root_scaffold.dart';

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

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _selectedRoom; // 101..310

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

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _fmtTime(TimeOfDay? t) {
    if (t == null) return '';
    final int hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final String minute = t.minute.toString().padLeft(2, '0');
    final String period = t.period == DayPeriod.am ? 'AM' : 'PM';
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
    final String start = _fmtTime(_startTime);
    final String end = _fmtTime(_endTime);

    // Encode a simple JSON-like payload so the scanner can parse fields easily
    // Example: {"type":"attendance","subject":"Math","room":"ROOM 103","start":"9:00 AM","end":"10:00 AM","ts":1690000000000}
    return '{"type":"attendance","subject":"$subject","room":"$room","start":"$start","end":"$end","ts":${DateTime.now().millisecondsSinceEpoch}}';
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime first = DateTime(now.year - 1);
    final DateTime last = DateTime(now.year + 2);
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: _selectedDate ?? now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
            // Controls inside a clean card
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool narrow = constraints.maxWidth < 720;
                        Widget dateBtn = SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            style: ButtonStyle(
                              alignment: Alignment.centerLeft,
                              minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
                            ),
                            icon: const Icon(Icons.event),
                            label: Text(_selectedDate == null ? 'Pick date' : _fmtDate(_selectedDate)),
                          ),
                        );
                        Widget startBtn = SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _pickTime(isStart: true),
                            style: ButtonStyle(
                              alignment: Alignment.centerLeft,
                              minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
                            ),
                            icon: const Icon(Icons.schedule),
                            label: Text(_startTime == null ? 'Start time' : _fmtTime(_startTime)),
                          ),
                        );
                        Widget endBtn = SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _pickTime(isStart: false),
                            style: ButtonStyle(
                              alignment: Alignment.centerLeft,
                              minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
                            ),
                            icon: const Icon(Icons.schedule_outlined),
                            label: Text(_endTime == null ? 'End time' : _fmtTime(_endTime)),
                          ),
                        );
                        if (narrow) {
                          return Column(
                            children: [
                              dateBtn,
                              const SizedBox(height: 12),
                              startBtn,
                              const SizedBox(height: 12),
                              endBtn,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: dateBtn),
                            const SizedBox(width: 12),
                            Expanded(child: startBtn),
                            const SizedBox(width: 12),
                            Expanded(child: endBtn),
                          ],
                        );
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
                setState(() {}); // rebuild QR
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR'),
            ),
          ],
        ),
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



