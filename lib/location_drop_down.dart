import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Stepper with Painter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Stepper')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: stages.length,
          itemBuilder: (context, index) {
            return CustomStepper(
              stage: stages[index],
              isLast: index == stages.length - 1,
            );
          },
        ),
      ),
    );
  }
}

class CustomStepper extends StatelessWidget {
  final Map<String, dynamic> stage;
  final bool isLast;

  CustomStepper({required this.stage, required this.isLast});

  @override
  Widget build(BuildContext context) {
    // Show all sub-stages if the stage is current, otherwise display only the stage name.
    final List<dynamic> filteredSubStages =
        stage['status'] == 'Current' ? stage['sub_stages'] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              child: CustomPaint(
                size: Size(20, 100),
                painter: StepperPainter(
                  isComplete: stage['status'] == 'Success',
                  isCurrent: stage['status'] == 'Current',
                  isLast: isLast,
                  subStages: filteredSubStages,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Always display the main stage name.
                  Text(
                    stage['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Display the sub-stages if they exist and the current stage is active.
                  if (filteredSubStages.isNotEmpty)
                    ...filteredSubStages.map<Widget>((subStage) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0), // Add space between each sub-stage
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(subStage['PlanetSub']),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class StepperPainter extends CustomPainter {
  final bool isComplete;
  final bool isCurrent;
  final bool isLast;
  final List<dynamic> subStages;

  StepperPainter({
    required this.isComplete,
    required this.isCurrent,
    required this.isLast,
    required this.subStages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..strokeWidth = 2.0;
    final double circleRadius = 10.0;
    final Offset circleCenter = Offset(size.width / 2, circleRadius);

    // Draw the main circle for the stage
    paint.color = isComplete ? Colors.blue : Colors.grey;
    canvas.drawCircle(
      circleCenter,
      circleRadius,
      paint..style = PaintingStyle.stroke,
    );

    if (isComplete || isCurrent) {
      canvas.drawCircle(
        circleCenter,
        circleRadius - 2,
        paint..style = PaintingStyle.fill,
      );
    }

    // Draw sub-stage indicators and connecting lines
    double startY = circleRadius * 2 + 10; // Start position for sub-stages

    for (int i = 0; i < subStages.length; i++) {
      final subStage = subStages[i];
      final bool isSubComplete = subStage['status'] == 'Success';
      final bool isSubCurrent = subStage['status'] == 'Current';

      // Draw the connecting line for completed sub-stages
      if (i > 0) {
        double previousY =
            startY - 40; // Calculate the previous Y position for the line

        if (isSubComplete) {
          paint.color = Colors.blue; // Solid blue line for completed
          canvas.drawLine(
            Offset(size.width / 2, previousY + 10), // Adjust for dot radius
            Offset(size.width / 2, startY - 10), // Adjust for dot radius
            paint,
          );
        } else {
          // Draw a dashed line for pending sub-stages
          paint.color = Colors.grey;

          double dashWidth = 4.0;
          double dashSpace = 2.0;
          double startYDashed = previousY + 10; // Adjust for dot radius
          double endYDashed = startY - 10; // Adjust for dot radius

          // Calculate the total length of the line
          double lineLength = endYDashed - startYDashed;
          int dashCount = (lineLength / (dashWidth + dashSpace)).floor();

          for (int j = 0; j < dashCount; j++) {
            double startX = size.width / 2;
            double startYDash = startYDashed + j * (dashWidth + dashSpace);
            double endYDash = startYDash + dashWidth;

            canvas.drawLine(
              Offset(startX, startYDash),
              Offset(startX, endYDash),
              paint,
            );
          }
        }
      }

      // Draw the sub-stage dot
      paint.style = PaintingStyle.fill;
      paint.color = isSubCurrent
          ? Colors.blue // Set the color to blue if it's the current stage
          : isSubComplete
              ? Colors.green
              : Colors.grey;

      canvas.drawCircle(
        Offset(size.width / 2, startY),
        5.0,
        paint,
      );

      // Move to the next sub-stage position
      startY += 40; // Increase the space between sub-stages
    }

    // Draw the main connecting line (if not last stage)
    if (!isLast) {
      paint.color = isComplete || isCurrent ? Colors.blue : Colors.grey;
      canvas.drawLine(
        Offset(size.width / 2, circleRadius * 2),
        Offset(size.width / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

final List<Map<String, dynamic>> stages = [
  {
    "id": "1",
    "name": "Application Initiation",
    "status": "Success",
    "sub_stages": []
  },
  {
    "id": "2",
    "name": "Credit / KYC Authentication",
    "status": "Current",
    "sub_stages": [
      {
        "SysStage": "Qualification",
        "SystemSubStage": "KYC docs upload",
        "PlanetStage": "Credit / KYC Authentication",
        "PlanetSub": "KYC docs upload",
        "stageLevel": "2",
        "subStageLevel": "1",
        "status": "Current"
      },
      {
        "SysStage": "Qualification",
        "SystemSubStage": "Income Details",
        "PlanetStage": "Credit / KYC Authentication",
        "PlanetSub": "Awaiting Income Document for offer enhancement",
        "stageLevel": "2",
        "subStageLevel": "2",
        "status": "Pending"
      },
      {
        "SysStage": "Qualification",
        "SystemSubStage": "Asset Details",
        "PlanetStage": "Credit / KYC Authentication",
        "PlanetSub": "Please select your asset",
        "stageLevel": "2",
        "subStageLevel": "3",
        "status": "Pending"
      },
      {
        "SysStage": "Qualification",
        "SystemSubStage": "Offer details",
        "PlanetStage": "Credit / KYC Authentication",
        "PlanetSub": "Select your offer tenure and amount",
        "stageLevel": "2",
        "subStageLevel": "4",
        "status": "Pending"
      }
    ]
  },
  {
    "id": "3",
    "name": "Loan Sanction Approval",
    "status": "Pending",
    "sub_stages": [
      {
        "SysStage": "Sanction",
        "SystemSubStage": "Loan Sanction With Eligibility",
        "PlanetStage": "Loan Sanction Approval",
        "PlanetSub": "Loan Sanctioned",
        "stageLevel": "3",
        "subStageLevel": "1",
        "status": "Pending"
      }
    ]
  },
  {
    "id": "4",
    "name": "Disbursement Formalities",
    "status": "Pending",
    "sub_stages": [
      {
        "SysStage": "Formalities",
        "SystemSubStage": "Account Setup",
        "PlanetStage": "Disbursement Formalities",
        "PlanetSub": "Upload your account details",
        "stageLevel": "4",
        "subStageLevel": "1",
        "status": "Pending"
      }
    ]
  },
  {
    "id": "5",
    "name": "Loan Disbursement",
    "status": "Pending",
    "sub_stages": []
  },
];
