import 'package:flutter/material.dart';
import '../../widget/time_tracker/track_button.dart';

class TrackButtonSection extends StatefulWidget {
  const TrackButtonSection({super.key});

  @override
  State<TrackButtonSection> createState() => _TrackButtonSectionState();
}

class _TrackButtonSectionState extends State<TrackButtonSection> {

  final List<String> bibNumbers = [
    "001", "002", "003", "004", 
    "005", "006", "007", "008",
    "009", "010"
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4, 
      shrinkWrap: true,  
      physics: NeverScrollableScrollPhysics(), 
      // children: bibNumbers.map((bib) => TrackButton(bib: bib)).toList(),
      children: bibNumbers.map((bib) => Center(child: TrackButton(bib: bib))).toList(),

    );
  }
}