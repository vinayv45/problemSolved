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

    final currentStage = data['data']['applicationDetails'][0]['stage'];
    final currentSubStage = data['data']['applicationDetails'][0]['subStage'];

    // Debug output
    print("Current Stage: $currentStage");
    print("Current SubStage: $currentSubStage");

    // Extracting stage level
    int currentStageLevel = 0;
    for (var step in data["data"]["applicationContent"][0]["subStages"]) {
      if (step["SysStage"] == currentStage &&
          step["SystemSubStage"] == currentSubStage) {
        currentStageLevel = int.parse(step["stageLevel"].toString());
        break; // Exit once we find the matching step
      }
    }

    setState(() {
      currentStatus = StepData(
        subStage: currentSubStage,
        stage: currentStage,
        stageLevel: currentStageLevel,
      );
    });

    // Debug output for currentStatus
    print(
        "Current Status: ${currentStatus.subStage}, ${currentStatus.stage}, ${currentStatus.stageLevel}");

    // Group step data
    groupedSteps =
        groupByPlanetStage(data["data"]["applicationContent"][0]["subStages"]);
    setState(() {});

    // Debug output for grouped steps
    print("Grouped Steps: $groupedSteps");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TimelineStepper(
            groupedSteps: groupedSteps,
            currentStatus: currentStatus,
          )),
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

        // Determine if the planet stage is complete
        bool isStageComplete = subSteps
            .every((step) => step.stageLevel < currentStatus.stageLevel);

        // Only show ongoing sub-stages for the current stage
        final List<StepperItem> ongoingSubStages = subSteps.where((step) {
          return step.stageLevel ==
              currentStatus.stageLevel; // Only include ongoing stages
        }).toList();

        bool arePreviousStagesComplete =
            groupedSteps.keys.take(index).every((key) {
          final previousSteps = groupedSteps[key]!;
          return previousSteps.every((step) {
            return step.stageLevel < currentStatus.stageLevel;
          });
        });

        print(
            "Are Previous Stages Complete for index $index: $arePreviousStagesComplete");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planet stage label
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                bottom: 0,
              ),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.zero,
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isStageComplete
                          ? Colors.blue
                          : Colors.transparent, // Filled if complete
                      border: Border.all(
                          color: isStageComplete
                              ? Colors.transparent
                              : Colors.grey), // Outline if not complete
                    ),
                    child: isStageComplete
                        ? const Icon(
                            Icons.check,
                            color: Colors.white, // Check icon color
                            size: 12, // Adjust size as needed
                          )
                        : null, // No icon for incomplete stages
                  ),
                  const SizedBox(width: 10),
                  Text(
                    planetStage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            if (isStageComplete) ...[
              Padding(
                padding: const EdgeInsets.only(
                  left: 26.0,
                  bottom: 0,
                  top: 0,
                ),
                child: Column(
                  children: List.generate(
                    4,
                    (index) {
                      return Container(
                        height: 10,
                        width: 2,
                        color: Colors.blue,
                        margin: const EdgeInsets.only(
                            right: 4), // Space between bars
                      );
                    },
                  ),
                ),
              ),
            ],

            ...ongoingSubStages.map(
              (step) {
                print("step ${step.systemSubStage}");
                bool isActive = step.systemSubStage == currentStatus.subStage &&
                    step.sysStage == currentStatus.stage;

                return step.planetSub.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          top: 0,
                        ),
                        child: Row(
                          children: [
                            // Check if previous stages are complete to show grey or blue dots
                            arePreviousStagesComplete
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        children: List.generate(
                                          4,
                                          (index) {
                                            return Container(
                                              width: 2,
                                              height: 10, // Height of each dot
                                              color: Colors.blue,
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        children: List.generate(
                                          4,
                                          (index) {
                                            return Container(
                                              width: 2,
                                              height: 10, // Height of each dot
                                              color: Colors.grey,
                                              margin: const EdgeInsets.only(
                                                bottom: 4,
                                              ), // Space between dots
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                            const SizedBox(width: 8),
                            Text(
                              step.systemSubStage,
                              style: TextStyle(
                                color: isActive ? Colors.black : Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          ],
        );
      },
    );
  }
}
