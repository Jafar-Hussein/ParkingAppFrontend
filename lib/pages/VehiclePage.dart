import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../navigation/Nav.dart';
import '../model/VehicleModel.dart';

class VehiclePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String ownerName;

  const VehiclePage({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.ownerName,
  }) : super(key: key);

  @override
  _VehiclePageState createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final int rowsPerPage = 5;
  int currentPage = 0;
  bool isLoading = true;

  List<VehicleModel> allVehicles = [];

  String get apiUrl =>
      'http://10.0.2.2:8081/vehicles/owner/${widget.ownerName}';

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allVehicles =
              data.map((item) => VehicleModel.fromJson(item)).toList();
        });
      } else {
        print('Fel vid hämtning av fordon: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addVehicleDialog() async {
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
                await http.post(
                  Uri.parse('http://10.0.2.2:8081/vehicles'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(newVehicle),
                );
                fetchVehicles();
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

  Future<void> editVehicleDialog(VehicleModel vehicle) async {
    final TextEditingController regController = TextEditingController(
      text: vehicle.registreringsnummer,
    );
    final TextEditingController typController = TextEditingController(
      text: vehicle.typ,
    );

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Redigera fordon'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: regController,
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
                  final updatedVehicle = {
                    "id": vehicle.id,
                    "registreringsnummer": regController.text,
                    "typ": typController.text,
                    "owner": {"namn": widget.ownerName},
                  };
                  await http.put(
                    Uri.parse('http://10.0.2.2:8081/vehicles/${vehicle.id}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(updatedVehicle),
                  );
                  fetchVehicles();
                },
                child: Text('Spara'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Avbryt'),
              ),
            ],
          ),
    );
  }

  Future<void> deleteVehicle(int id) async {
    await http.delete(Uri.parse('http://10.0.2.2:8081/vehicles/$id'));
    fetchVehicles();
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (allVehicles.length / rowsPerPage).ceil();
    int startIndex = currentPage * rowsPerPage;
    int endIndex =
        (currentPage + 1) * rowsPerPage > allVehicles.length
            ? allVehicles.length
            : (currentPage + 1) * rowsPerPage;
    List<VehicleModel> currentVehicles = allVehicles.sublist(
      startIndex,
      endIndex,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addVehicleDialog,
        child: Icon(Icons.add),
        tooltip: "Lägg till fordon",
      ),
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: 1,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentVehicles.length + 1,
                            itemBuilder: (context, index) {
                              if (index < currentVehicles.length) {
                                final vehicle = currentVehicles[index];
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
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed:
                                              () => editVehicleDialog(vehicle),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => deleteVehicle(vehicle.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_back),
                                        onPressed:
                                            currentPage > 0
                                                ? () => setState(
                                                  () => currentPage--,
                                                )
                                                : null,
                                      ),
                                      Text(
                                        'Sida ${currentPage + 1} av $totalPages',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward),
                                        onPressed:
                                            currentPage < totalPages - 1
                                                ? () => setState(
                                                  () => currentPage++,
                                                )
                                                : null,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
