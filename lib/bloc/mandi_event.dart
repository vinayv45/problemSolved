import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object> get props => [];
}

class LoadStates extends LocationEvent {}

class StateSelected extends LocationEvent {
  final String stateId;

  StateSelected(this.stateId);

  @override
  List<Object> get props => [stateId];
}

class DistrictSelected extends LocationEvent {
  final String districtId;

  DistrictSelected(this.districtId);

  @override
  List<Object> get props => [districtId];
}
