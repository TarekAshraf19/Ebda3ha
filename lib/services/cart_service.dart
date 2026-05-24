import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class CartService {
  CartService._();
  static final CartService instance = CartService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('User not logged in');
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> _itemsRef() {
    return _db.collection('carts').doc(_uid).collection('items');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream() {
    return _itemsRef().snapshots();
  }

  String _buildCartItemId({
    required String productId,
    String? size,
    String? color,
  }) {
    final safeSize = (size ?? '').trim().toLowerCase();
    final safeColor = (color ?? '').trim().toLowerCase();
    return '${productId}_${safeSize}_${safeColor}';
  }

  Future<void> addToCart(
      Product product, {
        int qty = 1,
        String? size,
        String? color,
      }) async {
    final selectedSize = size ?? '';
    final selectedColor = color ?? '';

    final cartItemId = _buildCartItemId(
      productId: product.id,
      size: selectedSize,
      color: selectedColor,
    );

    final docRef = _itemsRef().doc(cartItemId);

    print('================ CART DEBUG ================');
    print('uid: $_uid');
    print('product id: ${product.id}');
    print('product name: ${product.name}');
    print('cart item id: $cartItemId');
    print('path: carts/$_uid/items/$cartItemId');

    final snap = await docRef.get();

    if (snap.exists) {
      final oldQty = ((snap.data()?['quantity'] ?? 0) as num).toInt();

      await docRef.set({
        'cartItemId': cartItemId,
        'productId': product.id,
        'name': product.name,
        'image': product.image,
        'price': product.price,
        'quantity': oldQty + qty,
        'size': selectedSize,
        'color': selectedColor,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('cart item updated successfully');
    } else {
      await docRef.set({
        'cartItemId': cartItemId,
        'productId': product.id,
        'name': product.name,
        'image': product.image,
        'price': product.price,
        'quantity': qty,
        'size': selectedSize,
        'color': selectedColor,
        'addedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('cart item added successfully');
    }

    final verify = await docRef.get();
    print('exists after write: ${verify.exists}');
    print('data after write: ${verify.data()}');
    print('===========================================');
  }

  Future<void> setQuantity(String cartItemId, int qty) async {
    final docRef = _itemsRef().doc(cartItemId);

    if (qty <= 0) {
      await docRef.delete();
    } else {
      await docRef.update({
        'quantity': qty,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeItem(String cartItemId) async {
    await _itemsRef().doc(cartItemId).delete();
  }

  Future<void> clearCart() async {
    final snap = await _itemsRef().get();
    for (final d in snap.docs) {
      await d.reference.delete();
    }
  }
}