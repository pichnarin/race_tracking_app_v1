import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class TrackButton extends StatelessWidget {
  final String bib;
  const TrackButton({super.key, required this.bib});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary, 
          foregroundColor: Colors.white, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), 
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        ),
        child: Text(bib),
      ),
    );
  }
}

