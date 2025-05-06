import 'package:flutter/material.dart';
import '../../../widget/time_tracker/segments_widget.dart';
import '../segments/cycling_segment.dart';
import '../segments/running_segment.dart';
import '../segments/swim_segment.dart';

void main() {
  runApp(MaterialApp(home: TrackingPage()));
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  String selectedSegment = "swimming";

  String getSegmentImage() {
    switch (selectedSegment) {
      case "cycling":
        return 'assets/cycling.png';
      case "running":
        return 'assets/running.png';
      case "swimming":
      default:
        return 'assets/swimming.png';
    }
  }

  Widget getSegmentWidget() {
    switch (selectedSegment) {
      case "cycling":
        return CyclingScreen(data: "Data for Cycling");
      case "running":
        return RunningScreen(data: "Data for Running");
      case "swimming":
      default:
        return SwimmingScreen(data: "Data for Swimming");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [Image.asset(getSegmentImage(), width: 40, height: 40)],
            ),
            SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedSegment[0].toUpperCase() +
                      selectedSegment.substring(1),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SegmentSection(
            selectedSegment: selectedSegment,
            onSegmentSelected: (segment) {
              setState(() {
                selectedSegment = segment;
              });
            },
          ),

          Expanded(child: getSegmentWidget()),
        ],
      ),
    );
  }
}
