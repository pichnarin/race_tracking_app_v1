import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/UI/screens/manager/competition_screen.dart';
import 'package:race_tracking_app_v1/UI/screens/manager/result_screen.dart';
import 'UI/screens/manager/home_screen.dart';
import 'UI/widget/manager/manager_navbar.dart' ;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const CompetitionScreen(),
      HomeScreen(onViewAllPressed: () {
        setState(() {
          _selectedIndex = 0;
        });
      }),
      const ResultScreen(),
    ]);
  }

  void _onItemTapped(int index) {
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
        onItemSelected: _onItemTapped,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
  ));
}
