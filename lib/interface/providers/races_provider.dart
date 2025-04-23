import 'package:flutter/cupertino.dart';
import 'package:race_tracking_app_v1/data/repo/race_repo.dart';

import '../../data/model/races.dart';
import '../async_value.dart';

class RaceProvider extends ChangeNotifier {
  final RaceRepo _repository;
  AsyncValue<List<Race>>? racesState;
  AsyncValue<Race>? raceState;

  RaceProvider(this._repository);

  bool get isLoading =>
      racesState != null && racesState!.state == AsyncValueState.loading;
  bool get hasData =>
      racesState != null && racesState!.state == AsyncValueState.success;

  bool get isRaceLoading =>
      raceState != null && raceState!.state == AsyncValueState.loading;
  bool get hasRaceData =>
      raceState != null && raceState!.state == AsyncValueState.success;

// Create a new race
  void addRace(String name, RaceStatus status, DateTime startTime, Map<String, RaceSegmentDetail> segments) async {
    try {
      raceState = AsyncValue.loading();
      notifyListeners();

      final createdRace = await _repository.createRace(
        name: name,
        status: status,
        startTime: startTime,
        segments: segments,
      );
      raceState = AsyncValue.success(createdRace);
      print("SUCCESS: Race created with UID ${createdRace.uid}");
    } catch (error) {
      print("ERROR: $error");
      raceState = AsyncValue.error(error);
    }

    notifyListeners();
  }

}
