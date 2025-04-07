import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../navigation/Nav.dart';

class ParkingSpacePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;
  final String ownerName;

  const ParkingSpacePage({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.ownerName,
  }) : super(key: key);

  @override
  _ParkingSpaceState createState() => _ParkingSpaceState();
}

class _ParkingSpaceState extends State<ParkingSpacePage> {
  final int rowsPerPage = 7;
  int currentPage = 0;
  List<dynamic> parkingSpaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParkingSpaces();
  }

  Future<void> fetchParkingSpaces() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8081/parkingspaces'),
      );
      if (response.statusCode == 200) {
        setState(() {
          parkingSpaces = json.decode(response.body);
        });
      } else {
        print('Fel vid hämtning av parkeringsplatser: ${response.statusCode}');
      }
    } catch (e) {
      print('Fel: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  int get totalPages => (parkingSpaces.length / rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final int start = currentPage * rowsPerPage;
    final int end =
        (start + rowsPerPage > parkingSpaces.length)
            ? parkingSpaces.length
            : start + rowsPerPage;
    final List<dynamic> currentData = parkingSpaces.sublist(start, end);

    return Scaffold(
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: 2,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
            ownerName: widget.ownerName,
          ),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentData.length,
                            itemBuilder: (context, index) {
                              final space = currentData[index];
                              return Card(
                                margin: EdgeInsets.all(10),
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
                                icon: Icon(Icons.arrow_back),
                                onPressed:
                                    currentPage > 0
                                        ? () => setState(() => currentPage--)
                                        : null,
                              ),
                              Text('Sida ${currentPage + 1} av $totalPages'),
                              IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed:
                                    currentPage < totalPages - 1
                                        ? () => setState(() => currentPage++)
                                        : null,
                              ),
                            ],
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
