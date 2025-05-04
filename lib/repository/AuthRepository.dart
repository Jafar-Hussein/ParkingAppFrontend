import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRepository {
  final String baseUrl = 'http://10.0.2.2:8081';

  Future<Map<String, dynamic>> login(String namn, String personnummer) async {
    final response = await http.get(Uri.parse('$baseUrl/persons/namn/$namn'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['personnummer'] == personnummer) {
        return data;
      } else {
        throw Exception("Fel personnummer");
      }
    } else {
      throw Exception("Användare hittades inte");
    }
  }

  Future<Map<String, dynamic>> register(
    String namn,
    String personnummer,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/persons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'namn': namn, 'personnummer': personnummer}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Registrering misslyckades");
    }
  }
}
