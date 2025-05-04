class ParkingState {
  final bool isLoading;
  final List<Map<String, dynamic>> parkingHistory;
  final List<Map<String, dynamic>> availableSpaces;
  final List<Map<String, dynamic>> vehicles;
  final String errorMessage;

  ParkingState({
    this.isLoading = true,
    this.parkingHistory = const [],
    this.availableSpaces = const [],
    this.vehicles = const [],
    this.errorMessage = '',
  });

  ParkingState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? parkingHistory,
    List<Map<String, dynamic>>? availableSpaces,
    List<Map<String, dynamic>>? vehicles,
    String? errorMessage,
  }) {
    return ParkingState(
      isLoading: isLoading ?? this.isLoading,
      parkingHistory: parkingHistory ?? this.parkingHistory,
      availableSpaces: availableSpaces ?? this.availableSpaces,
      vehicles: vehicles ?? this.vehicles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
