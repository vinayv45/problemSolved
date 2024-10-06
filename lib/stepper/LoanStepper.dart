import 'package:flutter/material.dart';
import 'dart:convert'; // Import for JSON decoding
import 'loan_stepper.dart'; // Import your model classes

class LoanStepper extends StatefulWidget {
  @override
  _LoanStepperState createState() => _LoanStepperState();
}

class _LoanStepperState extends State<LoanStepper> {
  List<StepperItem> steps = [];
  StepData currentStatus = StepData(subStage: '', stage: '', product: '');

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  void loadJsonData() {
    String jsonString = '''{
      "data": {
        "subStage": "Offer details",
        "stage": "Qualification",
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

    Map<String, dynamic> jsonData = json.decode(jsonString);
    currentStatus = StepData.fromJson(jsonData['data']);
    steps = (jsonData['stepper-data'] as List)
        .map((step) => StepperItem.fromJson(step))
        .toList();

    // Find the current step index based on subStage
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = steps
        .indexWhere((step) => step.systemSubStage == currentStatus.subStage);

    return Scaffold(
      appBar: AppBar(
        title: Text("Loan Stepper"),
      ),
      body: Stepper(
        currentStep: currentIndex != -1 ? currentIndex : 0,
        steps: steps.map((step) {
          return Step(
            title: Text(step.systemSubStage),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stage: ${step.planetStage}'),
                if (step.planetSub.isNotEmpty) Text('Note: ${step.planetSub}'),
              ],
            ),
            isActive: steps.indexOf(step) <= currentIndex,
            state: steps.indexOf(step) < currentIndex
                ? StepState.complete
                : steps.indexOf(step) == currentIndex
                    ? StepState.editing
                    : StepState.indexed,
          );
        }).toList(),
      ),
    );
  }
}
