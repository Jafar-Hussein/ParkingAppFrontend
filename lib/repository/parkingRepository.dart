import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'parking';
  Future<List<Map<String, dynamic>>> getParkingHistory(String uid) async {
    final snapshot =
        await _firestore
            .collection(collection)
            .where('ownerUid', isEqualTo: uid)
            .orderBy('startTime', descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getAvailableSpaces() async { // test kommentar
    final snapshot = await _firestore.collection('parkingspace').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getVehicles(String uid) async {
    final snapshot =
        await _firestore
            .collection('vehicle')
            .where('ownerUid', isEqualTo: uid)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> startParking(
    String spaceId,
    Map vehicle,
    String ownerUid,
  ) async {
    final parkingDoc = await _firestore.collection(collection).add({
      "vehicle": vehicle,
      "parkingSpaceId": spaceId,
      "startTime": DateTime.now().toIso8601String(),
      "price": 0.0,
      "ownerUid": ownerUid,
    });
  }

  Future<void> stopParking(String parkingId, Map parking) async {
    final updated = {...parking, "endTime": DateTime.now().toIso8601String()};

    await _firestore
        .collection(collection)
        .doc(parkingId)
        .update(updated.cast<String, Object?>());
  }
}
