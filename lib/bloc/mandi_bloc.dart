import 'package:bloc_features/bloc/mandi_event.dart';
import 'package:bloc_features/bloc/mandi_state.dart';
import 'package:bloc_features/model/district_model.dart';
import 'package:bloc_features/model/state_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  static final List<StateModel> states = [
    StateModel(id: '1', name: 'State A'),
    StateModel(id: '2', name: 'State B'),
  ];

  static final List<DistrictModel> districts = [
    DistrictModel(id: '1', name: 'District A1', stateId: '1'),
    DistrictModel(id: '2', name: 'District A2', stateId: '1'),
    DistrictModel(id: '3', name: 'District B1', stateId: '2'),
    DistrictModel(id: '4', name: 'District B2', stateId: '2'),
  ];

  LocationBloc() : super(LocationState(districts: districts, states: states)) {
    on<LoadStates>((event, emit) {
      emit(state.copyWith(isLoading: false, states: states));
    });

    on<StateSelected>((event, emit) {
      final filteredDistricts = districts
          .where((district) => district.stateId == event.stateId)
          .toList();

      emit(state.copyWith(
        selectedStateId: event.stateId,
        districts: filteredDistricts,
        selectedDistrictId: null,
      ));
    });

    on<DistrictSelected>((event, emit) {
      emit(state.copyWith(selectedDistrictId: event.districtId));
    });
  }
}
