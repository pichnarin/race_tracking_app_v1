import 'package:flutter/material.dart';
import '../../screens/time_tracker/pages/home_page.dart';
import '../../screens/time_tracker/pages/result_page.dart';
import 'time_tracker_navbar.dart';

class TimeTrackerApp extends StatefulWidget {
  const TimeTrackerApp({super.key});

  @override
  State<TimeTrackerApp> createState() => _TimeTrackerAppState();
}

class _TimeTrackerAppState extends State<TimeTrackerApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ResultPage(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
