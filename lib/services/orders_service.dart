import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class OrdersService {
  OrdersService._();
  static final instance = OrdersService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> userOrdersRef() {
    return _db.collection('users').doc(_uid).collection('orders');
  }

  Stream<List<OrderModel>> ordersStreamByStatus(String status) {
    return userOrdersRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final allOrders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      return allOrders.where((order) => order.status == status).toList();
    });
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await userOrdersRef().doc(orderId).get();
    if (!doc.exists || doc.data() == null) return null;
    return OrderModel.fromMap(doc.data()!, doc.id);
  }
}