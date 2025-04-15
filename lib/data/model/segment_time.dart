import 'package:race_tracking_app_v1/data/model/Triathlon.dart';

//special use when time tracker tap on bib of participant

class SegmentTime{
  final Triathlon segment;
  final DateTime timeStamp;

  SegmentTime({
    required this.segment,
    required this.timeStamp
  });
}