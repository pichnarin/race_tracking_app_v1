import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:race_tracking_app_v1/data/model/participants.dart';
import 'package:race_tracking_app_v1/data/model/races.dart';
import 'package:race_tracking_app_v1/data/repo/race_repo.dart';

import '../env.dart';

class FireRaceRepo extends RaceRepo {
  final client = http.Client();

  @override
  Future<Race> createRace({
    required String name,
    required RaceStatus status,
    required DateTime startTime,
    required Map<String, RaceSegmentDetail> segments,
  }) async {
    final existingRaces = await fetchRaces();

    // Check if a race with the same name already exists
    if (existingRaces.values.any((race) => race.name == name)) {
      throw Exception('A race with the name "$name" already exists.');
    }

    Uri uri = Uri.parse(Environment.allRacesUrl);

    // Prepare the race data to send to the backend
    final newRaceData = {
      'name': name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'segments': segments.map((key, value) => MapEntry(key, value.toJson())),
    };

    // Send POST request to create the race
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newRaceData),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to create race: ${response.statusCode}');
    }

    final responseData = json.decode(response.body);
    final newUid = responseData['name'];

    if (newUid == null) {
      throw Exception('Failed to get a valid UID from the response.');
    }

    return Race(
      uid: newUid,
      name: name,
      status: status,
      startTime: startTime,
      segments: segments,
    );
  }

  @override
  Future<Participant> addParticipant({
    required String bib,
    required String raceId,
    required Map<String, DateTime> segmentStartTimes,
    required Map<String, DateTime> segmentFinishTimes,
    required String totalTime,
  }) async {
    final url =
        '${Environment.baseUrl}${Environment.racesCollection}/$raceId/${Environment.participantsCollection}.json';

    final fetchResponse = await client.get(Uri.parse(url));
    if (fetchResponse.statusCode != 200) {
      throw Exception('Failed to fetch existing participants');
    }

    //check if the bib already exists
    final existingData = json.decode(fetchResponse.body);
    if (existingData != null && existingData is Map<String, dynamic>) {
      for (final entry in existingData.entries) {
        final participant = entry.value;
        if (participant != null &&
            participant is Map<String, dynamic> &&
            participant['bib'] == bib) {
          throw Exception('A participant with bib "$bib" already exists.');
        }
      }
    }

    //prepare the new participant data
    final newParticipant = {
      'bib': bib,
      'segmentStartTimes': segmentStartTimes.map(
            (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'segmentFinishTimes': segmentFinishTimes.map(
            (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'totalTime': totalTime,
    };

    try {
      final http.Response response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newParticipant),
      );

      if (response.statusCode != HttpStatus.ok) {
        throw Exception('Failed to add participant: ${response.statusCode}');
      }

      final responseData = json.decode(response.body);

      final newPid = responseData['name'];
      if (newPid == null || newPid is! String) {
        throw Exception('Failed to get a valid PID from the response.');
      }

      return Participant(
        pid: newPid,
        bib: bib,
        raceId: raceId,
        segmentStartTimes: segmentStartTimes,
        segmentFinishTimes: segmentFinishTimes,
        totalTime: totalTime,
      );
    } catch (e) {
      throw Exception('Error adding participant: $e');
    }
  }

  @override
  Future<void> startRaceEvent() async {
    final racesResponse = await client.get(Uri.parse(Environment.allRacesUrl));
    final races = jsonDecode(racesResponse.body) as Map<String, dynamic>?;

    if (races != null) {
      for (final entry in races.entries) {
        final raceId = entry.key;
        final url =
            '${Environment.baseUrl}${Environment.racesCollection}/$raceId.json';
        await client.patch(
          Uri.parse(url),
          body: jsonEncode({
            'status': 0,
            'startTime': DateTime.now().toIso8601String(),
          }),
        );
      }
    }
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Future<void> updateParticipant(Participant participant) {
    // TODO: implement updateParticipant
    throw UnimplementedError();
  }

  @override
  Future<List<Participant>> fetchDashboardScore(String raceId) {
    // TODO: implement fetchDashboardScore
    throw UnimplementedError();
  }

  @override
  Future<Participant?> fetchParticipant(String bib) {
    // TODO: implement fetchParticipant
    throw UnimplementedError();
  }

  @override
  Future<List<Participant>> fetchParticipants(String raceId) async {
    final url =
        '${Environment.baseUrl}${Environment.racesCollection}/$raceId/${Environment.participantsCollection}.json';

    final http.Response response = await client.get(Uri.parse(url));

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to fetch participants: ${response.statusCode}');
    }

    final Map<String, dynamic>? responseData = json.decode(response.body);
    if (responseData == null) return [];

    return responseData.entries.map((entry) {
      final pid = entry.key;
      final data = entry.value;
      return Participant.fromJson({...data, 'pid': pid, 'raceId': raceId});
    }).toList();
  }

  @override
  Future<Race?> fetchRace(String raceId) {
    // TODO: implement fetchRace
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Race>> fetchRaces() async {
    try {
      final uri = Uri.parse(Environment.allRacesUrl); // Replace with actual URL
      final http.Response response = await http.get(uri);

      if (response.statusCode != HttpStatus.ok) {
        throw Exception('Failed to fetch races');
      }

      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Parse the response into a Map<String, Race>
      final Map<String, Race> races = {};
      responseBody.forEach((key, value) {
        races[key] = Race.fromJson({
          ...value,
          'uid': key,
        }); // Use your fromJson method to convert to Race
      });

      return races;
    } catch (e) {
      throw Exception('Failed to fetch races: $e');
    }
  }

  @override
  Future<void> recordSegmentTime({
    required String raceId,
    required String bib,
    required String segment,
    required DateTime finishTime,
  }) {
    // TODO: implement recordSegmentTime
    throw UnimplementedError();
  }

  @override
  Future<void> deleteParticipant(String bib) {
    // TODO: implement deleteParticipant
    throw UnimplementedError();
  }
}
