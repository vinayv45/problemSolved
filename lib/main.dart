import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Stepper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String jsonString = '''{
        "data": {
           "subStage": "Document Verification",
           "stage": "Disbusement",
           "product": "Two Wheeler"
        },
        "stepper-data": [
          {
            "SysStage": "Qualification",
            "SystemSubStage": "KYC docs upload",
            "PlanetStage": "Credit / KYC Authentication",
            "PlanetSub": "",
            "stageLevel": 2,
            "subStageLevel": 1
          },
          {
            "SysStage": "Qualification",
            "SystemSubStage": "Income Details",
            "PlanetStage": "Credit / KYC Authentication",
            "PlanetSub": "",
            "stageLevel": 2,
            "subStageLevel": 2
          },
          {
            "SysStage": "Qualification",
            "SystemSubStage": "Asset Details",
            "PlanetStage": "Credit / KYC Authentication",
            "PlanetSub": "Please select your asset",
            "stageLevel": 2,
            "subStageLevel": 3
          },
          {
            "SysStage": "Qualification",
            "SystemSubStage": "Offer details",
            "PlanetStage": "Credit / KYC Authentication",
            "PlanetSub": "Select your offer tenure and amount",
            "stageLevel": 2,
            "subStageLevel": 4
          },
          {
            "SysStage": "Sanction",
            "SystemSubStage": "Loan Sanction With Eligibility",
            "PlanetStage": "Loan Sanction Approval",
            "PlanetSub": "Loan Sanctioned",
            "stageLevel": 3,
            "subStageLevel": 1
          },
          {
            "SysStage": "Disbusement",
            "SystemSubStage": "Disbusement Form",
            "PlanetStage": "Disbusement Formalities",
            "PlanetSub": "Awaiting Bank & Other Details",
            "stageLevel": 4,
            "subStageLevel": 1
          },
          {
            "SysStage": "Disbusement",
            "SystemSubStage": "Mandate Setup",
            "PlanetStage": "Disbusement Formalities",
            "PlanetSub": "Mandate Setup",
            "stageLevel": 4,
            "subStageLevel": 2
          },
          {
            "SysStage": "Disbusement",
            "SystemSubStage": "E-DOC",
            "PlanetStage": "Disbusement Formalities",
            "PlanetSub": "Loan Agreement Execution",
            "stageLevel": 4,
            "subStageLevel": 3
          },
          {
            "SysStage": "Disbusement",
            "SystemSubStage": "Document Verification",
            "PlanetStage": "Disbusement Formalities",
            "PlanetSub": "Documents are getting verified",
            "stageLevel": 4,
            "subStageLevel": 4
          },
          {
            "SysStage": "Disbusement",
            "SystemSubStage": "Online Welcome Kit",
            "PlanetStage": "Loan Disbursed",
            "PlanetSub": "Online Welcome Kit",
            "stageLevel": 5,
            "subStageLevel": 1
          }
        ]
      }''';

  @override
  Widget build(BuildContext context) {
    final data = jsonDecode(jsonString);

    // Extracting stage level based on the current stage and sub-stage
    int currentStageLevel = 0;

    for (var step in data["stepper-data"]) {
      if (step["SysStage"] == data["data"]["stage"] &&
          step["SystemSubStage"] == data["data"]["subStage"]) {
        currentStageLevel = step["stageLevel"];
        break; // Exit once we find the matching step
      }
    }

    final currentStatus = StepData(
      subStage: data["data"]["subStage"],
      stage: data["data"]["stage"],
      stageLevel: currentStageLevel,
    );

    // Group step data by PlanetStage
    final groupedSteps = groupByPlanetStage(data["stepper-data"]);

    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Stepper'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TimelineStepper(
          groupedSteps: groupedSteps,
          currentStatus: currentStatus,
        ),
      ),
    );
  }

  Map<String, List<StepperItem>> groupByPlanetStage(List<dynamic> stepData) {
    Map<String, List<StepperItem>> groupedSteps = {};

    for (var step in stepData) {
      String planetStage = step["PlanetStage"];
      if (!groupedSteps.containsKey(planetStage)) {
        groupedSteps[planetStage] = [];
      }
      groupedSteps[planetStage]!.add(StepperItem.fromJson(step));
    }

    return groupedSteps;
  }
}

class StepData {
  final String subStage;
  final String stage;
  final int stageLevel;

  StepData({
    required this.subStage,
    required this.stage,
    required this.stageLevel,
  });
}

class StepperItem {
  final String sysStage;
  final String systemSubStage;
  final String planetStage;
  final String planetSub;
  final int stageLevel;
  final int subStageLevel;

  StepperItem({
    required this.sysStage,
    required this.systemSubStage,
    required this.planetStage,
    required this.planetSub,
    required this.stageLevel,
    required this.subStageLevel,
  });

