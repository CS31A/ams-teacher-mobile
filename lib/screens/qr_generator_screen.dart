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

  int? _selectedRoom; // 101..310
  // Hour filter for schedules (e.g., 7 => show 7 AM schedules)
  final List<int> _hours = const [7, 8, 9, 10, 11, 12];
  int? _selectedHour;

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

  List<String> _sampleSchedulesForHour(int hour) {
    // Simple sample schedules for demo purposes
    // e.g., hour 7 => ["7:30 AM - 8:30 AM", "7:30 AM - 9:00 AM", ...]
    final String start = '${hour == 12 ? 12 : hour}:30 AM';
    final List<String> ends = [
      '${(hour % 12) + 1}:30 AM',
      '${(hour % 12) + 2}:00 AM',
      '${(hour % 12) + 2}:30 AM',
      '${(hour % 12) + 3}:00 AM',
    ];
    return ends.map((e) => '$start - $e').toList();
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

    // Times removed from the generator per request
    const String start = '';
    const String end = '';

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
                    // Hour dropdown and filtered schedules
                    DropdownButtonFormField<int>(
                      value: _selectedHour,
                      items: _hours
                          .map((h) => DropdownMenuItem<int>(
                                value: h,
                                child: Text('$h AM'),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Filter by hour',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _selectedHour = v;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_selectedHour != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Schedules starting at ${_selectedHour} AM',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._sampleSchedulesForHour(_selectedHour!)
                              .map(
                                (s) => Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F6FE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 18, color: Color(0xFF1565C0)),
                                      const SizedBox(width: 8),
                                      Text(s),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ],
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



