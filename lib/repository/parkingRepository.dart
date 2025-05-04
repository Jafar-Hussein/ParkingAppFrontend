import 'package:http/http.dart' as http;
import 'dart:convert';

class ParkingRepository {
  final String apiBase = 'http://10.0.2.2:8081';

  Future<List<dynamic>> getParkingHistory() async {
    final res = await http.get(Uri.parse('$apiBase/parkings'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Misslyckades att hämta parkeringar');
    }
  }

  Future<List<dynamic>> getAvailableSpaces() async {
    final res = await http.get(Uri.parse('$apiBase/parkingspaces'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Misslyckades att hämta parkeringsplatser');
    }
  }

  Future<List<dynamic>> getVehicles(String ownerName) async {
    final res = await http.get(Uri.parse('$apiBase/vehicles/owner/$ownerName'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Misslyckades att hämta fordon');
    }
  }

  Future<void> startParking(int spaceId, Map vehicle, String ownerName) async {
    final payload = {
      "vehicle": vehicle,
      "parkingSpace": {"id": spaceId},
      "startTime": DateTime.now().toIso8601String(),
      "price": 0.0,
    };

    final res = await http.post(
      Uri.parse('$apiBase/parkings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('Misslyckades att starta parkering');
    }
  }

  Future<void> stopParking(int parkingId, Map parking, String ownerName) async {
    final updated = {...parking, "endTime": DateTime.now().toIso8601String()};

    final res = await http.put(
      Uri.parse('$apiBase/parkings/$parkingId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated),
    );

    if (res.statusCode != 200) {
      throw Exception('Misslyckades att avsluta parkering');
    }
  }
}
