import 'package:flutter_application/bloc/vehicle/vehicle_event.dart';
import 'package:flutter_application/bloc/vehicle/vehicle_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/vehicleRepository.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleBloc(this.vehicleRepository) : super(VehicleLoadingState()) {
    on<LoadVehiclesEvent>(_onLoadVehicles);
    on<AddVehicleEvent>(_onAddVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(
    LoadVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoadingState());
    try {
      final vehicles = await vehicleRepository.getVehicles(event.ownerUid);
      emit(VehicleLoadedState(vehicles));
    } catch (e) {
      emit(VehicleErrorState(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      print("🟢 addVehicle skickas: ${event.vehicle}");

      await vehicleRepository.addVehicle(event.vehicle);

      final vehicles = await vehicleRepository.getVehicles(event.ownerUid);

      print("🟢 Hämtade fordon: $vehicles");

      emit(VehicleLoadedState(vehicles));
    } catch (e) {
      print("🔴 Fel vid lägg till fordon: $e");
      emit(VehicleErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await vehicleRepository.deleteVehicle(event.vehicleId);
      final vehicles = await vehicleRepository.getVehicles(event.ownerUid);
      emit(VehicleLoadedState(vehicles));
    } catch (e) {
      emit(VehicleErrorState(e.toString()));
    }
  }
}
