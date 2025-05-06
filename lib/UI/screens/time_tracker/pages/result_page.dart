import 'package:flutter/material.dart';
import 'package:race_tracking_app_v1/UI/theme/app_color.dart'; 
import '../../../widget/global/participants_table.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  final List<Map<String, dynamic>> dummyParticipants = const [
    {
      'bib': '001',
      'name': 'Panhavath',
      'totalTime': '00:32:45',
    },
    {
      'bib': '002',
      'name': 'Pich',
      'totalTime': '00:30:21',
    },
    {
      'bib': '003',
      'name': 'Yuth',
      'totalTime': '00:35:10',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          title: const Center(
            child: Text(
              "Result Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/flag.png', 
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ParticipantTable(participants: dummyParticipants),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
