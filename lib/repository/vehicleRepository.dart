// vehicle_repository.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/VehicleModel.dart';

// Här definierar vi en modell för Vehicle. Det kan behövas för att skapa en VehicleModel eller liknande.
// Det är här du kan använda din egen VehicleModel om den finns.
class VehicleRepository {
  final String apiBase = 'http://10.0.2.2:8081'; // Adjust API base as needed

  // Fetch vehicles for a specific owner
  Future<List<VehicleModel>> getVehicles(String ownerName) async {
    final response = await http.get(
      Uri.parse('$apiBase/vehicles/owner/$ownerName'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((vehicle) => VehicleModel.fromJson(vehicle))
          .toList();
    } else {
      throw Exception('Failed to fetch vehicles');
    }
  }

  // Add a vehicle
  Future<void> addVehicle(Map<String, dynamic> vehicle) async {
    print("Skickar fordon till backend: $vehicle"); // 🧪 Lägg till denna

    final response = await http.post(
      Uri.parse('$apiBase/vehicles'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vehicle),
    );

    print("Svarskod: ${response.statusCode}"); // 🧪

    if (response.statusCode != 200) {
      throw Exception('Failed to add vehicle');
    }
  }

  // Delete a vehicle
  Future<void> deleteVehicle(int vehicleId) async {
    final response = await http.delete(
      Uri.parse('$apiBase/vehicles/$vehicleId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete vehicle');
    }
  }
}
