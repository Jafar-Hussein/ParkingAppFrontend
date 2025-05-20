import 'dart:math'; // För att generera 32-bitars ID
import 'package:flutter_bloc/flutter_bloc.dart';
import 'parking_event.dart';
import 'parking_state.dart';
import '../../repository/parkingRepository.dart';
import '../../repository/NotificationRepository.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final NotificationRepository notificationRepository;

  // 🔐 Lagrar notification-id kopplat till parkering-id
  final Map<String, int> _notificationIds = {};

  ParkingBloc(this.parkingRepository, this.notificationRepository)
    : super(ParkingState()) {
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
      final history = await parkingRepository.getParkingHistory(event.ownerUid);
      final spaces = await parkingRepository.getAvailableSpaces();
      final vehicles = await parkingRepository.getVehicles(event.ownerUid);

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
        event.ownerUid,
        address: event.address,
      );

      // 🕒 Skapa ett säkert 32-bitars notis-ID
      final int notificationId =
          DateTime.now().millisecondsSinceEpoch % 1000000;

      // 💾 Koppla notis till en unik key (spaceId + uid)
      final String parkingKey = '${event.spaceId}_${event.ownerUid}';
      _notificationIds[parkingKey] = notificationId;

      final DateTime deliveryTime = DateTime.now().add(
        const Duration(minutes: 2),
      );
      await notificationRepository.scheduleNotification(
        title: 'Parkering pågår',
        content: 'Din parkering avslutas snart!',
        deliveryTime: deliveryTime.subtract(const Duration(minutes: 1)),
        id: notificationId,
      );

      add(LoadParkingDataEvent(event.ownerUid));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onStopParkingEvent(
    StopParkingEvent event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      await parkingRepository.stopParking(event.parkingId, event.parking);

      // Avbryt notisen (om vi har ett ID sparat)
      final String parkingKey = '${event.parkingId}_${event.ownerUid}';
      final int? notificationId = _notificationIds[parkingKey];

      if (notificationId != null) {
        await notificationRepository.cancelNotification(notificationId);
        _notificationIds.remove(parkingKey);
      }

      add(LoadParkingDataEvent(event.ownerUid));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
