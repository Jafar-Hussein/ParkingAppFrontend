import 'package:flutter/material.dart';
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
  // Example data for parking spaces and vehicles
  List<Map<String, dynamic>> parkingData = [
    {
      "space": "001",
      "vehicle": "Car",
      "license": "XYZ 1234",
      "status": "Occupied",
    },
    {
      "space": "002",
      "vehicle": "Motorcycle",
      "license": "ABC 9876",
      "status": "Occupied",
    },
    {"space": "003", "vehicle": "None", "license": "None", "status": "Empty"},
    // Add more entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color appBarColor = theme.primaryColor;

    return Scaffold(
      body: Row(
        children: [
          // This assumes your Nav.dart defines a widget named CustomNavigationRail
          CustomNavigationRail(
            selectedIndex: 0,
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),

          // Select index according to your page
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              itemCount: parkingData.length,
              itemBuilder: (context, index) {
                var parking = parkingData[index];
                return Card(
                  child: ListTile(
                    title: Text('Space: ${parking["space"]}'),
                    subtitle: Text(
                      'Vehicle: ${parking["vehicle"]} - License: ${parking["license"]}',
                    ),
                    trailing: Text(parking["status"]),
                    leading: Icon(
                      parking["status"] == "Occupied"
                          ? Icons.directions_car
                          : Icons.local_parking,
                    ),
                    onTap: () {
                      // You can add actions upon tapping the parking space
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
