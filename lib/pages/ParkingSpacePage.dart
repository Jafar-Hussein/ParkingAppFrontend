import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/parkingplace/parking_space_bloc.dart';
import '../bloc/parkingplace/parking_space_event.dart';
import '../bloc/parkingplace/parking_space_state.dart';
import '../repository/ParkingSpaceRepository.dart';
import '../repository/NotificationRepository.dart';
import '../navigation/Nav.dart';

class ParkingSpacePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String ownerName;
  final String ownerUid;
  final NotificationRepository notificationRepository;

  const ParkingSpacePage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.ownerName,
    required this.ownerUid,
    required this.notificationRepository,
  });

  @override
  _ParkingSpacePageState createState() => _ParkingSpacePageState();
}

class _ParkingSpacePageState extends State<ParkingSpacePage> {
  int _currentParkingPage = 0;
  final int _rowsPerPage = 7;

  void _goToNextPage() => setState(() => _currentParkingPage++);
  void _goToPreviousPage() => setState(() => _currentParkingPage--);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: 2,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            ownerName: widget.ownerName,
            ownerUid: widget.ownerUid,
            notificationRepository: widget.notificationRepository,
          ),
          Expanded(
            child: BlocProvider(
              create:
                  (context) =>
                      ParkingPlaceBloc(Parkingspacerepository())
                        ..add(LoadParkingSpacesEvent()),
              child: BlocBuilder<ParkingPlaceBloc, ParkingSpaceState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage.isNotEmpty) {
                    return Center(child: Text(state.errorMessage));
                  }

                  final int totalPages =
                      (state.spaces.length / _rowsPerPage).ceil();
                  final start = _currentParkingPage * _rowsPerPage;
                  final end =
                      (start + _rowsPerPage > state.spaces.length)
                          ? state.spaces.length
                          : start + _rowsPerPage;

                  final currentPageData = state.spaces.sublist(start, end);

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentPageData.length,
                          itemBuilder: (context, index) {
                            final space = currentPageData[index];
                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                title: Text('ID: ${space["id"]}'),
                                subtitle: Text('Adress: ${space["address"]}'),
                                trailing: Text('${space["pricePerHour"]} kr'),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed:
                                  _currentParkingPage > 0
                                      ? _goToPreviousPage
                                      : null,
                            ),
                            Text(
                              'Sida ${_currentParkingPage + 1} av $totalPages',
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed:
                                  _currentParkingPage < totalPages - 1
                                      ? _goToNextPage
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
