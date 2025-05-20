import 'package:cloud_firestore/cloud_firestore.dart';


class Parkingspacerepository {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = 'parkingspace';

  Future<List<Map<String, dynamic>>> getAll() async {
    final snapshot = await _firestore.collection(collection).get();

    return snapshot.docs
        .map(
          (doc) =>
              {
                    ...doc.data(),
                    'firebaseId':
                        doc.id, // Valfritt: inkludera dokumentets Firestore-ID
                  },
        )
        .toList();
  }

  Future<void> add(Map<String, dynamic> parkingSpace) async {
    try {
      if (parkingSpace.isNotEmpty) {
        await _firestore.collection(collection).add(parkingSpace);
      } else {
        print('parkingSpace är tom');
      }
    } catch (e) {
      print('Fel vid add(): $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      print('Fel vid delete(): $e');
      rethrow;
    }
  }
}
