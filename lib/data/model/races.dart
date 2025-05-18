import 'package:flutter/foundation.dart';
import 'package:race_tracking_app_v1/data/model/participants.dart';

enum RaceStatus {
  upcoming,
  started,
  completed,
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
  final String uid;
  final String name;
  final RaceStatus status;
  final DateTime startTime;
  final Map<String, RaceSegmentDetail> segments;
  final String location;
  final Map<String, Participant>? participants;

  Race({
    required this.uid,
    required this.name,
    required this.status,
    required this.startTime,
    required this.segments,
    required this.location,
    this.participants, // optional in constructor
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    final segmentMap = json['segments'] != null
        ? Map<String, dynamic>.from(json['segments'])
        : {};
    final parsedSegments = segmentMap.map(
          (key, value) => MapEntry<String, RaceSegmentDetail>(
        key as String,
        RaceSegmentDetail.fromJson(value),
      ),
    );

    // participants is optional, so handle null safely
    Map<String, Participant>? parsedParticipants;
    if (json['participants'] != null) {
      final participantMap = Map<String, dynamic>.from(json['participants']);
      parsedParticipants = participantMap.map(
            (key, value) => MapEntry<String, Participant>(
          key as String,
          Participant.fromJson(Map<String, dynamic>.from(value)),
        ),
      );
    }

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
      participants: parsedParticipants,
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
      if (participants != null)
        'participants': participants!.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is Race && other.uid == uid;
  }

  @override
  int get hashCode => super.hashCode ^ uid.hashCode;
}
