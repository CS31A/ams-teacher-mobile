import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'qr_generator_screen.dart';
import 'students_list_screen.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = [
      const HomeScreen(),
      const QRGeneratorScreen(),
      const StudentsListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() {
            _currentIndex = i;
          });
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
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}




