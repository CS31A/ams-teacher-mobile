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
    );
  }
}




