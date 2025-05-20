import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/data/Firebase/fire_race_repo.dart';
import 'package:race_tracking_app_v1/model/races.dart';
import 'package:race_tracking_app_v1/model/participants.dart';
import '../../model/race_segments_detail.dart';
class RaceProvider with ChangeNotifier {
  final FireRaceRepo _raceRepo;

  List<Race> _races = [];
  List<Participant> _participants = [];
  bool _isLoading = false;
  String? _error;

  RaceProvider(this._raceRepo);

  FireRaceRepo get repo => _raceRepo;

  List<Race> get races => _races;
  List<Participant> get participants => _participants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRaceById(String raceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedRaceMap = await _raceRepo.fetchRace(raceId);
      final fetchedRace = fetchedRaceMap.values.first;

      final index = _races.indexWhere((r) => r.uid == raceId);
      if (index != -1) {
        _races[index] = fetchedRace;
      } else {
        _races.add(fetchedRace);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final racesMap = await _raceRepo.fetchRaces();
      _races = racesMap.values.toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchParticipants(String raceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _participants = await _raceRepo.fetchParticipants(raceId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createRace({
    required String name,
    required RaceStatus status,
    required DateTime startTime,
    required Map<String, RaceSegmentDetail> segments,
    required String location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepo.createRace(
        name: name,
        status: status,
        startTime: startTime,
        segments: segments,
        location: location,
      );
      await fetchRaces();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startRace(String raceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepo.startRaceEvent(raceId);
      await fetchRaces();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> endRace(String raceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepo.endRaceEvent(raceId);
      await fetchRaces();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addParticipant({
    required String bib,
    required String raceId,
    required String name,
    required Map<String, DateTime> segmentStartTimes,
    required Map<String, DateTime> segmentFinishTimes,
    required String totalTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepo.addParticipant(
        bib: bib,
        raceId: raceId,
        name: name,
        segmentStartTimes: segmentStartTimes,
        segmentFinishTimes: segmentFinishTimes,
        totalTime: totalTime,
      );
      await fetchParticipants(raceId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateParticipant(Participant participant) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepo.updateParticipant(participant);
      await fetchParticipants(participant.raceId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteParticipant(String bib) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepo.deleteParticipant(bib);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> recordSegmentTime({
    required String raceId,
    required String bib,
    required String segment,
    required DateTime finishTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _raceRepo.recordSegmentTime(
        raceId: raceId,
        bib: bib,
        segment: segment,
        finishTime: finishTime,
      );
      await fetchParticipants(raceId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Participant>> fetchDashboardScore(String raceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _raceRepo.fetchDashboardScore(raceId);
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Participant?> fetchParticipant(String bib) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _raceRepo.fetchParticipant(bib);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRaceDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final raceMap = await _raceRepo.fetchRaces(); // returns Map<String, Race>
      _races = raceMap.values.toList(); // Store directly
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchRaceParticipantById(
    String raceId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _raceRepo.fetchRaceParticipantById(raceId);
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
