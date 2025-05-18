import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Navbar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

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
          // Wrap each NavbarBtn in an Expanded to evenly space them and center content vertically
          children: [
            Expanded(
              child: NavbarBtn(
                icon: Icons.home,
                label: "Home",
                isSelected: selectedIndex == 0,
                onTap: () => onItemSelected(0),
              ),
            ),
            Expanded(
              child: NavbarBtn(
                icon: Icons.fact_check_outlined,
                label: "Result",
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavbarBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const NavbarBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? Colors.white : Colors.black54;
    final textStyle = TextStyle(
      color: isSelected ? Colors.white : Colors.white70,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 4),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}

