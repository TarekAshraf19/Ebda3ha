import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class ReviewsService {
  ReviewsService._();
  static final instance = ReviewsService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  Future<void> submitReview({
    required OrderModel order,
    required int rating,
    required String comment,
  }) async {
    if (order.items.isEmpty) {
      throw Exception('No products found in this order');
    }

    final batch = _db.batch();

    for (final item in order.items) {
      if (item.isRated) continue;

      final reviewRef = _db
          .collection('products')
          .doc(item.productId)
          .collection('reviews')
          .doc(_uid);

      batch.set(reviewRef, {
        'userId': _uid,
        'orderId': order.orderId,
        'productId': item.productId,
        'productTitle': item.title,
        'rating': rating,
        'comment': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      final globalOrderRef = _db.collection('orders').doc(order.orderId);
      final userOrderRef = _db
          .collection('users')
          .doc(_uid)
          .collection('orders')
          .doc(order.orderId);

      final updatedGlobalItems = order.items.map((e) {
        return {
          'cartItemId': e.cartItemId,
          'productId': e.productId,
          'title': e.title,
          'imageUrl': e.imageUrl,
          'price': e.price,
          'quantity': e.quantity,
          'size': e.size,
          'color': e.color,
          'total': e.total,
          'isRated': true,
        };
      }).toList();

      batch.update(globalOrderRef, {
        'items': updatedGlobalItems,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(userOrderRef, {
        'items': updatedGlobalItems,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}