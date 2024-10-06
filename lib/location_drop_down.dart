import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_features/bloc/mandi_bloc.dart';
import 'package:bloc_features/bloc/mandi_event.dart';
import 'package:bloc_features/bloc/mandi_state.dart';

class LocationDropdowns extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state.states == null || state.states!.isEmpty) {
            return const Center(child: Text("No states available"));
          }

          print("Selected state ID: ${state.selectedStateId}");
          print("Selected district ID: ${state.selectedDistrictId}");
          print("Available states: ${state.states?.map((s) => s.id).toList()}");
          print(
              "Available districts: ${state.districts?.map((d) => d.id).toList()}");

          return Column(
            children: [
              DropdownButton<String>(
                hint: const Text("Select State"),
                value: state.selectedStateId != null &&
                        state.states!.any((s) => s.id == state.selectedStateId)
                    ? state.selectedStateId
                    : null,
                items: state.states?.map((state) {
                  return DropdownMenuItem(
                    value: state.id,
                    child: Text(state.name),
                  );
                }).toList(),
                onChanged: (value) {
                  print("selected stated value");
                  print(value);
                  print("selected stated value");
                  // Handle state change and load districts
                  context.read<LocationBloc>().add(StateSelected(value!));
                },
              ),

              // District Dropdown
              DropdownButton<String>(
                hint: Text("Select District"),
                value: state.selectedDistrictId != null &&
                        state.districts!
                            .any((d) => d.id == state.selectedDistrictId)
                    ? state.selectedDistrictId
                    : null, // Ensure the value matches one of the districts
                items: state.districts?.map((district) {
                  return DropdownMenuItem(
                    value: district.id,
                    child: Text(district.name),
                  );
                }).toList(),
                onChanged: (value) {
                  // Handle district change
                  context.read<LocationBloc>().add(DistrictSelected(value!));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
