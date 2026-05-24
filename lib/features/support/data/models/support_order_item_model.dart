import 'package:cloud_firestore/cloud_firestore.dart';

class SupportOrderItemModel {
  final String id;
  final String orderNumber;
  final String orderStatus;
  final int itemCount;
  final String userId;
  final DateTime? createdAt;

  const SupportOrderItemModel({
    required this.id,
    required this.orderNumber,
    required this.orderStatus,
    required this.itemCount,
    required this.userId,
    required this.createdAt,
  });

  factory SupportOrderItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? <String, dynamic>{};
    final items = (data['items'] as List?) ?? [];

    return SupportOrderItemModel(
      id: doc.id,
      orderNumber: (data['orderNumber'] ?? doc.id).toString(),
      orderStatus: (data['status'] ?? data['orderStatus'] ?? '').toString(),
      itemCount: items.length,
      userId: (data['userId'] ?? '').toString(),
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}