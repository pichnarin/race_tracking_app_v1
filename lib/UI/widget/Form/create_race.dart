import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/race_provider.dart';
import 'package:race_tracking_app_v1/model/race_segments_detail.dart';
import 'package:race_tracking_app_v1/model/races.dart';

class CreateRaceForm extends StatefulWidget {
  final void Function(Race createdRace) onRaceCreated;

  const CreateRaceForm({
    super.key,
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
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  Future<void> _createRace() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both date and time')),
        );
        return;
      }

      _formKey.currentState!.save();

      final startTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final raceSegments = {
        'swimming': RaceSegmentDetail(distance: swimming),
        'cycling': RaceSegmentDetail(distance: cycling),
        'running': RaceSegmentDetail(distance: running),
      };

      setState(() {
        _isSubmitting = true;
      });

      try {
        final raceProvider = Provider.of<RaceProvider>(context, listen: false);
        final createdRace = await raceProvider.createRace(
          name: raceName,
          status: RaceStatus.upcoming,
          startTime: startTime,
          segments: raceSegments,
          location: location,
        );

        widget.onRaceCreated(createdRace);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Race created with UID: ${createdRace.uid}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create race: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Race"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Race Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter race name' : null,
                onSaved: (value) => raceName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter location' : null,
                onSaved: (value) => location = value!,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'No date chosen'
                          : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() => selectedDate = date);
                            }
                          },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedTime == null
                          ? 'No time chosen'
                          : 'Time: ${selectedTime!.format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() => selectedTime = time);
                            }
                          },
                    child: const Text('Pick Time'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Swimming Distance',
                ),
                onSaved: (value) => swimming = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cycling Distance',
                ),
                onSaved: (value) => cycling = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Running Distance',
                ),
                onSaved: (value) => running = value ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _createRace,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
