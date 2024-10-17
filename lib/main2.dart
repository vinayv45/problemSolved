// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class SubStage {
//   final String sysStage;
//   final String systemSubStage;
//   final String planetStage;
//   final String planetSub;
//   final int stageLevel;
//   final int subStageLevel;
//   final bool isCompleted;

//   SubStage({
//     required this.sysStage,
//     required this.systemSubStage,
//     required this.planetStage,
//     required this.planetSub,
//     required this.stageLevel,
//     required this.subStageLevel,
//     this.isCompleted = false,
//   });
// }

// class LoanStepper extends StatelessWidget {
//   final List<SubStage> subStages;
//   final String currentSysStage;
//   final String currentSystemSubStage;

//   LoanStepper({
//     required this.subStages,
//     required this.currentSysStage,
//     required this.currentSystemSubStage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Group sub-stages by PlanetStage
//     final Map<String, List<SubStage>> groupedStages = {};
//     for (var subStage in subStages) {
//       if (!groupedStages.containsKey(subStage.planetStage)) {
//         groupedStages[subStage.planetStage] = [];
//       }
//       groupedStages[subStage.planetStage]!.add(subStage);
//     }

//     return Padding(
//       padding: const EdgeInsets.all(18.0),
//       child: ListView.builder(
//         itemCount: groupedStages.length,
//         itemBuilder: (context, index) {
//           final planetStage = groupedStages.keys.elementAt(index);
//           final planetSubs = groupedStages[planetStage]!;

//           // Check if the last sub-stage is completed
//           bool isLastSubStageCompleted = planetSubs.last.isCompleted;

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 planetStage,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               ...planetSubs.map((subStage) {
//                 return Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Column(
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.only(right: 8.0),
//                           height: 10,
//                           width: 10,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: (subStage.systemSubStage ==
//                                         currentSystemSubStage &&
//                                     subStage.sysStage == currentSysStage)
//                                 ? Colors.blue
//                                 : isLastSubStageCompleted
//                                     ? Colors.green
//                                     : Colors.red, // Change this if needed
//                           ),
//                         ),
//                         if (subStage !=
//                             planetSubs
//                                 .last) // To avoid the line for the last item
//                           Container(
//                             width: 2,
//                             height: 40,
//                             color: Colors.grey,
//                           ),
//                       ],
//                     ),
//                     const SizedBox(width: 8), // Space between circle and text
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             subStage.systemSubStage,
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                           if (subStage.planetSub.isNotEmpty)
//                             Text(
//                               subStage.planetSub,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey, // PlanetSub in grey
//                               ),
//                             ),
//                           if (subStage.isCompleted)
//                             const Icon(
//                               Icons.motorcycle,
//                               size: 20,
//                               color: Colors.green,
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//               const SizedBox(height: 20), // Spacer between groups
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text("Loan Process Steps")),
//         body: FutureBuilder<Map<String, dynamic>>(
//           future: loadJsonData(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text("Error loading data"));
//             } else {
//               final data = snapshot.data!;

//               final subStages = (data['stepper-data'] as List)
//                   .map((e) => SubStage(
//                         sysStage: e['SysStage'],
//                         systemSubStage: e['SystemSubStage'],
//                         planetStage: e['PlanetStage'],
//                         planetSub: e['PlanetSub'],
//                         stageLevel: e['stageLevel'],
//                         subStageLevel: e['subStageLevel'],
//                         isCompleted: e['SystemSubStage'] == 'Offer details',
//                       ))
//                   .toList();

//               // Current status based on the JSON structure
//               String currentSysStage = 'Qualification';
//               String currentSystemSubStage = 'KYC docs upload';

//               return LoanStepper(
//                 subStages: subStages,
//                 currentSysStage: currentSysStage,
//                 currentSystemSubStage: currentSystemSubStage,
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
