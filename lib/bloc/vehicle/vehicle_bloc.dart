import 'package:flutter_application/bloc/vehicle/vehicle_event.dart';
import 'package:flutter_application/bloc/vehicle/vehicle_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicle_event.dart' as vehEvent;
import 'vehicle_state.dart' as state;
import '../../repository/vehicleRepository.dart';

class VehicleBloc extends Bloc<vehEvent.VehicleEvent, state.VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleBloc(this.vehicleRepository) : super(state.VehicleLoadingState()) {
    on<vehEvent.LoadVehiclesEvent>(_onLoadVehicles);
    on<vehEvent.AddVehicleEvent>(_onAddVehicle);
    on<vehEvent.DeleteVehicleEvent>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(
    vehEvent.LoadVehiclesEvent event,
    Emitter<state.VehicleState> emit,
  ) async {
    emit(state.VehicleLoadingState());
    try {
      final vehicles = await vehicleRepository.getVehicles(event.ownerName);
      emit(state.VehicleLoadedState(vehicles));
    } catch (e) {
      emit(state.VehicleErrorState(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    vehEvent.AddVehicleEvent event,
    Emitter<state.VehicleState> emit,
  ) async {
    try {
      await vehicleRepository.addVehicle(event.vehicle);
      final vehicles = await vehicleRepository.getVehicles(
        event.vehicle['owner']['namn'],
      );
      emit(state.VehicleLoadedState(vehicles));
    } catch (e) {
      emit(state.VehicleErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    vehEvent.DeleteVehicleEvent event,
    Emitter<state.VehicleState> emit,
  ) async {
    try {
      await vehicleRepository.deleteVehicle(event.vehicleId);
      final vehicles = await vehicleRepository.getVehicles(event.ownerName);
      emit(state.VehicleLoadedState(vehicles));
    } catch (e) {
      emit(state.VehicleErrorState(e.toString()));
    }
  }
}
