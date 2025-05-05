import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class SegmentsWidget extends StatelessWidget {
  final String segment;
  const SegmentsWidget({super.key, required this.segment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // fixed width
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColor.primary,
      ),
      child: Center(
        // center the text inside
        child: Text(segment, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class SegmentSection extends StatelessWidget {
  const SegmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SegmentsWidget(segment: "swimming"),
        SegmentsWidget(segment: "cycling"),
        SegmentsWidget(segment: "running"),
      ],
    );
  }
}
