import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../navigation/Nav.dart';

class ParkingPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String ownerName;

  const ParkingPage({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.ownerName,
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

  int historyPage = 0;
  int spacesPage = 0;
  final int itemsPerPage = 3;

  bool sortByNewest = true;

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
      final vehicleRes = await http.get(
        Uri.parse('$apiBase/vehicles/owner/${widget.ownerName}'),
      );

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
      "vehicle": vehicle,
      "parkingSpace": {"id": spaceId},
      "startTime": now.toIso8601String(),
      "price": 0.0,
    };
    final res = await http.post(
      Uri.parse('$apiBase/parkings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200) loadData();
  }

  Future<void> stopParking(int parkingId, Map parking) async {
    final updated = {...parking, "endTime": DateTime.now().toIso8601String()};
    final res = await http.put(
      Uri.parse('$apiBase/parkings/$parkingId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated),
    );
    if (res.statusCode == 200) loadData();
  }

  List<dynamic> get pagedSpaces {
    final start = spacesPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, availableSpaces.length);
    return availableSpaces.sublist(start, end);
  }

  List<dynamic> get pagedHistory {
    final finished = parkingHistory.where((p) => p['endTime'] != null).toList();

    finished.sort(
      (a, b) =>
          sortByNewest
              ? b['startTime'].compareTo(a['startTime'])
              : a['startTime'].compareTo(b['startTime']),
    );

    final start = historyPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, finished.length);
    return finished.sublist(start, end);
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
            ownerName: widget.ownerName,
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
                            "📍 Lediga parkeringsplatser:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (vehicles.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                "Inga fordon registrerade.",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          else
                            ...pagedSpaces.map(
                              (space) => Card(
                                child: ListTile(
                                  title: Text(
                                    space['address'] ?? 'Okänd adress',
                                  ),
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
                                    onSelected: (selected) {
                                      startParking(space['id'], selected);
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
                                icon: Icon(Icons.arrow_back),
                              ),
                              Text("Sida ${spacesPage + 1}"),
                              IconButton(
                                onPressed:
                                    (spacesPage + 1) * itemsPerPage <
                                            availableSpaces.length
                                        ? () => setState(() => spacesPage++)
                                        : null,
                                icon: Icon(Icons.arrow_forward),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "📋 Parkeringshistorik:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DropdownButton<bool>(
                                value: sortByNewest,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      sortByNewest = value;
                                    });
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text("Nyast först"),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text("Äldst först"),
                                  ),
                                ],
                              ),
                            ],
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
                                icon: Icon(Icons.arrow_back),
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
                                icon: Icon(Icons.arrow_forward),
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
