import 'package:flutter/material.dart';
import '../../../widget/time_tracker/track_button_section.dart';

class SwimmingScreen extends StatelessWidget {
  final String data;
  const SwimmingScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Swimming Segment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Track Participants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TrackButtonSection(), 
          ],
        ),
      ),
    );
  }
}
