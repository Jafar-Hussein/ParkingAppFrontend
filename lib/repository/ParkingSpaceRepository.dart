import 'package:http/http.dart' as http;
import 'dart:convert';

class Parkingspacerepository {
  final String apiBase = 'http://10.0.2.2:8081';

  /// Hämta alla parkeringsplatser
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(Uri.parse('$apiBase/parkingspaces'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Kunde inte hämta parkeringsplatser');
    }
  }

  /// Lägg till en parkeringsplats
  Future<void> add(Map<String, dynamic> parkingSpace) async {
    final response = await http.post(
      Uri.parse('$apiBase/parkingspaces'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parkingSpace),
    );

    if (response.statusCode != 200) {
      throw Exception('Kunde inte lägga till parkeringsplats');
    }
  }

  /// Radera en parkeringsplats
  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$apiBase/parkingspaces/$id'));

    if (response.statusCode != 200) {
      throw Exception('Kunde inte radera parkeringsplats');
    }
  }
}
