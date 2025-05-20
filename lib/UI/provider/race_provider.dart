import 'package:flutter/foundation.dart';
import '../../data/repo/firebase_race_repo.dart';

class RaceProvider with ChangeNotifier {
  final FireRaceRepo _raceRepo = FireRaceRepo();

  List<Map<String, dynamic>> _startedRaces = [];
  List<Map<String, dynamic>> get startedRaces => _startedRaces;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchStartedRaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final races = await _raceRepo.fetchRaceDetails();

      // Filter races with status 'started' (case-insensitive)
      _startedRaces = races.where((race) {
        final status = race['status'];
        return status != null && status.toString().toLowerCase() == 'started';
      }).toList();
    } catch (e) {
      _error = 'Failed to fetch races: $e';
      _startedRaces = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
