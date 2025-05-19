import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String registreringsnummer;
  final String typ;
  final String owner;

  VehicleModel({
    required this.id,
    required this.registreringsnummer,
    required this.typ,
    required this.owner,
  });

  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return VehicleModel(
      id: data['id'] ?? doc.id,
      registreringsnummer: data['registreringsnummer'] ?? '',
      typ: data['typ'] ?? '',
      owner: data['ownerName'] ?? '',
    );
  }
}
