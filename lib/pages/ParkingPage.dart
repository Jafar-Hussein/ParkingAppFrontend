import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/parking/parking_bloc.dart';
import '../bloc/parking/parking_event.dart';
import '../bloc/parking/parking_state.dart';
import '../navigation/Nav.dart';
import '../repository/parkingRepository.dart';

class ParkingPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String ownerName;

  const ParkingPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.ownerName,
  });

  @override
  _ParkingPageState createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  int _currentParkingPage = 0;
  int _currentHistoryPage = 0;
  final int _rowsPerPage = 5;

  void _goToNextParkingPage() => setState(() => _currentParkingPage++);
  void _goToPreviousParkingPage() => setState(() => _currentParkingPage--);
  void _goToNextHistoryPage() => setState(() => _currentHistoryPage++);
  void _goToPreviousHistoryPage() => setState(() => _currentHistoryPage--);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParkingBloc>(
      create: (context) {
        final bloc = ParkingBloc(ParkingRepository()); // ✅ Skicka in dependency
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bloc.add(LoadParkingDataEvent(widget.ownerName));
        });
        return bloc;
      },
      child: Scaffold(
        body: Row(
          children: [
            CustomNavigationRail(
              selectedIndex: 0,
              toggleTheme: widget.toggleTheme,
              isDarkMode: widget.isDarkMode,
              ownerName: widget.ownerName,
            ),
            Expanded(
              child: BlocBuilder<ParkingBloc, ParkingState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage.isNotEmpty) {
                    return Center(child: Text(state.errorMessage));
                  }

                  final int totalParkingPages =
                      (state.availableSpaces.length / _rowsPerPage).ceil();
                  final int totalHistoryPages =
                      (state.parkingHistory.length / _rowsPerPage).ceil();

                  final currentParkingPageData =
                      state.availableSpaces
                          .skip(_currentParkingPage * _rowsPerPage)
                          .take(_rowsPerPage)
                          .toList();

                  final currentHistoryPageData =
                      state.parkingHistory
                          .skip(_currentHistoryPage * _rowsPerPage)
                          .take(_rowsPerPage)
                          .toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📍 Lediga parkeringsplatser:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...currentParkingPageData.map(
                          (space) => Card(
                            child: ListTile(
                              title: Text(space['address'] ?? 'Okänd adress'),
                              subtitle: Text(
                                "Pris per timme: ${space['pricePerHour']} kr",
                              ),
                              trailing: PopupMenuButton<Map>(
                                icon: const Icon(Icons.directions_car),
                                itemBuilder:
                                    (_) =>
                                        state.vehicles
                                            .map(
                                              (v) => PopupMenuItem<Map>(
                                                value: v,
                                                child: Text(
                                                  v['registreringsnummer'],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                onSelected: (selected) {
                                  context.read<ParkingBloc>().add(
                                    StartParkingEvent(
                                      space['id'],
                                      selected,
                                      widget.ownerName,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed:
                                  _currentParkingPage > 0
                                      ? _goToPreviousParkingPage
                                      : null,
                            ),
                            Text(
                              'Sida ${_currentParkingPage + 1} av $totalParkingPages',
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed:
                                  _currentParkingPage < totalParkingPages - 1
                                      ? _goToNextParkingPage
                                      : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "🕒 Pågående parkeringar:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...state.parkingHistory
                            .where((entry) => entry['endTime'] == null)
                            .map(
                              (entry) => Card(
                                child: ListTile(
                                  title: Text(
                                    "${entry['vehicle']['registreringsnummer']} - ${entry['parkingSpace']['address']}",
                                  ),
                                  subtitle: Text(
                                    "Start: ${entry['startTime']}",
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      context.read<ParkingBloc>().add(
                                        StopParkingEvent(
                                          entry['id'],
                                          entry,
                                          widget.ownerName,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Avsluta"),
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 20),
                        const Text(
                          "📋 Parkeringshistorik:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...currentHistoryPageData.map(
                          (history) => Card(
                            child: ListTile(
                              title: Text(
                                "Fordon: ${history['vehicle']['registreringsnummer']}",
                              ),
                              subtitle: Text(
                                "Start: ${history['startTime']}\nSlut: ${history['endTime'] ?? 'Pågående'}",
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed:
                                  _currentHistoryPage > 0
                                      ? _goToPreviousHistoryPage
                                      : null,
                            ),
                            Text(
                              'Sida ${_currentHistoryPage + 1} av $totalHistoryPages',
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed:
                                  _currentHistoryPage < totalHistoryPages - 1
                                      ? _goToNextHistoryPage
                                      : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
