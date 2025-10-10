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

  final List<Widget> _pages = const [
    HomeScreen(),
    QRGeneratorScreen(),
    StudentsListScreen(),
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
            icon: Icon(Icons.qr_code_2_outlined),
            selectedIcon: Icon(Icons.qr_code_2),
            label: 'QR Generator',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Sections',
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




