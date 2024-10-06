import 'package:equatable/equatable.dart';

import '../model/district_model.dart';
import '../model/state_model.dart';

class LocationState extends Equatable {
  final List<StateModel>? states;
  final List<DistrictModel>? districts;

  final String? selectedStateId;
  final String? selectedDistrictId;

  const LocationState({
    this.states,
    this.districts,
    this.selectedStateId,
    this.selectedDistrictId,
  });

  LocationState copyWith({
    List<StateModel>? states,
    List<DistrictModel>? districts,
    bool? isLoading,
    String? selectedStateId,
    String? selectedDistrictId,
  }) {
    return LocationState(
      states: states ?? this.states,
      districts: districts ?? this.districts,
      selectedStateId: selectedStateId ?? this.selectedStateId,
      selectedDistrictId: selectedDistrictId ?? this.selectedDistrictId,
    );
  }

  @override
  List<Object?> get props =>
      [states, districts, selectedStateId, selectedDistrictId];
}
