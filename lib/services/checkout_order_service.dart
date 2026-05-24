import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutOrderService {
  CheckoutOrderService._();
  static final instance = CheckoutOrderService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _userRef() {
    return _db.collection('users').doc(_uid);
  }

  CollectionReference<Map<String, dynamic>> _ordersRef() {
    return _db.collection('orders');
  }

  CollectionReference<Map<String, dynamic>> _userOrdersRef() {
    return _db.collection('users').doc(_uid).collection('orders');
  }

  Future<void> saveShippingAddress({
    required String firstName,
    required String lastName,
    required String country,
    required String streetName,
    required String city,
    required String phoneNumber,
    required String shippingMethod,
    required double shippingPrice,
  }) async {
    await _userRef().set({
      'checkoutShipping': {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'country': country.trim(),
        'streetName': streetName.trim(),
        'city': city.trim(),
        'phoneNumber': phoneNumber.trim(),
        'shippingMethod': shippingMethod,
        'shippingPrice': shippingPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getSavedShippingAddress() async {
    final doc = await _userRef().get();
    final data = doc.data();
    if (data == null) return null;
    return data['checkoutShipping'] as Map<String, dynamic>?;
  }

  Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    Map<String, dynamic>? selectedCard,
    required double subtotal,
    required double shippingPrice,
  }) async {
    if (items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final total = subtotal + shippingPrice;

    final preparedItems = items.map((item) {
      return {
        ...item,
        'isRated': item['isRated'] ?? false,
      };
    }).toList();

    final orderData = {
      'orderId': '',
      'userId': _uid,
      'items': preparedItems,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'selectedCard': selectedCard,
      'subtotal': subtotal,
      'shippingPrice': shippingPrice,
      'total': total,

      // new fields for order flow
      'status': 'pending',
      'trackingNumber': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'deliveredAt': null,
      'cancelledAt': null,

      'createdAt': FieldValue.serverTimestamp(),
    };

    final orderRef = _ordersRef().doc();

    final fullOrderData = {
      ...orderData,
      'orderId': orderRef.id,
    };

    await orderRef.set(fullOrderData);

    await _userOrdersRef().doc(orderRef.id).set(fullOrderData);

    return orderRef.id;
  }
}