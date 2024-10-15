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
    final currentSubStage = "Asset Details";

    // Extracting stage level and sub-stage level
    int currentStageLevel = 0;
    int currentSubStageLevel = 0;
    for (var step in data["data"]["applicationContent"][0]["subStages"]) {
      if (step["SysStage"] == currentStage &&
          step["SystemSubStage"] == currentSubStage) {
        currentStageLevel = int.parse(step["stageLevel"].toString());
        currentSubStageLevel = int.parse(step["subStageLevel"].toString());
        break;
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

    groupedSteps =
        groupByPlanetStage(data["data"]["applicationContent"][0]["subStages"]);
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

        // Only show ongoing sub-stages for the current stage
        final List<StepperItem> ongoingSubStages = subSteps.where((step) {
          return step.stageLevel == currentStatus.stageLevel;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planet stage label
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.zero,
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isStageComplete
                              ? Colors.blue
                              : Colors.transparent,
                          border: Border.all(
                            color: isStageComplete
                                ? Colors.transparent
                                : Colors.grey,
                          ),
                        ),
                        child: isStageComplete
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              )
                            : null,
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
                ],
              ),
            ),

            // Render ongoing sub-stages
            ...ongoingSubStages.map(
              (step) {
                bool isActive = step.systemSubStage == currentStatus.subStage &&
                    step.sysStage == currentStatus.stage;
                bool isPrevious =
                    step.subStageLevel <= currentStatus.subStageLevel;

                return step.planetSub.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          top: 0,
                        ),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: List.generate(
                                    4, // Adjust the number of segments in the line
                                    (index) {
                                      return Container(
                                        width: 2,
                                        height:
                                            10, // Height of each line segment
                                        color: isPrevious
                                            ? Colors.blue
                                            : Colors
                                                .grey, // Blue or grey based on completion
                                        margin: EdgeInsets.only(
                                          bottom: isPrevious ? 0 : 4,
                                        ), // Space between segments
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPrevious
                                        ? Colors.blue
                                        : Colors.grey, // Blue or grey dot
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              step.planetSub,
                              style: TextStyle(
                                color: isActive
                                    ? Colors.black
                                    : Colors
                                        .grey, // Black for active, grey for inactive
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),

            // Red line to separate each planet stage
            Padding(
              padding: const EdgeInsets.only(
                left: 26.0,
              ),
              child: isLastElement
                  ? Container() // No red line for the last element
                  : Container(
                      width: 2,
                      height: 40, // Adjust height based on your design
                      color: Colors.red,
                    ),
            ),
          ],
        );
      },
    );
  }
}
