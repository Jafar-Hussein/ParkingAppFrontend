abstract class VehicleEvent {}

class LoadVehiclesEvent extends VehicleEvent {
  final String ownerUid;

  LoadVehiclesEvent(this.ownerUid);
}

class AddVehicleEvent extends VehicleEvent {
  final Map<String, dynamic> vehicle;
  final String ownerUid;
  AddVehicleEvent(this.vehicle, this.ownerUid);
}

class DeleteVehicleEvent extends VehicleEvent {
  final String vehicleId;
  final String ownerName;
  final String ownerUid;
  DeleteVehicleEvent(this.vehicleId, this.ownerName, this.ownerUid);
}
