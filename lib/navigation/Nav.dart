import 'package:flutter/material.dart';
import '../pages/ParkingPage.dart';
import '../pages/ParkingSpacePage.dart';
import '../pages/VehiclePage.dart';
import '../main.dart'; // Ensure the path is correct

class CustomNavigationRail extends StatefulWidget {
  final int selectedIndex;
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const CustomNavigationRail({
    Key? key,
    required this.selectedIndex,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _CustomNavigationRailState createState() => _CustomNavigationRailState();
}

class _CustomNavigationRailState extends State<CustomNavigationRail> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ParkingPage(
                  isDarkMode: widget.isDarkMode,
                  toggleTheme: widget.toggleTheme,
                ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => VehiclePage(
                  isDarkMode: widget.isDarkMode,
                  toggleTheme: widget.toggleTheme,
                ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ParkingSpacePage(
                  isDarkMode: widget.isDarkMode,
                  toggleTheme: widget.toggleTheme,
                ),
          ),
        );
        break;
      case 3:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color navigationRailColor =
        theme.brightness == Brightness.light
            ? const Color(0xFF5E35B1)
            : Colors.blueGrey[800]!;

    return NavigationRail(
      backgroundColor: navigationRailColor,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemSelected,
      labelType: NavigationRailLabelType.selected,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      selectedLabelTextStyle: const TextStyle(color: Colors.white),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.local_parking),
          selectedIcon: Icon(Icons.local_parking),
          label: Text('Parking'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.directions_car),
          selectedIcon: Icon(Icons.directions_car_filled),
          label: Text('Vehicles'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.place),
          selectedIcon: Icon(Icons.place),
          label: Text('Parking Spaces'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
      ],
    );
  }
}
