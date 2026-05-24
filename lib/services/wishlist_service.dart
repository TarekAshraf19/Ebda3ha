import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class WishlistService {
  WishlistService._();
  static final instance = WishlistService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception("User not logged in");
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> get _wishlistRef =>
      _db.collection('users').doc(_uid).collection('wishlist');

  Stream<QuerySnapshot<Map<String, dynamic>>> wishlistStream() {
    return _wishlistRef.orderBy('addedAt', descending: true).snapshots();
  }

  Future<bool> isInWishlist(String productId) async {
    final doc = await _wishlistRef.doc(productId).get();
    return doc.exists;
  }

  Stream<bool> isInWishlistStream(String productId) {
    return _wishlistRef.doc(productId).snapshots().map((d) => d.exists);
  }

  Future<void> add(Product p) async {
    await _wishlistRef.doc(p.id).set({
      'productId': p.id,
      'name': p.name,
      'image': p.image,
      'price': p.price,
      'category': p.category,
      'description': p.description,
      'rating': p.rating,
      'reviewsCount': p.reviewsCount,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> remove(String productId) async {
    await _wishlistRef.doc(productId).delete();
  }

  Future<void> toggle(Product p) async {
    final doc = await _wishlistRef.doc(p.id).get();
    if (doc.exists) {
      await remove(p.id);
    } else {
      await add(p);
    }
  }
}