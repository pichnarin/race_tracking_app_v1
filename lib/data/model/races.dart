import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum RaceStatus {
  upcoming,
  started,
  ended
}

class RaceSegmentDetail {
  final String distance;

  RaceSegmentDetail({required this.distance});

  factory RaceSegmentDetail.fromJson(Map<String, dynamic> json) {
    return RaceSegmentDetail(distance: json['distance'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'distance': distance};
  }
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

  factory Race.fromJson(Map<String, dynamic> json) {
    // Ensure that segments is properly cast to a Map<String, dynamic>
    final segmentMap = json['segments'] != null
        ? Map<String, dynamic>.from(json['segments'])
        : {};

    // Now cast the map keys to String and create the parsedSegments
    final parsedSegments = segmentMap.map(
          (key, value) => MapEntry<String, RaceSegmentDetail>(
        key as String,  // Ensure that the key is a String
        RaceSegmentDetail.fromJson(value),
      ),
    );

    return Race(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Race',
      status: json['status'] != null
          ? RaceStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => RaceStatus.started,
      )
          : RaceStatus.started,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      segments: parsedSegments,
      location: json['location'] as String? ?? 'Unknown Location',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'segments': segments.map((key, value) => MapEntry(key, value.toJson())),
      'location': location,
    };
  }
}
