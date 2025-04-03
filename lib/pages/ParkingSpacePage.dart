import 'package:flutter/material.dart';

class ParkingSpacePage extends StatefulWidget {
  @override
  _ParkingSpaceState createState() => _ParkingSpaceState();
}

class _ParkingSpaceState extends State<ParkingSpacePage> {
  final int rowsPerPage = 1; // Number of rows per page
  int currentPage = 0;
  List<Map<String, String>> data = [
    {"ID": "1", "Adress": "Gata 123", "Pris": "120.0 kr"},
    {"ID": "2", "Adress": "Gata 124", "Pris": "150.0 kr"},
    // Add more entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color appBarColor = theme.primaryColor;

    int totalPages = (data.length / rowsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text("Parking Space"),
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
                ), // Set the border color to black
                borderRadius: BorderRadius.circular(
                  10.0,
                ), // Optional: if you want rounded corners
              ),
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Adress',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Pris',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows:
                    List.generate(rowsPerPage, (index) {
                      final actualIndex = index + currentPage * rowsPerPage;
                      return actualIndex < data.length
                          ? DataRow(
                            cells: [
                              DataCell(Text(data[actualIndex]['ID'] ?? '')),
                              DataCell(Text(data[actualIndex]['Adress'] ?? '')),
                              DataCell(Text(data[actualIndex]['Pris'] ?? '')),
                            ],
                          )
                          : null;
                    }).whereType<DataRow>().toList(),
              ),
            ),
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
