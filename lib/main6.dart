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
      home: HomeScreen2(),
    );
  }
}

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  List completeList = [];
  loadJsonData() async {
    String currentSysStage = "Qualification";
    String currentSysSubStage = "KYC docs upload";
    final data =
        await rootBundle.loadString('assets/json/track_application.json');

    final data2 = jsonDecode(data);
    List stages = [];
    for (int i = 0; i < data2["data"]["applicationContent"].length; i++) {
      if ("TW_ASSISTED" == data2["data"]["applicationContent"][i]["lob"]) {
        for (var step in data2["data"]["applicationContent"][i]["subStages"]) {
          if (step["SysStage"] == currentSysStage &&
              step["SystemSubStage"] == currentSysSubStage) {
            stages.addAll(data2["data"]["applicationContent"][i]["subStages"]);
          }
        }
      }
    }

    Map<String, dynamic> groupStages = {};
    for (Map<String, dynamic> stage in stages) {
      String currentStage = stage['stageLevel'];
      if (groupStages.containsKey(currentStage)) {
        groupStages[currentStage].add(stage);
      } else {
        groupStages.putIfAbsent(
          currentStage,
          () => [
            stage,
          ],
        );
      }
    }
    for (String key in groupStages.keys) {
      List<Map<String, dynamic>> subStages = groupStages[key];
      Map<String, dynamic> stepInformation = {
        "id": key,
        "name": "",
        "status": "Pending",
        "sub_stages": subStages,
      };
      completeList.add(stepInformation);
    }
    for (Map<String, dynamic> stage in completeList) {
      List<Map<String, dynamic>> currentSubStages = stage['sub_stages'];
      List<Map<String, dynamic>> toBeRemovedSubStages = [];
      for (Map<String, dynamic> subStage in currentSubStages) {
        subStage.putIfAbsent("status", () => "Pending");
        if (subStage['SysStage'] == currentSysStage &&
            subStage['SystemSubStage'] == currentSubStages) {
          if (currentSysSubStage == "EXPIRED" ||
              currentSysSubStage == "REJECTED") {
            subStage['status'] = "Failed";
          } else {
            subStage['status'] = "Current";
          }
        } else {
          if (subStage['subStageLevel'] == "0") {
            toBeRemovedSubStages.add(subStage);
          }
        }
      }
      stage['name'] = currentSubStages.first['PlanetStage'];
      currentSubStages.removeWhere((e) => toBeRemovedSubStages.contains(e));
    }
    completeList.sort(
      (current, next) =>
          int.parse(current['id']) < int.parse(next['id']) ? -1 : 1,
    );
    for (int i = 0; i < completeList.length; i++) {
      Map<String, dynamic> currentStage = completeList[i];
      currentStage['sub_stages'].sort(
        (current, next) => int.parse(current['subStageLevel']) <
                int.parse(next['subStageLevel'])
            ? -1
            : 1,
      );
      int containFailedSubStage = currentStage['sub_stages']
          .indexWhere((stage) => stage['status'] == "Failed");
      int containCurrentSubStage = currentStage['sub_stages']
          .indexWhere((stage) => stage['status'] == "Current");
      currentStage['status'] = containFailedSubStage != -1
          ? "Failed"
          : containCurrentSubStage != -1
              ? "Current"
              : "Pending";
      if (containCurrentSubStage != -1 || containFailedSubStage != -1) {
        updatePreviousStages(completeList, i);
        updatePreviousStages(
          currentStage['sub_stages'],
          containFailedSubStage != -1
              ? containFailedSubStage
              : containCurrentSubStage != -1
                  ? containCurrentSubStage
                  : 0,
        );
      }
    }
    for (int i = 0; i < completeList.length; i++) {
      Map<String, dynamic> currentStage = completeList[i];
      if (currentStage["status"] == "Failed") {
        completeList.removeRange(i + 1, completeList.length);
      }
    }
    print(jsonEncode(completeList));
  }

  updatePreviousStages(List list, int currentIndex) {
    for (int i = 0; i < list.length; i++) {
      if (i < currentIndex) {
        list[i]['status'] = "Success";
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
