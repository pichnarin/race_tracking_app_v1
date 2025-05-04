import 'package:flutter/material.dart';
import '../../../data/firebase/fire_race_repo.dart';
import '../../../data/model/races.dart';

class AddParticipantForm extends StatefulWidget {
   const AddParticipantForm({super.key});
 
   @override
   State<AddParticipantForm> createState() => _AddParticipantFormState();
 }
 
 class _AddParticipantFormState extends State<AddParticipantForm> {
   final FireRaceRepo repo = FireRaceRepo();
   final _formKey = GlobalKey<FormState>();
   final TextEditingController _nameController = TextEditingController();
   final TextEditingController _bibController = TextEditingController();
   String? _selectedRaceId;
   List<Race> _races = [];
 
   @override
   void initState() {
     super.initState();
     _fetchRaces(); // Call fetch on init
   }
 
   Future<void> _fetchRaces() async {
     try {
       var races = await repo.fetchRaces(); // Map<String, Race>
       List<Race> raceList = races.values.toList();
       setState(() {
         _races = raceList;
       });
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to fetch races: $e')),
       );
     }
   }
 
   @override
   Widget build(BuildContext context) {
     return MaterialApp( // Wrapping with MaterialApp
       home: Scaffold(
         appBar: AppBar(
           title: const Text('Add Participant', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B389B)),),
         ),
         body: Form(
           key: _formKey,
           child: SingleChildScrollView(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 const Text(
                   'Full Name',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
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
                 const Text(
                   'Bib Number',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
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
                 const SizedBox(height: 16.0),
                 const Text(
                   'Race',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
                 DropdownButtonFormField<String>(
                   decoration: const InputDecoration(
                     hintText: 'Select Race',
                     border: OutlineInputBorder(),
                   ),
                   value: _selectedRaceId,
                   items: _races.map((race) {
                     return DropdownMenuItem<String>(
                       value: race.uid,
                       child: Text(race.name),
                     );
                   }).toList(),
                   onChanged: (String? newValue) {
                     setState(() {
                       _selectedRaceId = newValue;
                     });
                   },
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please select a race';
                     }
                     return null;
                   },
                 ),
                 const SizedBox(height: 24.0),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: <Widget>[
                     TextButton(
                       onPressed: () {
                         Navigator.pop(context);
                       },
                       child: const Text('Cancel'),
                     ),
                     const SizedBox(width: 8.0),
                     ElevatedButton(
                       onPressed: () async {
                         if (_formKey.currentState!.validate()) {
                           final name = _nameController.text.trim();
                           final bib = _bibController.text.trim();
                           try {
                             final participant = await repo.addParticipant(
                               name: name,
                               bib: bib,
                               raceId: _selectedRaceId!,
                               segmentStartTimes: {},
                               segmentFinishTimes: {},
                               totalTime: '00:00:00',
                             );
                            // Participant added successfully
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Participant added successfully!')),
                             );
                              // Navigate back to the previous screen after a short delay
                             Future.delayed(const Duration(seconds: 1), () {
                               Navigator.pop(context);
                             });
 
 ;                          } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Failed to add participant: $e')),
                             );
                           }
                         }
                       },
                       child: const Text('Add Participant'),
                     ),
                   ],
                 ),
               ],
             ),
           ),
         ),
       ),
     );
   }
 }