import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/data/repo/race_repo.dart';

import '../../../data/model/races.dart';

class CreateRaceForm extends StatefulWidget {
  final RaceRepo repo;
  final void Function(Race createdRace) onRaceCreated;

  const CreateRaceForm({
    super.key,
    required this.repo,
    required this.onRaceCreated,
  });

  @override
  State<CreateRaceForm> createState() => _CreateRaceFormState();
}

class _CreateRaceFormState extends State<CreateRaceForm> {
  final _formKey = GlobalKey<FormState>();
  String raceName = '';
  String location = '';
  String swimming = '';
  String cycling = '';
  String running = '';

  Future<void> _createRace() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final raceSegments = {
        'swimming': RaceSegmentDetail(distance: swimming),
        'cycling': RaceSegmentDetail(distance: cycling),
        'running': RaceSegmentDetail(distance: running),
      };

      try {
        final createdRace = await widget.repo.createRace(
          name: raceName,
          status: RaceStatus.upcoming,
          startTime: now,
          segments: raceSegments,
          location: location,
        );

        widget.onRaceCreated(createdRace);

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Race created with UID: ${createdRace.uid}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create race: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create New Race"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Race Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter race name' : null,
                onSaved: (value) => raceName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value == null || value.isEmpty ? 'Enter location' : null,
                onSaved: (value) => location = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Swimming Distance'),
                onSaved: (value) => swimming = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cycling Distance'),
                onSaved: (value) => cycling = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Running Distance'),
                onSaved: (value) => running = value ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createRace,
          child: Text('Create'),
        ),
      ],
    );
  }
}
