import 'package:flutter/material.dart';
import 'package:flutter_application/bloc/vehicle/vehicle_event.dart';
import '../pages/ParkingPage.dart';
import '../pages/ParkingSpacePage.dart';
import '../pages/VehiclePage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vehicle/vehicle_bloc.dart';
import '../repository/vehicleRepository.dart';
import '../repository/NotificationRepository.dart'; // ✅ Lägg till import

class CustomNavigationRail extends StatefulWidget {
  final int selectedIndex;
  final Function(bool) toggleTheme;
  final bool isDarkMode;
  final String ownerName;
  final String ownerUid;
  final NotificationRepository notificationRepository; // ✅ Ny parameter

  const CustomNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.ownerName,
    required this.ownerUid,
    required this.notificationRepository, // ✅ Lägg till här också
  });

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
                  ownerName: widget.ownerName,
                  ownerUid: widget.ownerUid,
                  notificationRepository:
                      widget.notificationRepository, // ✅ här
                ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => BlocProvider(
                  create:
                      (_) =>
                          VehicleBloc(VehicleRepository())
                            ..add(LoadVehiclesEvent(widget.ownerUid)),
                  child: VehiclePage(
                    isDarkMode: widget.isDarkMode,
                    toggleTheme: widget.toggleTheme,
                    ownerName: widget.ownerName,
                    ownerUid: widget.ownerUid,
                    notificationRepository: widget.notificationRepository,
                  ),
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
                  ownerName: widget.ownerName,
                  ownerUid: widget.ownerUid,
                  notificationRepository: widget.notificationRepository,
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
