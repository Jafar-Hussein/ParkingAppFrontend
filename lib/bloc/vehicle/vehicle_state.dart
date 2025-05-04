// vehicle_state.dart

import '../../model/VehicleModel.dart'; // Import your model here

abstract class VehicleState {
  final bool isLoading;
  final String errorMessage;
  final List<VehicleModel> vehicles;

  VehicleState({
    this.isLoading = false,
    this.errorMessage = '',
    this.vehicles = const [],
  });
}

class VehicleLoadingState extends VehicleState {
  VehicleLoadingState() : super(isLoading: true);
}

class VehicleLoadedState extends VehicleState {
  VehicleLoadedState(List<VehicleModel> vehicles)
    : super(isLoading: false, vehicles: vehicles);
}

class VehicleErrorState extends VehicleState {
  VehicleErrorState(String message)
    : super(isLoading: false, errorMessage: message);
}
