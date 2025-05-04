import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vehicle/vehicle_bloc.dart';
import '../bloc/vehicle/vehicle_state.dart';
import '../bloc/vehicle/vehicle_event.dart';
import '../navigation/Nav.dart';
import '../repository/vehicleRepository.dart';

class VehiclePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String ownerName;

  const VehiclePage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.ownerName,
  });

  @override
  _VehiclePageState createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  int _currentPage = 0;
  final int _rowsPerPage = 5;
  late VehicleBloc _vehicleBloc;

  @override
  void initState() {
    super.initState();
    _vehicleBloc = VehicleBloc(VehicleRepository());
    _vehicleBloc.add(LoadVehiclesEvent(widget.ownerName));
  }

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
    return BlocProvider(
      create: (context) {
        final bloc = VehicleBloc(VehicleRepository());
        // Vänta till efter första build innan vi triggar hämta fordon
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bloc.add(LoadVehiclesEvent(widget.ownerName));
        });
        return bloc;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _addVehicleDialog(context);
          },
          tooltip: "Lägg till fordon",
          child: Icon(Icons.add),
        ),
        body: Row(
          children: [
            CustomNavigationRail(
              selectedIndex: 1,
              toggleTheme: widget.toggleTheme,
              isDarkMode: widget.isDarkMode,
              ownerName: widget.ownerName,
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
                                  icon: Icon(Icons.delete, color: Colors.red),
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
      ),
    );
  }

  Future<void> _addVehicleDialog(BuildContext context) async {
    final TextEditingController regController = TextEditingController();
    final TextEditingController typController = TextEditingController();
    final FocusNode regFocus = FocusNode();

    await showDialog(
      context: context,
      builder: (_) {
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(regFocus);
        });

        return AlertDialog(
          title: Text('Lägg till fordon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: regController,
                focusNode: regFocus,
                decoration: InputDecoration(labelText: 'Registreringsnummer'),
              ),
              TextField(
                controller: typController,
                decoration: InputDecoration(labelText: 'Typ'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final newVehicle = {
                  "registreringsnummer": regController.text,
                  "typ": typController.text,
                  "owner": {"namn": widget.ownerName},
                };

                context.read<VehicleBloc>().add(AddVehicleEvent(newVehicle));
              },
              child: Text('Spara'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Avbryt'),
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
