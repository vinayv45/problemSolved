// import 'package:bloc_features/main.dart';
// import 'package:flutter/material.dart';

// class FlipkartOrderTracker extends StatelessWidget {
//   final Map<String, List<StepperItem>> groupedSteps;
//   final StepData currentStatus;

//   const FlipkartOrderTracker({
//     Key? key,
//     required this.groupedSteps,
//     required this.currentStatus,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(16.0),
//       children: groupedSteps.entries.map((entry) {
//         final String planetStage = entry.key;
//         final List<StepperItem> subSteps = entry.value;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Stage Title (Main Section Heading)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Text(
//                 planetStage,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color:
//                       _isCompleted(planetStage) ? Colors.green : Colors.black,
//                 ),
//               ),
//             ),
//             // Sub-Stages with Icons, Lines and Text
//             Column(
//               children: subSteps.map((step) {
//                 bool isActive = step.systemSubStage == currentStatus.subStage;
//                 bool isCompleted = _isCompleted(planetStage);

//                 return Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Circle and Vertical Line
//                     Column(
//                       children: [
//                         // Circle with check or outline
//                         Container(
//                           width: 24,
//                           height: 24,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: isCompleted ? Colors.green : Colors.white,
//                             border: Border.all(
//                               color: isCompleted ? Colors.green : Colors.grey,
//                               width: 2,
//                             ),
//                           ),
//                           child: Icon(
//                             isCompleted ? Icons.check : Icons.circle_outlined,
//                             color: isCompleted ? Colors.white : Colors.grey,
//                             size: 16,
//                           ),
//                         ),
//                         // Vertical line (solid if completed, dashed if pending)
//                         if (subSteps.indexOf(step) != subSteps.length - 1)
//                           Container(
//                             width: 2,
//                             height: 60,
//                             child: CustomPaint(
//                               painter: isCompleted
//                                   ? SolidLinePainter()
//                                   : DashPainter(),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(width: 10),
//                     // Text (Stage and Sub-stage)
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 5.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Sub-Stage Title
//                             Text(
//                               step.systemSubStage,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: isActive ? Colors.blue : Colors.black,
//                               ),
//                             ),
//                             // Subtitle (if any)
//                             if (step.planetSub.isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4.0),
//                                 child: Text(
//                                   step.planetSub,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   bool _isCompleted(String planetStage) {
//     // Assuming currentStatus.stage indicates the active stage
//     return groupedSteps.keys.toList().indexOf(planetStage) <=
//         groupedSteps.keys.toList().indexOf(currentStatus.stage);
//   }
// }

// // Solid Line Painter for completed stages
// class SolidLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.green
//       ..strokeWidth = 2;

//     canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

// // Dashed Line Painter for pending stages
// class DashPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.grey
//       ..strokeWidth = 2;

//     var max = size.height;
//     var dashWidth = 5;
//     var dashSpace = 5;
//     double startY = 0;

//     while (startY < max) {
//       canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
//       startY += dashWidth + dashSpace;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

// // StepperItem and StepData classes remain the same as in the previous example.
