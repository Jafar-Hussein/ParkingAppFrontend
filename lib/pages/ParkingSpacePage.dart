import 'package:flutter/material.dart';
import '../navigation/Nav.dart';

class ParkingSpacePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) toggleTheme;

  const ParkingSpacePage({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _ParkingSpaceState createState() => _ParkingSpaceState();
}

class _ParkingSpaceState extends State<ParkingSpacePage> {
  final int rowsPerPage = 1; // Antalet rader per sida
  int currentPage = 0;
  List<Map<String, String>> data = [
    {"ID": "1", "Adress": "Gata 123", "Pris": "120.0 kr"},
    {"ID": "2", "Adress": "Gata 124", "Pris": "150.0 kr"},
    {"ID": "3", "Adress": "Gata 125", "Pris": "130.0 kr"},
    {"ID": "4", "Adress": "Gata 126", "Pris": "140.0 kr"},
    // Lägg till fler poster vid behov
  ];

  int get totalPages => (data.length / rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CustomNavigationRail(
            selectedIndex: 2,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),

          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: rowsPerPage,
                    itemBuilder: (context, index) {
                      int actualIndex = currentPage * rowsPerPage + index;
                      if (actualIndex < data.length) {
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text('ID: ${data[actualIndex]["ID"]}'),
                            subtitle: Text(
                              'Adress: ${data[actualIndex]["Adress"]}',
                            ),
                            trailing: Text('${data[actualIndex]["Pris"]}'),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
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
                      Text('Sida ${currentPage + 1} av $totalPages'),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
