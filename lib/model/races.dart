import '../model/race_segments_detail.dart';

enum RaceStatus {
  upcoming,
  started,
  completed,
}

class Race {
  final String uid; // Firebase-generated UID will be assigned later
  final String name;
  final RaceStatus status;
  final DateTime startTime;
  final Map<String, RaceSegmentDetail> segments;
  final String location;

  Race({
    required this.uid,
    required this.name,
    required this.status,
    required this.startTime,
    required this.segments,
    required this.location
  });


  @override
  bool operator ==(Object other) {
    return other is Race && other.uid == uid;
  }

  @override
  int get hashCode => super.hashCode ^ uid.hashCode;

}
