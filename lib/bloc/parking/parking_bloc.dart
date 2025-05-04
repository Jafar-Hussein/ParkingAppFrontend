import 'package:flutter_bloc/flutter_bloc.dart';
import 'parking_event.dart';
import 'parking_state.dart';
import '../../repository/parkingRepository.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;

  ParkingBloc(this.parkingRepository) : super(ParkingState()) {
    on<LoadParkingDataEvent>(_onLoadParkingDataEvent);
    on<StartParkingEvent>(_onStartParkingEvent);
    on<StopParkingEvent>(_onStopParkingEvent);
  }

  Future<void> _onLoadParkingDataEvent(
    LoadParkingDataEvent event,
    Emitter<ParkingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final history = await parkingRepository.getParkingHistory();
      final spaces = await parkingRepository.getAvailableSpaces();
      final vehicles = await parkingRepository.getVehicles(event.ownerName);

      emit(
        state.copyWith(
          isLoading: false,
          parkingHistory: history.cast<Map<String, dynamic>>(),
          availableSpaces: spaces.cast<Map<String, dynamic>>(),
          vehicles: vehicles.cast<Map<String, dynamic>>(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onStartParkingEvent(
    StartParkingEvent event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      await parkingRepository.startParking(
        event.spaceId,
        event.vehicle,
        event.ownerName,
      );
      add(LoadParkingDataEvent(event.ownerName));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onStopParkingEvent(
    StopParkingEvent event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      await parkingRepository.stopParking(
        event.parkingId,
        event.parking,
        event.ownerName,
      );
      add(LoadParkingDataEvent(event.ownerName));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
