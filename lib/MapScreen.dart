import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Ensure you're using latlong2

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(59.3293, 18.0686), // Coordinates of Stockholm
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?", //lägg api nyckel här
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(59.3293, 18.0686),
                width: 80,
                height: 80,
                child: Builder(
                  builder:
                      (ctx) => Container(
                        child: Icon(
                          Icons.location_on,
                          size: 40.0,
                          color: Colors.red,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
