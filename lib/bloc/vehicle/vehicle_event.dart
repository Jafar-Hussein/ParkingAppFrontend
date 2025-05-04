abstract class VehicleEvent {}

class LoadVehiclesEvent extends VehicleEvent {
  final String ownerName;

  LoadVehiclesEvent(this.ownerName);
}

class AddVehicleEvent extends VehicleEvent {
  final Map<String, dynamic> vehicle;

  AddVehicleEvent(this.vehicle);
}

class DeleteVehicleEvent extends VehicleEvent {
  final int vehicleId;
  final String ownerName;

  DeleteVehicleEvent(this.vehicleId, this.ownerName);
}
