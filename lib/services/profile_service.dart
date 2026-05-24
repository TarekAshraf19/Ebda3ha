import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  ProfileService._();
  static final instance = ProfileService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> userRef() {
    return _db.collection('users').doc(_uid);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    return userRef().snapshots();
  }

  Future<void> updateFields({
    String? fullName,
    String? phone,
    String? address,
    String? payment,
  }) async {
    final data = <String, dynamic>{};

    if (fullName != null) data['fullName'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (payment != null) data['payment'] = payment;

    if (data.isNotEmpty) {
      await userRef().set(data, SetOptions(merge: true));
    }

    if (fullName != null && fullName.trim().isNotEmpty) {
      await _auth.currentUser?.updateDisplayName(fullName.trim());
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await user.updatePassword(newPassword);
  }

  Future<String> uploadProfileImage(File file) async {
    final ref = _storage.ref().child('users/$_uid/profile.jpg');

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    await userRef().set({
      'photoUrl': url,
    }, SetOptions(merge: true));

    return url;
  }
}