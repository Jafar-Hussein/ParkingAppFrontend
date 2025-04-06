import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../navigation/Nav.dart';

class ParkingPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;

  const ParkingPage({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _ParkingPageState createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  bool isLoading = true;
  List<dynamic> parkingHistory = [];
  List<dynamic> availableSpaces = [];
  List<dynamic> vehicles = [];

  final String apiBase = 'http://10.0.2.2:8081';

  // Pagination
  int historyPage = 0;
  int spacesPage = 0;
  final int itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final historyRes = await http.get(Uri.parse('$apiBase/parkings'));
      final parkingSpaceRes = await http.get(
        Uri.parse('$apiBase/parkingspaces'),
      );
      final vehicleRes = await http.get(Uri.parse('$apiBase/vehicles'));

      if (historyRes.statusCode == 200 &&
          parkingSpaceRes.statusCode == 200 &&
          vehicleRes.statusCode == 200) {
        setState(() {
          parkingHistory = jsonDecode(historyRes.body);
          availableSpaces = jsonDecode(parkingSpaceRes.body);
          vehicles = jsonDecode(vehicleRes.body);
          isLoading = false;
        });
      } else {
        print("Kunde inte hämta data från backend.");
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> startParking(int spaceId, Map vehicle) async {
    final now = DateTime.now();

    final payload = {
      "vehicle": {
        "id": vehicle['id'],
        "registreringsnummer": vehicle['registreringsnummer'],
        "typ": vehicle['typ'],
        "owner": {
          "id": vehicle['owner']['id'],
          "namn": vehicle['owner']['namn'],
          "personnummer": vehicle['owner']['personnummer'],
        },
      },
      "parkingSpace": {"id": spaceId},
      "startTime": now.toIso8601String(),
      "price": 0.0,
    };

    final res = await http.post(
      Uri.parse('$apiBase/parkings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200) {
      loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kunde inte starta parkering")),
      );
    }
  }

  Future<void> stopParking(int parkingId, Map parking) async {
    final updatedParking = {
      "id": parking['id'],
      "vehicle": parking['vehicle'],
      "parkingSpace": parking['parkingSpace'],
      "startTime": parking['startTime'],
      "endTime": DateTime.now().toIso8601String(),
    };

    final res = await http.put(
      Uri.parse('$apiBase/parkings/$parkingId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedParking),
    );

    if (res.statusCode == 200) {
      loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kunde inte avsluta parkering")),
      );
    }
  }

  List<dynamic> get pagedHistory {
    final ongoing = parkingHistory.where((p) => p['endTime'] == null).toList();
    final finished =
        parkingHistory.where((p) => p['endTime'] != null).toList()
          ..sort((a, b) => b['startTime'].compareTo(a['startTime']));

    final int start = historyPage * itemsPerPage;
    final int end = (start + itemsPerPage).clamp(0, finished.length);
    final paginatedFinished = finished.sublist(start, end);

    return [...ongoing, ...paginatedFinished];
  }

  List<dynamic> get pagedSpaces {
    final int start = spacesPage * itemsPerPage;
    final int end = (start + itemsPerPage).clamp(0, availableSpaces.length);
    return availableSpaces.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: 0,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "\u{1F4CD} Lediga parkeringsplatser:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...pagedSpaces.map(
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
                                          vehicles
                                              .map(
                                                (v) => PopupMenuItem<Map>(
                                                  value: v,
                                                  child: Text(
                                                    v['registreringsnummer'],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                  onSelected: (selectedVehicle) {
                                    startParking(space['id'], selectedVehicle);
                                  },
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed:
                                    spacesPage > 0
                                        ? () => setState(() => spacesPage--)
                                        : null,
                                icon: const Icon(Icons.arrow_back),
                              ),
                              Text("Sida ${spacesPage + 1}"),
                              IconButton(
                                onPressed:
                                    (spacesPage + 1) * itemsPerPage <
                                            availableSpaces.length
                                        ? () => setState(() => spacesPage++)
                                        : null,
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "\u{1F4CB} Parkeringshistorik:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...pagedHistory.map(
                            (entry) => Card(
                              child: ListTile(
                                title: Text(
                                  "${entry['vehicle']['registreringsnummer']} - ${entry['parkingSpace']['address']}",
                                ),
                                subtitle: Text(
                                  "Start: ${entry['startTime']}\nPris: ${entry['price']} kr",
                                ),
                                trailing:
                                    entry['endTime'] == null
                                        ? ElevatedButton(
                                          onPressed:
                                              () => stopParking(
                                                entry['id'],
                                                entry,
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text("Avsluta"),
                                        )
                                        : const Text("Avslutad"),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed:
                                    historyPage > 0
                                        ? () => setState(() => historyPage--)
                                        : null,
                                icon: const Icon(Icons.arrow_back),
                              ),
                              Text("Sida ${historyPage + 1}"),
                              IconButton(
                                onPressed:
                                    (historyPage + 1) * itemsPerPage <
                                            parkingHistory
                                                .where(
                                                  (p) => p['endTime'] != null,
                                                )
                                                .length
                                        ? () => setState(() => historyPage++)
                                        : null,
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
