import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubject;
  String? _selectedRoom;
  int? _selectedSlotIndex;
  bool _showQrOverlay = false;
  String _roomFilter = '1st Floor';

  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Geography',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Art',
    'Music',
    'Physical Education',
  ];

  final List<String> _timeSlots = [
    '8:00 AM - 9:00 AM',
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
  ];

  List<String> _rooms() {
    return [
      '101', '102', '103', '104', '105', '106',
      '201', '202', '203', '204', '205', '206',
      '301', '302', '303', '304', '305', '306',
      'SLAB1', 'SLAB2', 'SLAB3', 'SLAB4', 'SLAB5',
    ];
  }

  List<String> _filteredRooms() {
    final rooms = _rooms();
    switch (_roomFilter) {
      case '1st Floor':
        return rooms.where((room) => room.startsWith('1')).toList();
      case '2nd Floor':
        return rooms.where((room) => room.startsWith('2')).toList();
      case '3rd Floor':
        return rooms.where((room) => room.startsWith('3')).toList();
      case 'SLAB':
        return rooms.where((room) => room.startsWith('SLAB')).toList();
      default:
        return rooms;
    }
  }

  bool _isFormValid() {
    return _selectedSubject != null && 
           _selectedRoom != null && 
           _selectedSlotIndex != null;
  }

  String _getSubjectHelperText() {
    if (_selectedSubject == null) {
      return 'Select a subject from the list';
    }
    return 'Selected: $_selectedSubject';
  }

  String _getRoomHelperText() {
    if (_selectedRoom == null) {
      return 'Select a room for your class';
    }
    return 'Selected: $_selectedRoom';
  }

  String _getTimeSlotHelperText() {
    if (_selectedSlotIndex == null) {
      return 'Select a time slot for your class';
    }
    return 'Selected: ${_timeSlots[_selectedSlotIndex!]}';
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _roomFilter == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _roomFilter = value;
            _selectedRoom = null; // Reset selection when filter changes
          });
        }
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[800],
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$label: $value',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveToHistory() async {
    // TODO: Implement history saving functionality
    // This would typically save to SharedPreferences or a database
  }

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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subject Dropdown
                          Text(
                            'Subject',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedSubject,
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: 'Select a subject',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _subjects.map((subject) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        subject,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubject = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a subject';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getSubjectHelperText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Room Filter Chips
                          Text(
                            'Room Filter',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildFilterChip('1st Floor', '1st Floor'),
                              _buildFilterChip('2nd Floor', '2nd Floor'),
                              _buildFilterChip('3rd Floor', '3rd Floor'),
                              _buildFilterChip('SLAB', 'SLAB'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Room Dropdown
                          Text(
                            'Room',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedRoom,
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: 'Select a room',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _filteredRooms().map((room) {
                              return DropdownMenuItem<String>(
                                value: room,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        room,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRoom = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a room';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getRoomHelperText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time Slot Dropdown
                          Text(
                            'Time Slot',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedSlotIndex,
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: 'Select a time slot',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _timeSlots.asMap().entries.map((entry) {
                              return DropdownMenuItem<int>(
                                value: entry.key,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        entry.value,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSlotIndex = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a time slot';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getTimeSlotHelperText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
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
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // QR Code Info Chips
                              Row(
                                children: [
                                  _buildInfoChip('Subject', _selectedSubject!, Icons.book),
                                  const SizedBox(width: 8),
                                  _buildInfoChip('Room', _selectedRoom!, Icons.room),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildInfoChip('Time', _timeSlots[_selectedSlotIndex!], Icons.access_time),
                              const SizedBox(height: 20),
                              // QR Code
                              QrImageView(
                                data: 'Subject: $_selectedSubject\nRoom: $_selectedRoom\nTime: ${_timeSlots[_selectedSlotIndex!]}\nGenerated: ${DateTime.now().toString()}',
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 20),
                              // Close Button
                              TextButton(
                                onPressed: () => setState(() => _showQrOverlay = false),
                                child: const Text('Close'),
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
        ],
      ),
    );
  }
}