  factory StepperItem.fromJson(Map<String, dynamic> json) {
    return StepperItem(
      sysStage: json["SysStage"],
      systemSubStage: json["SystemSubStage"],
      planetStage: json["PlanetStage"],
      planetSub: json["PlanetSub"],
      stageLevel: json["stageLevel"],
      subStageLevel: json["subStageLevel"],
    );
  }
}

class TimelineStepper extends StatelessWidget {
  final Map<String, List<StepperItem>> groupedSteps;
  final StepData currentStatus;

  const TimelineStepper({
    Key? key,
    required this.groupedSteps,
    required this.currentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: groupedSteps.entries.map((entry) {
        final String planetStage = entry.key;
        final List<StepperItem> subSteps = entry.value;
        bool isComplete = true;

        // Check if each stage and its sub-stage is complete
        for (var step in subSteps) {
          if (step.stageLevel < currentStatus.stageLevel) {
            isComplete = true; // Mark as completed if earlier stage
          } else if (step.stageLevel == currentStatus.stageLevel) {
            if (step.systemSubStage == currentStatus.subStage) {
              isComplete =
                  true; // Mark as complete if current stage and sub-stage match
            } else {
              isComplete = false; // Otherwise mark as not complete
            }
          } else {
            isComplete = false; // Future stages are not complete
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  Transform.translate(
                    offset: const Offset(0, 0),
                    child: Checkbox(
                      fillColor: isComplete
                          ? const WidgetStatePropertyAll(Colors.blue)
                          : const WidgetStatePropertyAll(Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      value: isComplete,
                      onChanged: null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      planetStage,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Column(
                children: subSteps.map((step) {
                  bool isActive =
                      step.systemSubStage == currentStatus.subStage &&
                          step.sysStage == currentStatus.stage;
                  bool isLastItem = step == subSteps.last;
                  bool isCompletedStage =
                      step.stageLevel < currentStatus.stageLevel;

                  // Pass 'isComplete' to all the completed lines in the painter
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          CustomPaint(
                            size: const Size(8, 40),
                            painter: TimelinePainter(
                              isActive: isActive,
                              isComplete: isCompletedStage ||
                                  step.stageLevel == currentStatus.stageLevel &&
                                      step.subStageLevel <=
                                          currentStatus
                                              .stageLevel, // All previous lines blue
                              isLastItem: isLastItem,
                              isFirstItem: step == subSteps.first,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      if (step.planetSub.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 30, top: 10),
                          child: Text(
                            step.planetSub,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final bool isComplete;
  final bool isActive;
  final bool isLastItem;
  final bool isFirstItem;

  TimelinePainter({
    required this.isComplete,
    required this.isActive,
    required this.isLastItem,
    required this.isFirstItem,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..strokeWidth = 2.0
      ..color = isComplete || isActive ? Colors.blue : Colors.grey
      ..style = PaintingStyle.stroke;

    double startY = 0; // Always start from the top of the widget
    double endY = size.height;

    if (!isComplete && !isActive) {
      // Draw dotted line for incomplete steps
      _drawDottedLine(canvas, size, linePaint, startY, endY);
    } else {
      // Draw solid line for completed steps
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, endY),
        linePaint,
      );
    }

    // Draw the dot for completed and active sub-stages with white fill and grey outline
    if (isComplete || isActive) {
      _drawSolidCircle(canvas, size);
    } else {
      _drawOutlinedCircle(canvas, size);
    }
  }

  void _drawDottedLine(
      Canvas canvas, Size size, Paint paint, double startY, double endY) {
    const double dashHeight = 4; // Height of a dash
    const double dashSpacing = 4; // Space between dashes

    double y = startY;
    while (y < endY) {
      // Draw individual dash
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashHeight),
        paint,
      );
      y += dashHeight + dashSpacing; // Move to the next dash position
    }
  }

  void _drawSolidCircle(Canvas canvas, Size size) {
    Paint solidCirclePaint = Paint()
      ..color = Colors.blue // Blue filled for completed or active steps
      ..style = PaintingStyle.fill;

    double iconSize = 4.0; // Set the size for the dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      iconSize,
      solidCirclePaint,
    );
  }

  void _drawOutlinedCircle(Canvas canvas, Size size) {
    Paint fillPaint = Paint()
      ..color = Colors.white // White fill color
      ..style = PaintingStyle.fill;

    Paint outlinePaint = Paint()
      ..color = Colors.grey // Grey outline for incomplete steps
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double iconSize = 4.0; // Set the size for the dot

    // Draw white-filled circle first
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      iconSize,
      fillPaint,
    );

    // Then draw the grey outline
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      iconSize,
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
