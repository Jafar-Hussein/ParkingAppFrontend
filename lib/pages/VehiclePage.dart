import 'package:flutter/material.dart';
import '../navigation/Nav.dart';

class VehiclePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;

  const VehiclePage({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _VehiclePageState createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final int rowsPerPage = 2;
  int currentPage = 0;

  List<Map<String, dynamic>> vehicles = [
    {"Type": "Car", "ID": "12345", "Status": "Active"},
    {"Type": "Truck", "ID": "67890", "Status": "Inactive"},
    {"Type": "Bike", "ID": "10112", "Status": "Active"},
    {"Type": "Bus", "ID": "31385", "Status": "Inactive"},
  ];

  @override
  Widget build(BuildContext context) {
    int totalPages = (vehicles.length / rowsPerPage).ceil();
    int startIndex = currentPage * rowsPerPage;
    int endIndex =
        (currentPage + 1) * rowsPerPage > vehicles.length
            ? vehicles.length
            : (currentPage + 1) * rowsPerPage;

    List<Map<String, dynamic>> currentVehicles = vehicles.sublist(
      startIndex,
      endIndex,
    );

    return Scaffold(
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: 1,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              itemCount: currentVehicles.length + 1, // vehicles + pagination
              itemBuilder: (context, index) {
                if (index < currentVehicles.length) {
                  final vehicle = currentVehicles[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(vehicle["Type"]),
                      subtitle: Text("ID: ${vehicle["ID"]}"),
                      trailing: Text(vehicle["Status"]),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed:
                              currentPage > 0
                                  ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                  : null,
                        ),
                        Text('Page ${currentPage + 1} of $totalPages'),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed:
                              currentPage < totalPages - 1
                                  ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
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
    );
  }
}
