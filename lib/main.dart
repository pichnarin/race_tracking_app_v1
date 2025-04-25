import 'package:flutter/material.dart';
import 'UI/widget/navbar.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Hello world")), // placeholder
        bottomNavigationBar: Navbar(), // This makes it sit at the bottom
      ),
    );
  }
}
