abstract class ParkingSpaceState {
  final bool isLoading;
  final String errorMessage;
  final List<Map<String, dynamic>> spaces;

  ParkingSpaceState({
    this.isLoading = false,
    this.errorMessage = '',
    this.spaces = const [],
  });
}

class ParkingPlaceLoadingState extends ParkingSpaceState {
  ParkingPlaceLoadingState() : super(isLoading: true);
}

class ParkingPlaceLoadedState extends ParkingSpaceState {
  ParkingPlaceLoadedState(List<Map<String, dynamic>> spaces)
    : super(isLoading: false, spaces: spaces);
}

class ParkingPlaceErrorState extends ParkingSpaceState {
  ParkingPlaceErrorState(String errorMessage)
    : super(isLoading: false, errorMessage: errorMessage);
}
