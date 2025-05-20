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
