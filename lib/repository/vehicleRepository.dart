import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/VehicleModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRepository {
  // Skapar en instans av Firebase Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Namnet på samlingen i Firestore
  final String collection = 'vehicle';

  // Hämtar alla fordon som tillhör en specifik användare (via ownerUid)
  Future<List<VehicleModel>> getVehicles(String ownerUid) async {
    try {
      // Hämtar dokument från 'vehicle'-samlingen där ownerUid matchar användaren
      final snapshot =
          await _firestore
              .collection(collection)
              .where('ownerUid', isEqualTo: ownerUid)
              .get(); // snapshot innehåller alla matchande dokument

      // Konverterar varje dokument i snapshot till en VehicleModel
      return snapshot.docs.map((doc) {
        final data = doc.data(); // Hämtar fält från varje dokument
        return VehicleModel(
          id: data['id'], // ID lagras manuellt i dokumentet
          registreringsnummer: data['registreringsnummer'],
          typ: data['typ'],
          owner: data['ownerName'], // Namnet på ägaren
        );
      }).toList();
    } catch (e) {
      print('Fel vid hämtning av fordon: $e');
      rethrow;
    }
  }

  // Lägger till ett nytt fordon i Firestore
  Future<void> addVehicle(Map<String, dynamic> vehicle) async {
    try {
      if (vehicle.isNotEmpty) {
        // Lägger till dokument i Firestore och får tillbaka en referens till det nya dokumentet
        final docRef = await _firestore.collection(collection).add(vehicle);

        // Uppdaterar dokumentet med sitt eget Firestore-ID (sparas som 'id')
        await _firestore.collection(collection).doc(docRef.id).update({
          'id': docRef.id,
        });
      } else {
        print('Fordon kunde inte skapas: Inga data angivna');
      }
    } catch (e) {
      print('Fel vid skapande av fordon: $e');
      rethrow;
    }
  }

  // Tar bort ett fordon baserat på dess Firestore ID
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore.collection(collection).doc(vehicleId).delete();
    } catch (e) {
      print('Fel vid borttagning av fordon: $e');
      rethrow;
    }
  }
}
