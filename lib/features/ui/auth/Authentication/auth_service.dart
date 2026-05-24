import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user
  Future<String?> registerUser({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      await userCred.user!.updateDisplayName(fullName);

      await _firestore.collection("users").doc(uid).set({
        "fullName": fullName,
        "phone": phone,
        "email": email,

        // profile extra fields (جاهزة للـ Profile page)
        "photoUrl": "",
        "address": "",
        "payment": "",

        "createdAt": FieldValue.serverTimestamp(),
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Login user
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _ensureUserDoc(cred.user!);

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _ensureUserDoc(User user) async {
    final ref = _firestore.collection("users").doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        "fullName": user.displayName ?? "",
        "phone": "",
        "email": user.email ?? "",
        "photoUrl": "",
        "address": "",
        "payment": "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  // Reset password
  Future<String?> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset email sent";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}