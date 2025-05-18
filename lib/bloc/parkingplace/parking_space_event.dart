abstract class ParkingPlaceEvent {}

class LoadParkingSpacesEvent extends ParkingPlaceEvent {}

class AddParkingSpaceEvent extends ParkingPlaceEvent {
  final Map<String, dynamic> parkingSpace;
  final String ownerUid;
  AddParkingSpaceEvent(this.parkingSpace, this.ownerUid);
}

class DeleteParkingSpaceEvent extends ParkingPlaceEvent {
  final String spaceId;
  final String ownerUid;
  DeleteParkingSpaceEvent(this.spaceId, this.ownerUid);
}
