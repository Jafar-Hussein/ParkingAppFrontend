abstract class ParkingPlaceEvent {}

class LoadParkingSpacesEvent extends ParkingPlaceEvent {}

class AddParkingSpaceEvent extends ParkingPlaceEvent {
  final Map<String, dynamic> parkingSpace;

  AddParkingSpaceEvent(this.parkingSpace);
}

class DeleteParkingSpaceEvent extends ParkingPlaceEvent {
  final int spaceId;

  DeleteParkingSpaceEvent(this.spaceId);
}
