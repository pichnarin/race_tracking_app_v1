import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class SegmentsWidget extends StatelessWidget {
  final String segment;
  final VoidCallback? onPressed;
  final bool isSelected;

  const SegmentsWidget({
    super.key,
    required this.segment,
    this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColor.primary : AppColor.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(segment),
      ),
    );
  }
}

class SegmentSection extends StatelessWidget {
  final Function(String) onSegmentSelected;
  final String selectedSegment;

  const SegmentSection({
    super.key,
    required this.onSegmentSelected,
    required this.selectedSegment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SegmentsWidget(
          segment: "Swimming",
          isSelected: selectedSegment == "swimming",
          onPressed: () => onSegmentSelected("swimming"),
        ),
        SegmentsWidget(
          segment: "Cycling",
          isSelected: selectedSegment == "cycling",
          onPressed: () => onSegmentSelected("cycling"),
        ),
        SegmentsWidget(
          segment: "Running",
          isSelected: selectedSegment == "running",
          onPressed: () => onSegmentSelected("running"),
        ),
      ],
    );
  }
}

