import 'package:flutter_bloc/flutter_bloc.dart';
import 'parking_space_event.dart';
import 'parking_space_state.dart';
import '../../repository/ParkingSpaceRepository.dart';

class ParkingPlaceBloc extends Bloc<ParkingPlaceEvent, ParkingSpaceState> {
  final Parkingspacerepository repository;

  ParkingPlaceBloc(this.repository) : super(ParkingPlaceLoadingState()) {
    on<LoadParkingSpacesEvent>(_onLoadSpaces);
    on<AddParkingSpaceEvent>(_onAddSpace);
    on<DeleteParkingSpaceEvent>(_onDeleteSpace);
  }

  Future<void> _onLoadSpaces(
    LoadParkingSpacesEvent event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    emit(ParkingPlaceLoadingState());
    try {
      final spaces = await repository.getAll();
      emit(ParkingPlaceLoadedState(spaces));
    } catch (e) {
      emit(ParkingPlaceErrorState(e.toString()));
    }
  }

  Future<void> _onAddSpace(
    AddParkingSpaceEvent event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    try {
      await repository.add(event.parkingSpace);
      final updated = await repository.getAll();
      emit(ParkingPlaceLoadedState(updated));
    } catch (e) {
      emit(ParkingPlaceErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteSpace(
    DeleteParkingSpaceEvent event,
    Emitter<ParkingSpaceState> emit,
  ) async {
    try {
      await repository.delete(event.spaceId);
      final updated = await repository.getAll();
      emit(ParkingPlaceLoadedState(updated));
    } catch (e) {
      emit(ParkingPlaceErrorState(e.toString()));
    }
  }
}
