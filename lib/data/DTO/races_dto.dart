import '../../model/races.dart';
import '../../model/race_segments_detail.dart';

class RaceDTO {
  final String uid;
  final String name;
  final RaceStatus status;
  final DateTime startTime;
  final Map<String, RaceSegmentDetail> segments;
  final String location;

  RaceDTO({
    required this.uid,
    required this.name,
    required this.status,
    required this.startTime,
    required this.segments,
    required this.location,
  });

  factory RaceDTO.fromJson(Map<String, dynamic> json) {
    final segmentMap = json['segments'] != null
        ? Map<String, dynamic>.from(json['segments'])
        : {};

    final parsedSegments = segmentMap.map(
      (key, value) => MapEntry(
        key as String,
        RaceSegmentDetail.fromJson(value),
      ),
    );

    return RaceDTO(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Race',
      status: json['status'] != null
          ? RaceStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => RaceStatus.started,
            )
          : RaceStatus.started,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      segments: parsedSegments,
      location: json['location'] ?? 'Unknown Location',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'segments': segments.map((k, v) => MapEntry(k, v.toJson())),
      'location': location,
    };
  }

  Race toModel() {
    return Race(
      uid: uid,
      name: name,
      status: status,
      startTime: startTime,
      segments: segments,
      location: location,
    );
  }

  factory RaceDTO.fromModel(Race model) {
    return RaceDTO(
      uid: model.uid,
      name: model.name,
      status: model.status,
      startTime: model.startTime,
      segments: model.segments,
      location: model.location,
    );
  }
}
