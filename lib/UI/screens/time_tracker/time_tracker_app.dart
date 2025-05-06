import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/tracking_page.dart';
import 'pages/result_page.dart';
import '../../widget/global/navbar.dart';

class TimeTrackerApp extends StatefulWidget {
  const TimeTrackerApp({super.key});

  @override
  State<TimeTrackerApp> createState() => _TimeTrackerAppState();
}

class _TimeTrackerAppState extends State<TimeTrackerApp> {
  int _selectedIndex = 1; // Default to home page

  final List<Widget> _pages = [
    HomePage(), // Replace with your actual widget
    TrackingPage(),
    ResultPage(), // Replace with your actual widget
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
