// UI/screens/time_tracker/pages/running_segment.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/segment_provider.dart';
import '../../../widget/time_tracker/track_button_section.dart';

class RunningScreen extends StatelessWidget {
  const RunningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final segmentProvider = Provider.of<SegmentProvider>(context, listen: false);
    
    // Set current segment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      segmentProvider.setSegment('running');
    });
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Track Running Participants",
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
