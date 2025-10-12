import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'attendance_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AttendanceScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_currentIndex != widget.initialIndex && _pages.isNotEmpty) {
      // Initialize from initialIndex once on first build
      _currentIndex = widget.initialIndex;
    }
    return Scaffold(
      body: _pages[_currentIndex],
    );
  }
}




