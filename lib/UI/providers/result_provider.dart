import 'package:flutter/material.dart';
import '../../data/Firebase/fire_race_repo.dart';

class ResultProvider with ChangeNotifier {
  final FireRaceRepo _raceRepo = FireRaceRepo();

  List<Map<String, dynamic>> _allRaces = [];
  List<Map<String, dynamic>> _filteredRaces = [];
  String _searchText = '';
  String? _errorMessage;
  bool _isLoading = false;

  List<Map<String, dynamic>> get filteredRaces => _filteredRaces;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadRaceList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final races = await _raceRepo.fetchRaceDetails();
      _allRaces = races;
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error fetching race details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchText(String text) {
    _searchText = text;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredRaces = _allRaces.where((race) {
      final name = (race['name'] ?? '').toString().toLowerCase();
      final status = (race['status'] ?? '').toString().toLowerCase();

      final matchesSearch = name.contains(_searchText.toLowerCase());
      final isCompleted = status == 'completed';

      return matchesSearch && isCompleted;
    }).toList();
    notifyListeners();
  }

  void clearSearch() {
    _searchText = '';
    _applyFilters();
  }
}