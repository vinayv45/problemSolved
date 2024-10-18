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
    final List<dynamic> filteredSubStages =
        (stage['status'] == 'Current' && stage['status'] != 'Failed')
            ? stage['sub_stages']
            : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              child: CustomPaint(
                size: Size(
                  20,
                  60 + (filteredSubStages.length * 22),
                ),
                painter: StepperPainter(
                  isComplete: stage['status'] == 'Success',
                  isCurrent: stage['status'] == 'Current',
                  isLast: isLast,
                  subStages: filteredSubStages,
                  status: stage['status'],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  stage['status'] == 'Failed'
                      ? Text(
                          "Application Rejected",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                      : Text(
                          stage['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  if (filteredSubStages.isNotEmpty)
                    ...filteredSubStages.map<Widget>((subStage) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
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
      ],
    );
  }
}

class StepperPainter extends CustomPainter {
  final bool isComplete;
  final bool isCurrent;
  final bool isLast;
  final List<dynamic> subStages;
  final String status;

  StepperPainter({
    required this.isComplete,
    required this.isCurrent,
    required this.isLast,
    required this.subStages,
    required this.status,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..strokeWidth = 2;
    final double circleRadius = status == "Current" ? 8 : 10.0;
    final Offset circleCenter = Offset(size.width / 2, circleRadius);

    // Set color based on the main stage status
    if (status == "Failed") {
      paint.color = Colors.red; // Red circle for failed status
    } else if (isComplete || isCurrent) {
      paint.color = Colors.blue; // Blue for success or current status
    } else {
      paint.color = Colors.grey; // Grey for pending
    }

    // Draw the main circle for the stage
    paint.style =
        status == "Pending" ? PaintingStyle.stroke : PaintingStyle.fill;
    canvas.drawCircle(circleCenter, circleRadius, paint);

    // Draw the close icon if the status is "Failed"
    if (status == "Failed") {
      final double iconSize = 10.0;
      _drawCloseIcon(canvas, circleCenter, iconSize, Colors.white);
    }

    // Draw the check icon if the status is "Success"
    if (status == "Success") {
      final double iconSize = 10.0;
      _drawCheckIcon(
          canvas, circleCenter, iconSize, Colors.white); // Draw check icon
    }

    // Draw the vertical line connecting stages
    if (!isLast) {
      if (isComplete || isCurrent) {
        _drawLine(canvas, Offset(size.width / 2, circleRadius * 2),
            Offset(size.width / 2, size.height), paint);
      } else {
        _drawDottedLine(canvas, Offset(size.width / 2, circleRadius * 2),
            Offset(size.width / 2, size.height), paint);
      }
    }

    // Draw sub-stages
    double startY = circleRadius * 2 + 20;
    for (int i = 0; i < subStages.length; i++) {
      final subStage = subStages[i];
      final bool isSubComplete = subStage['status'] == 'Success';
      final bool isSubCurrent = subStage['status'] == 'Current';
      final bool isSubPending = subStage['status'] == 'Pending';
      final bool isSubFailed = subStage['status'] == 'Failed';

      // Draw sub-stage line only for current or success stages
      if (i > 0) {
        if (isSubComplete || isSubCurrent) {
          paint.color = Colors.blue;
          _drawLine(canvas, Offset(size.width / 2, startY - 20),
              Offset(size.width / 2, startY), paint);
        } else if (isSubPending) {
          paint.color = Colors.grey;
          _drawDottedLine(canvas, Offset(size.width / 2, startY - 20),
              Offset(size.width / 2, startY), paint);
        } else if (isSubFailed) {
          paint.color = Colors.red;
          _drawDottedLine(canvas, Offset(size.width / 2, startY - 20),
              Offset(size.width / 2, startY), paint); // Red dotted line
        }
      }

      // Draw sub-stage dot
      final double dotRadius = 5.0;

      if (isSubCurrent) {
        paint.style = PaintingStyle.fill;
        paint.color = Colors.blue;
        canvas.drawCircle(Offset(size.width / 2, startY), dotRadius, paint);
      } else if (isSubPending) {
        paint.style = PaintingStyle.fill;
        paint.color = Colors.white;
        canvas.drawCircle(Offset(size.width / 2, startY), dotRadius, paint);

        paint.style = PaintingStyle.stroke;
        paint.color = Colors.grey;
        paint.strokeWidth = 1.0;
        canvas.drawCircle(Offset(size.width / 2, startY), dotRadius, paint);
      }

      // Move to the next sub-stage position
      startY += 30;
    }
  }

  void _drawCloseIcon(Canvas canvas, Offset center, double size, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - size / 2, center.dy - size / 2),
      Offset(center.dx + size / 2, center.dy + size / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + size / 2, center.dy - size / 2),
      Offset(center.dx - size / 2, center.dy + size / 2),
      paint,
    );
  }

  void _drawCheckIcon(Canvas canvas, Offset center, double size, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - size / 3, center.dy),
      Offset(center.dx - size / 6, center.dy + size / 3),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - size / 6, center.dy + size / 3),
      Offset(center.dx + size / 3, center.dy - size / 3),
      paint,
    );
  }

  void _drawLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 5.0;
    const double dashSpace = 3.0;
    double distance = (end - start).distance;
    final double dx = (end.dx - start.dx) / distance;
    final double dy = (end.dy - start.dy) / distance;

    double x = start.dx;
    double y = start.dy;

    while (distance >= 0) {
      canvas.drawLine(
          Offset(x, y), Offset(x + dashWidth * dx, y + dashWidth * dy), paint);
      x += (dashWidth + dashSpace) * dx;
      y += (dashWidth + dashSpace) * dy;
      distance -= dashWidth + dashSpace;
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
        "status": "Current"
      },
      {
        "SysStage": "Qualification",
        "SystemSubStage": "Asset Details",
        "PlanetStage": "Credit / KYC Authentication",
        "PlanetSub": "Please select your asset",
        "stageLevel": "2",
        "subStageLevel": "3",
        "status": "Current"
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
    "status": "Failed",
    "sub_stages": [
      {
        "SysStage": "Sanction",
        "SystemSubStage": "Loan Sanction With Eligibility",
        "PlanetStage": "Loan Sanction Approval",
        "PlanetSub": "Loan Sanctioned",
        "stageLevel": "3",
        "subStageLevel": "1",
        "status": "Failed"
      }
    ]
  },
];
