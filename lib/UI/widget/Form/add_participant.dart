import 'package:flutter/material.dart';
import '../../../data/Firebase/fire_race_repo.dart';
import '../../../model/races.dart';

class AddParticipantForm extends StatefulWidget {
  final FireRaceRepo repo;
  final void Function() onParticipantAdded;
  final String raceId; // Add raceId here

  const AddParticipantForm({
    super.key,
    required this.repo,
    required this.onParticipantAdded,
    required this.raceId, // Accept raceId as a parameter
  });

  @override
  State<AddParticipantForm> createState() => _AddParticipantFormState();
}

class _AddParticipantFormState extends State<AddParticipantForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bibController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Participant'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter participant name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the participant\'s full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _bibController,
                decoration: const InputDecoration(
                  hintText: 'Enter bib number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the bib number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel button
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final name = _nameController.text.trim();
              final bib = _bibController.text.trim();
              try {
                widget.repo.addParticipant(
                  name: name,
                  bib: bib,
                  raceId: widget.raceId, // Use the raceId passed to the form
                  segmentStartTimes: {},
                  segmentFinishTimes: {},
                  totalTime: '00:00:00',
                );

                widget
                    .onParticipantAdded(); // Notify the parent to refresh the participant list

                Navigator.of(context).pop(); // Close the dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Participant added successfully!'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add participant: $e')),
                );
              }
            }
          }, // Add Participant button
          child: const Text('Add Participant'),
        ),
      ],
    );
  }
}
