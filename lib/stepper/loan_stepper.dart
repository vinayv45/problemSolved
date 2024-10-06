import 'dart:convert';

class StepData {
  final String subStage;
  final String stage;
  final String product;

  StepData(
      {required this.subStage, required this.stage, required this.product});

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      subStage: json['subStage'],
      stage: json['stage'],
      product: json['product'],
    );
  }
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
      sysStage: json['SysStage'],
      systemSubStage: json['SystemSubStage'],
      planetStage: json['PlanetStage'],
      planetSub: json['PlanetSub'],
      stageLevel: json['stageLevel'],
      subStageLevel: json['subStageLevel'],
    );
  }
}
