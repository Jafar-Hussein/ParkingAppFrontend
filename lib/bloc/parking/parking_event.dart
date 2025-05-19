abstract class ParkingEvent {}

class LoadParkingDataEvent extends ParkingEvent {
  final String ownerUid;
  LoadParkingDataEvent(this.ownerUid);
}

class StartParkingEvent extends ParkingEvent {
  final String spaceId;
  final Map<String, dynamic> vehicle;
  final String ownerUid;
  final String address; // <--- Lägg till

  StartParkingEvent(this.spaceId, this.vehicle, this.ownerUid, this.address);
}

class StopParkingEvent extends ParkingEvent {
  final String parkingId;
  final Map<String, dynamic> parking;
  final String ownerUid;
  final String vehicleId;

  StopParkingEvent(this.parkingId, this.parking, this.ownerUid, this.vehicleId);
}
