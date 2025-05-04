import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/UI/widget/Form/add_participant.dart';
import 'package:race_tracking_app_v1/data/model/participants.dart';
import 'package:race_tracking_app_v1/data/model/races.dart';
import 'fire_race_repo.dart';

void main() {
  runApp(RaceTestApp());
}

class RaceTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Race Repo Tester', home: RaceTestScreen());
  }
}


class RaceTestScreen extends StatefulWidget {
  @override
  State<RaceTestScreen> createState() => _RaceTestScreenState();
}

class _RaceTestScreenState extends State<RaceTestScreen> {
  final FireRaceRepo repo = FireRaceRepo();
  Race? createdRace;
  List<Race> _races = []; // To hold the fetched races
  String? _selectedRaceId; // To hold the selected race ID
  
  List<Participant> _participants = []; // To hold the fetched participants

  DateTime? swimmingFinishTime;
  DateTime? cyclingFinishTime;
  DateTime? runningFinishTime;

  void showLog(String message) {
    print(message);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createRace() async {
    final now = DateTime.now();
    final raceName = "Test race"; // Example race name
    final raceStatus = RaceStatus.upcoming; // Starting status of the race
    final startTime = now; // The current time as start time

    // Example race segments
    final raceSegments = {
      'swimming': RaceSegmentDetail(distance: '1.5km'),
      'cycling': RaceSegmentDetail(distance: '40km'),
      'running': RaceSegmentDetail(distance: '10km'),
    };

    try {
      // Call the createRace method from the repository to create the race
      var createdRace = await repo.createRace(
        name: raceName,
        status: raceStatus,
        startTime: startTime,
        segments: raceSegments,
      );

      // Assuming createdRace has a UID or unique identifier
      setState(() {
        this.createdRace =
            createdRace; // Store the created race in state if needed
      });

      // Show a log message
      showLog("Race created with UID: ${createdRace.uid}");

      // Optionally show a confirmation message in the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Race created with UID: ${createdRace.uid}')),
      );
    } catch (e) {
      showLog('Failed to create race: $e');

      // Handle the error and display a message to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create race: $e')));
    }
  }

  // Fetch races from the repository
  Future<void> _fetchRaces() async {
    try {
      // Fetch the races from the repository
      var races =
      await repo
          .fetchRaces(); // Assuming fetchRaces returns a Map<String, Race>

      // Convert the Map to a List
      List<Race> raceList = races.values.toList();

      // Update the state with the fetched races
      setState(() {
        _races = raceList;
      });

      // Optionally show a log message
      showLog('Fetched ${_races.length} races');
    } catch (e) {
      showLog('Failed to fetch races: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FireRaceRepo Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: _createRace,
              child: const Text("1. Create Race"),
            ),
            ElevatedButton(
              onPressed: _fetchRaces,
              child: const Text("2. Fetch Races"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddParticipantForm()),
                );
              },

              child: const Text("Add Participant"),
            ),
            //Button to select race and start the race
            ElevatedButton(
              onPressed: () async {
                if (_selectedRaceId != null) {
                  try {
                    await repo.startRaceEvent(_selectedRaceId!);
                    showLog('Race "${_selectedRaceId!}" has started.');
                  } catch (e) {
                    showLog('Failed to start race: $e');
                  }
                } else {
                  showLog('Please select a race to start.');
                }
              },
              child: const Text("Start Race"),
            ),

            // Time tracker fetch participants by race
            ElevatedButton(
              onPressed: () async {
                if (_selectedRaceId != null) {
                  try {
                    // Fetch participants from the repository
                    final participants = await repo.fetchParticipants(
                      _selectedRaceId!,
                    );

                    // Update the state with the fetched participants
                    setState(() {
                      _participants = participants;
                    });

                    showLog('Fetched ${participants.length} participants');
                  } catch (e) {
                    showLog('Error fetching participants: $e');
                  }
                } else {
                  showLog('Please select a race first.');
                }
              },
              child: const Text("Load Participants"),
            ),

            //display the participant
            if (_participants.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                _participants.map((participant) {
                  int clickCount =
                  0; // Track the number of clicks for each participant

                  return Card(
                    child: ListTile(
                      title: Text('Bib: ${participant.bib}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Time: ${participant.totalTime}'),
                          ElevatedButton(
                            onPressed: () async {
                              if (_selectedRaceId != null) {
                                final now = DateTime.now();
                                String segment;

                                // Determine the segment based on the click count
                                if (clickCount == 0) {
                                  segment = 'swimming';
                                } else if (clickCount == 1) {
                                  segment = 'cycling';
                                } else if (clickCount == 2) {
                                  segment = 'running';
                                } else {
                                  showLog(
                                    'All segments have been recorded for this participant.',
                                  );
                                  return;
                                }

                                try {
                                  // Record the finish time for the segment
                                  await repo.recordSegmentTime(
                                    raceId: _selectedRaceId!,
                                    bib: participant.bib,
                                    segment: segment,
                                    finishTime: now,
                                  );

                                  showLog(
                                    'Recorded $segment finish time for Bib: ${participant.bib}',
                                  );
                                  clickCount++; // Increment the click count
                                } catch (e) {
                                  showLog(
                                    'Failed to record $segment finish time: $e',
                                  );
                                }
                              } else {
                                showLog('Please select a race first.');
                              }
                            },
                            child: const Text('Record Finish Time'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              const Text('No participants loaded.'),
          ],
        ),
      ),
    );
  }
}

