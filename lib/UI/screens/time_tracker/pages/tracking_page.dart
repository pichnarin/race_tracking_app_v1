import 'package:flutter/material.dart';
import '../../../widget/time_tracker/segments_widget.dart';
import '../../../widget/time_tracker/track_button_section.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("test track")),
        body: TrackingPage(),
      ),
    ),
  );
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
       // or whatever height you want
        children: [
          SegmentSection(),
          SizedBox(height: 20),   // Add some spacing
          TrackButtonSection(),
        ] 
      ),
    );
  }
}
