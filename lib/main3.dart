import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String jsonString = "";
  Map<String, List<StepperItem>> groupedSteps = {};
  StepData currentStatus = StepData(
    subStage: '',
    stage: '',
    stageLevel: 0,
    subStageLevel: 0,
  );

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var data2 =
        await rootBundle.loadString("assets/json/track_application.json");
    jsonString = data2;
    final data = jsonDecode(jsonString);

    final currentStage = "Qualification";
    final currentSubStage = "EXPIRED";

    // Extracting stage level and sub-stage level
    int currentStageLevel = 0;
    int currentSubStageLevel = 0;

    for (int i = 0; i < data["data"]["applicationContent"].length; i++) {
      if ("TW_ASSISTED" == data["data"]["applicationContent"][i]["lob"]) {
        for (var step in data["data"]["applicationContent"][i]["subStages"]) {
          if (step["SysStage"] == currentStage &&
              step["SystemSubStage"] == currentSubStage) {
            currentStageLevel = int.parse(step["stageLevel"].toString());
            currentSubStageLevel = int.parse(step["subStageLevel"].toString());
          }
        }
      }
    }

    setState(() {
      currentStatus = StepData(
        subStage: currentSubStage,
        stage: currentStage,
        stageLevel: currentStageLevel,
        subStageLevel: currentSubStageLevel,
      );
    });

    for (int i = 0; i < data["data"]["applicationContent"].length; i++) {
      if ("TW_ASSISTED" == data["data"]["applicationContent"][i]["lob"]) {
        groupedSteps = groupByPlanetStage(
            data["data"]["applicationContent"][i]["subStages"]);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  final int subStageLevel;

  StepData({
    required this.subStage,
    required this.stage,
    required this.stageLevel,
    required this.subStageLevel,
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
      stageLevel: int.parse(json["stageLevel"].toString()),
      subStageLevel: int.parse(json["subStageLevel"].toString()),
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
    return ListView.builder(
      itemCount: groupedSteps.length,
      itemBuilder: (context, index) {
        final String planetStage = groupedSteps.keys.elementAt(index);
        final List<StepperItem> subSteps = groupedSteps[planetStage]!;
        bool isLastElement = index == groupedSteps.length - 1;

        // Determine if the planet stage is complete
        bool isStageComplete = subSteps
            .every((step) => step.stageLevel < currentStatus.stageLevel);

        // Ongoing sub-stages for the current stage
        final List<StepperItem> ongoingSubStages = subSteps.where((step) {
          return step.stageLevel == currentStatus.stageLevel;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planet stage row with label and icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Planet stage circle icon
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isStageComplete
                              ? Colors.green
                              : (planetStage == currentStatus.stage)
                                  ? Colors.orange
                                  : Colors.white,
                          border: Border.all(
                            color: isStageComplete
                                ? Colors.green
                                : (planetStage == currentStatus.stage)
                                    ? Colors.orange
                                    : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isStageComplete
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : (planetStage == currentStatus.stage)
                                ? CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : null,
                      ),
                      if (!isLastElement)
                        Container(
                          width: 2,
                          height: 40, // Adjust height of the red line
                          color: Colors.red,
                        ),
                    ],
                  ),
                  // Planet stage text
                  Expanded(
                    child: Text(
                      planetStage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: (planetStage == currentStatus.stage)
                            ? Colors.orange
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Render sub-stages or show "Loan is expired" if current sub-stage is expired
            if (currentStatus.subStage == "EXPIRED")
              Padding(
                padding: const EdgeInsets.only(left: 56.0, top: 8.0),
                child: Text(
                  "Loan is expired",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...ongoingSubStages.map(
                (step) {
                  bool isActive =
                      step.systemSubStage == currentStatus.subStage &&
                          step.sysStage == currentStatus.stage;
                  bool isPrevious =
                      step.subStageLevel <= currentStatus.subStageLevel;

                  return step.planetSub.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 56.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: Row(
                            children: [
                              // Sub-stage step line and dot
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPrevious ? Colors.blue : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Sub-stage text
                              Expanded(
                                child: Text(
                                  step.planetSub,
                                  style: TextStyle(
                                    color:
                                        isActive ? Colors.black : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ).toList(),
          ],
        );
      },
    );
  }
}
