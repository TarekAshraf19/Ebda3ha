import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/payment_model.dart';

class PaymentService {
  PaymentService._();
  static final instance = PaymentService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> cardsRef() {
    return _db.collection('users').doc(_uid).collection('cards');
  }

  Stream<List<PaymentCardModel>> cardsStream() {
    return cardsRef()
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => PaymentCardModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> addCard({
    required String cardNumber,
    required String holderName,
    required int expMonth,
    required int expYear,
    required String brand,
  }) async {
    final cleanNumber = cardNumber.replaceAll(' ', '');

    final existing = await cardsRef().get();
    final isFirstCard = existing.docs.isEmpty;

    await cardsRef().add({
      'brand': brand,
      'last4': cleanNumber.substring(cleanNumber.length - 4),
      'holderName': holderName.trim(),
      'expMonth': expMonth,
      'expYear': expYear,
      'isDefault': isFirstCard,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(_uid).set({
      'payment': 'Card added',
    }, SetOptions(merge: true));
  }

  Future<void> setDefaultCard(String cardId) async {
    final batch = _db.batch();
    final allCards = await cardsRef().get();

    for (final doc in allCards.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == cardId});
    }

    await batch.commit();
  }

  Future<void> deleteCard(String cardId) async {
    await cardsRef().doc(cardId).delete();

    final allCards = await cardsRef().get();
    if (allCards.docs.isNotEmpty) {
      final hasDefault =
      allCards.docs.any((doc) => (doc.data()['isDefault'] ?? false) == true);

      if (!hasDefault) {
        await allCards.docs.first.reference.update({'isDefault': true});
      }
    } else {
      await _db.collection('users').doc(_uid).set({
        'payment': '',
      }, SetOptions(merge: true));
    }
  }

  Future<bool> mockValidateCard({
    required String cardNumber,
    required String holderName,
    required String expiry,
    required String cvc,
  }) async {
    final clean = cardNumber.replaceAll(' ', '');

    if (!_isValidCardNumber(clean)) return false;
    if (holderName.trim().isEmpty) return false;
    if (!_isValidExpiry(expiry)) return false;
    if (!_isValidCvc(cvc)) return false;

    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }

  bool _isValidCardNumber(String input) {
    if (input.length < 13 || input.length > 19) return false;
    if (!RegExp(r'^[0-9]+$').hasMatch(input)) return false;
    return _passesLuhn(input);
  }

  bool _passesLuhn(String number) {
    int sum = 0;
    bool alternate = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  bool _isValidExpiry(String expiry) {
    final match = RegExp(r'^(\d{2})\/(\d{2})$').firstMatch(expiry);
    if (match == null) return false;

    final month = int.parse(match.group(1)!);
    final year = int.parse(match.group(2)!);

    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final fullYear = 2000 + year;
    final expiryDate = DateTime(fullYear, month + 1, 0);

    return !expiryDate.isBefore(DateTime(now.year, now.month, 1));
  }

  bool _isValidCvc(String cvc) {
    return RegExp(r'^\d{3,4}$').hasMatch(cvc);
  }

  String detectBrand(String cardNumber) {
    final clean = cardNumber.replaceAll(' ', '');

    if (clean.startsWith('4')) return 'visa';

    final firstTwo = clean.length >= 2 ? int.tryParse(clean.substring(0, 2)) : null;
    final firstFour =
    clean.length >= 4 ? int.tryParse(clean.substring(0, 4)) : null;

    if ((firstTwo != null && firstTwo >= 51 && firstTwo <= 55) ||
        (firstFour != null && firstFour >= 2221 && firstFour <= 2720)) {
      return 'mastercard';
    }

    return 'card';
  }
}