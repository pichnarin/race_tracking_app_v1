// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking_app_v1/UI/provider/participant_provider.dart';

class AddParticipantForm extends StatefulWidget {
  final void Function() onParticipantAdded;
  final String raceId;

  const AddParticipantForm({
    super.key,
    required this.onParticipantAdded,
    required this.raceId,
  });

  @override
  State<AddParticipantForm> createState() => _AddParticipantFormState();
}

class _AddParticipantFormState extends State<AddParticipantForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bibController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bibController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    final participantProvider = Provider.of<ParticipantProvider>(context, listen: false);
    
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
          onPressed: _isSubmitting 
              ? null 
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting 
              ? null 
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text.trim();
                    final bib = _bibController.text.trim();
                    
                    setState(() {
                      _isSubmitting = true;
                    });
                    
                    try {
                      await participantProvider.addParticipant(
                        name: name,
                        bib: bib,
                        raceId: widget.raceId,
                      );

                      widget.onParticipantAdded();
                      
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Participant added successfully!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add participant: $e')),
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
                },
          child: _isSubmitting 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add Participant'),
        ),
      ],
    );
  }
}