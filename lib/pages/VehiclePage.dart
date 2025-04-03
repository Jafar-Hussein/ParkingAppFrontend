import 'package:flutter/material.dart';

class VehiclePage extends StatefulWidget {
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

    List<DataRow> currentRows =
        vehicles
            .sublist(
              currentPage * rowsPerPage,
              (currentPage + 1) * rowsPerPage > vehicles.length
                  ? vehicles.length
                  : (currentPage + 1) * rowsPerPage,
            )
            .map(
              (vehicle) => DataRow(
                cells: [
                  DataCell(Text(vehicle["Type"])),
                  DataCell(Text(vehicle["ID"])),
                  DataCell(Text(vehicle["Status"])),
                ],
              ),
            )
            .toList();

    final ThemeData theme = Theme.of(context);
    final Color appBarColor =
        theme.primaryColor; // Adjust this to your theme color

    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicles"),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ), // Set border color here
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: currentRows,
              ),
            ),
            SizedBox(height: 20.0), // Space between table and pagination
            Row(
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
          ],
        ),
      ),
    );
  }
}
