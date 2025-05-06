import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vehicle/vehicle_bloc.dart';
import '../bloc/vehicle/vehicle_state.dart';
import '../bloc/vehicle/vehicle_event.dart';
import '../navigation/Nav.dart';
import '../repository/vehicleRepository.dart';

class VehiclePage extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String ownerName;
  final int ownerId;

  const VehiclePage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.ownerName,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              VehicleBloc(VehicleRepository())
                ..add(LoadVehiclesEvent(ownerName)),
      child: Builder(
        builder:
            (context) => _VehiclePageContent(
              isDarkMode: isDarkMode,
              toggleTheme: toggleTheme,
              ownerName: ownerName,
              ownerId: ownerId,
            ),
      ),
    );
  }
}

class _VehiclePageContent extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String ownerName;
  final int ownerId;

  const _VehiclePageContent({
    required this.isDarkMode,
    required this.toggleTheme,
    required this.ownerName,
    required this.ownerId,
  });

  @override
  State<_VehiclePageContent> createState() => _VehiclePageContentState();
}

class _VehiclePageContentState extends State<_VehiclePageContent> {
  int _currentPage = 0;
  final int _rowsPerPage = 5;

  void _goToNextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _goToPreviousPage() {
    setState(() {
      _currentPage--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addVehicleDialog(context);
        },
        tooltip: "Lägg till fordon",
        child: const Icon(Icons.add),
      ),
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: 1,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            ownerName: widget.ownerName,
            ownerId: widget.ownerId,
          ),
          Expanded(
            child: BlocBuilder<VehicleBloc, VehicleState>(
              builder: (context, state) {
                if (state is VehicleLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is VehicleErrorState) {
                  return Center(child: Text(state.errorMessage));
                }

                final int totalPages =
                    (state.vehicles.length / _rowsPerPage).ceil();
                final startIndex = _currentPage * _rowsPerPage;
                final endIndex =
                    (startIndex + _rowsPerPage > state.vehicles.length)
                        ? state.vehicles.length
                        : startIndex + _rowsPerPage;

                final currentPageData = state.vehicles.sublist(
                  startIndex,
                  endIndex,
                );

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentPageData.length,
                        itemBuilder: (context, index) {
                          final vehicle = currentPageData[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 10.0,
                            ),
                            child: ListTile(
                              title: Text(vehicle.typ),
                              subtitle: Text(
                                "RegNr: ${vehicle.registreringsnummer}",
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _deleteVehicle(context, vehicle.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed:
                                _currentPage > 0 ? _goToPreviousPage : null,
                          ),
                          Text('Sida ${_currentPage + 1} av $totalPages'),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed:
                                _currentPage < totalPages - 1
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
        ],
      ),
    );
  }

  Future<void> _addVehicleDialog(BuildContext context) async {
    final TextEditingController regController = TextEditingController();
    final TextEditingController typController = TextEditingController();
    final FocusNode regFocus = FocusNode();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(dialogContext).requestFocus(regFocus);
        });

        return AlertDialog(
          title: const Text('Lägg till fordon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: regController,
                focusNode: regFocus,
                decoration: const InputDecoration(
                  labelText: 'Registreringsnummer',
                ),
              ),
              TextField(
                controller: typController,
                decoration: const InputDecoration(labelText: 'Typ'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (regController.text.isEmpty || typController.text.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Alla fält måste fyllas i')),
                  );
                  return;
                }

                final newVehicle = {
                  "registreringsnummer": regController.text,
                  "typ": typController.text,
                  "owner": {"id": widget.ownerId, "namn": widget.ownerName},
                };

                BlocProvider.of<VehicleBloc>(
                  context,
                ).add(AddVehicleEvent(newVehicle));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Spara'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Avbryt'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVehicle(BuildContext context, int vehicleId) async {
    context.read<VehicleBloc>().add(
      DeleteVehicleEvent(vehicleId, widget.ownerName),
    );
  }
}
