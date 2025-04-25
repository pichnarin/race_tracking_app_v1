import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        height: 80,
        color: AppColor.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NavbarBtn(icon: Icons.access_alarm_outlined, label: "Tracking"),
            NavbarBtn(icon: Icons.home, label: "Home"),
            NavbarBtn(icon: Icons.fact_check_outlined, label: "Result"),
          ],
        ),
      ),
    );
  }
}

class NavbarBtn extends StatelessWidget {
  const NavbarBtn({super.key, required this.icon, required this.label});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.black),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(label, style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
