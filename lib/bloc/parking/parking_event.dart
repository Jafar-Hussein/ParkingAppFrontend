abstract class ParkingEvent {}

class LoadParkingDataEvent extends ParkingEvent {
  final String ownerName;

  LoadParkingDataEvent(this.ownerName);
}

class StartParkingEvent extends ParkingEvent {
  final int spaceId;
  final Map vehicle;
  final String ownerName;

  StartParkingEvent(this.spaceId, this.vehicle, this.ownerName);
}

class StopParkingEvent extends ParkingEvent {
  final int parkingId;
  final Map parking;
  final String ownerName;

  StopParkingEvent(this.parkingId, this.parking, this.ownerName);
}
