import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> register(
    String namn,
    String personnummer,
  ) async {
    final email = '${namn.trim()}@test.se';
    final password = personnummer.trim();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Spara användaren i Firestore
      await _firestore.collection("personer").doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'namn': namn,
        'personnummer': personnummer,
      });

      return {
        'uid': result.user!.uid,
        'namn': namn,
        'personnummer': personnummer,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception("Okänt fel vid registrering: $e");
    }
  }

  Future<Map<String, dynamic>> login(String namn, String personnummer) async {
    final email = '${namn.trim()}@test.se';
    final password = personnummer.trim();

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Hämta användardata från Firestore
      final doc =
          await _firestore.collection("personer").doc(result.user!.uid).get();
      final data = doc.data();

      return {
        'uid': result.user!.uid,
        'namn': data?['namn'],
        'personnummer': data?['personnummer'],
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception("Okänt fel vid inloggning: $e");
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Ogiltig e-postadress';
      case 'user-not-found':
        return 'Användare hittades inte';
      case 'wrong-password':
        return 'Fel lösenord';
      case 'email-already-in-use':
        return 'E-postadressen är redan registrerad';
      case 'weak-password':
        return 'Lösenordet är för svagt (minst 6 tecken krävs)';
      default:
        return 'Autentiseringsfel: ${e.message}';
    }
  }
}
