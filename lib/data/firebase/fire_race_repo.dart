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
    required String location,
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
      'location': location,
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
      location: location,
    );
  }

  @override
  Future<Participant> addParticipant({
    required String bib,
    required String raceId,
    required String name,
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
      'name' : name,
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

      //added name
      return Participant(
        name: name,
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
  Future<void> startRaceEvent(String raceId) async {
    final url =
        '${Environment.baseUrl}${Environment.racesCollection}/$raceId.json';

    // Record the race start time
    final startTime = DateTime.now().toIso8601String();

    final response = await client.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': RaceStatus.started.name, // or use RaceStatus.started.index if it's an enum
        'startTime': startTime,
      }),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to start race: ${response.statusCode}');
    }

    // Fetch participants of the race
    final participantsUrl =
        '${Environment.baseUrl}${Environment.racesCollection}/$raceId/${Environment.participantsCollection}.json';

    final participantsResponse = await client.get(Uri.parse(participantsUrl));
    if (participantsResponse.statusCode != HttpStatus.ok) {
      throw Exception(
        'Failed to fetch participants: ${participantsResponse.statusCode}',
      );
    }

    final Map<String, dynamic>? participantsData = json.decode(
      participantsResponse.body,
    );
    if (participantsData == null) return;

    // Update each participant's swimming start time
    for (final entry in participantsData.entries) {
      final participantKey = entry.key;
      final participantData = entry.value;

      participantData['segmentStartTimes'] ??= {};
      participantData['segmentStartTimes']['swimming'] = startTime;

      final updateUrl =
          '${Environment.baseUrl}${Environment.racesCollection}/$raceId/${Environment.participantsCollection}/$participantKey.json';

      final updateResponse = await client.patch(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'segmentStartTimes': participantData['segmentStartTimes'],
        }),
      );

      if (updateResponse.statusCode != HttpStatus.ok) {
        throw Exception(
          'Failed to update participant: ${updateResponse.statusCode}',
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
  Future<void> updateParticipant(Participant participant) async {
    final url =
        '${Environment.baseUrl}${Environment.racesCollection}/${participant.raceId}/${Environment.participantsCollection}/${participant.pid}.json';

    final updateData = {
      'bib': participant.bib,
      'segmentStartTimes': participant.segmentStartTimes.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'segmentFinishTimes': participant.segmentFinishTimes.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'totalTime': participant.totalTime,
    };

    final response = await client.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to update participant: ${response.statusCode}');
    }
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

  // @override
  // Future<void> recordSegmentTime({
  //   required String raceId,
  //   required String bib,
  //   required String segment,
  //   required DateTime finishTime,
  // }) async {
  //   final url =
  //       '${Environment.baseUrl}${Environment.racesCollection}/$raceId/${Environment.participantsCollection}.json';
  //
  //   // Fetch the current participants
  //   final fetchResponse = await client.get(Uri.parse(url));
  //   if (fetchResponse.statusCode != HttpStatus.ok) {
  //     throw Exception(
  //       'Failed to fetch participants: ${fetchResponse.statusCode}',
  //     );
  //   }
  //
  //   final Map<String, dynamic>? participantsData = json.decode(
  //     fetchResponse.body,
  //   );
  //   if (participantsData == null) {
  //     throw Exception('No participants found for race $raceId');
  //   }
  //
  //   // Find the participant by bib
  //   String? participantKey;
  //   Map<String, dynamic>? participantData;
  //   participantsData.forEach((key, value) {
  //     if (value['bib'] == bib) {
  //       participantKey = key;
  //       participantData = value;
  //     }
  //   });
  //
  //   if (participantKey == null || participantData == null) {
  //     throw Exception('Participant with bib $bib not found in race $raceId');
  //   }
  //
  //   // Update the segment finish time
  //   participantData?['segmentFinishTimes'] ??= {};
  //   participantData?['segmentFinishTimes'][segment] =
  //       finishTime.toIso8601String();
  //
  //   // Send the updated data back to the server
  //   final updateUrl =
  //       '${Environment.baseUrl}${Environment.racesCollection}/$raceId/${Environment.participantsCollection}/$participantKey.json';
  //
  //   final updateResponse = await client.patch(
  //     Uri.parse(updateUrl),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'segmentFinishTimes': participantData?['segmentFinishTimes'],
  //     }),
  //   );
  //
  //   if (updateResponse.statusCode != HttpStatus.ok) {
  //     throw Exception(
  //       'Failed to update segment time: ${updateResponse.statusCode}',
  //     );
  //   }
  // }

  @override
  Future<void> recordSegmentTime({
    required String raceId,
    required String bib,
    required String segment,
    required DateTime finishTime,
  }) async {
    final url =
        '${Environment.baseUrl}${Environment.racesCollection}/$raceId/${Environment.participantsCollection}.json';

    // Fetch the current participants
    final fetchResponse = await client.get(Uri.parse(url));
    if (fetchResponse.statusCode != HttpStatus.ok) {
      throw Exception(
        'Failed to fetch participants: ${fetchResponse.statusCode}',
      );
    }

    final Map<String, dynamic>? participantsData = json.decode(
      fetchResponse.body,
    );
    if (participantsData == null) {
      throw Exception('No participants found for race $raceId');
    }

    // Find the participant by bib
    String? participantKey;
    Map<String, dynamic>? participantData;
    participantsData.forEach((key, value) {
      if (value['bib'] == bib) {
        participantKey = key;
        participantData = value;
      }
    });

    if (participantKey == null || participantData == null) {
      throw Exception('Participant with bib $bib not found in race $raceId');
    }

    // Update the segment finish time
    participantData?['segmentFinishTimes'] ??= {};
    participantData?['segmentFinishTimes'][segment] =
        finishTime.toIso8601String();

    // Update the next segment's start time if applicable
    participantData?['segmentStartTimes'] ??= {};
    if (segment == 'swimming') {
      participantData?['segmentStartTimes']['cycling'] =
          finishTime.toIso8601String();
    } else if (segment == 'cycling') {
      participantData?['segmentStartTimes']['running'] =
          finishTime.toIso8601String();
    } else if (segment == 'running') {
      // Calculate the total time
      final swimmingStart = DateTime.parse(
        participantData?['segmentStartTimes']['swimming'],
      );
      final swimmingFinish = DateTime.parse(
        participantData?['segmentFinishTimes']['swimming'],
      );
      final cyclingStart = DateTime.parse(
        participantData?['segmentStartTimes']['cycling'],
      );
      final cyclingFinish = DateTime.parse(
        participantData?['segmentFinishTimes']['cycling'],
      );
      final runningStart = DateTime.parse(
        participantData?['segmentStartTimes']['running'],
      );
      final runningFinish = DateTime.parse(
        participantData?['segmentFinishTimes']['running'],
      );

      final totalTime =
          (swimmingFinish.difference(swimmingStart) +
                  cyclingFinish.difference(cyclingStart) +
                  runningFinish.difference(runningStart))
              .inSeconds;

      participantData?['totalTime'] = formatDuration(
        Duration(seconds: totalTime),
      );
    }

    // Send the updated data back to the server
    final updateUrl =
        '${Environment.baseUrl}${Environment.racesCollection}/$raceId/${Environment.participantsCollection}/$participantKey.json';

    final updateResponse = await client.patch(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'segmentFinishTimes': participantData?['segmentFinishTimes'],
        'segmentStartTimes': participantData?['segmentStartTimes'],
        if (segment == 'running') 'totalTime': participantData?['totalTime'],
      }),
    );

    if (updateResponse.statusCode != HttpStatus.ok) {
      throw Exception(
        'Failed to update segment time: ${updateResponse.statusCode}',
      );
    }
  }

  @override
  Future<void> deleteParticipant(String bib) {
    // TODO: implement deleteParticipant
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRaceDetails() async {
    try {
      final uri = Uri.parse(Environment.allRacesUrl);
      final http.Response response = await http.get(uri);

      if (response.statusCode != HttpStatus.ok) {
        throw Exception('Failed to fetch races');
      }

      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Convert the JSON data into a list of maps
      final List<Map<String, dynamic>> raceDetails = responseBody.entries.map((entry) {
        final raceData = entry.value;
        return {
          'uid': entry.key,
          'name': raceData['name'],
          'participants': raceData['participants'] ?? {},
          'segments': raceData['segments'] ?? {},
          'startTime': raceData['startTime'],
          'location': raceData['location'],
          'status': raceData['status'],
        };
      }).toList();

      return raceDetails;
    } catch (e) {
      throw Exception('Failed to fetch race details: $e');
    }
}
}
