class OrderItemModel {
  final String cartItemId;
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final String size;
  final String color;
  final double total;
  final bool isRated;

  OrderItemModel({
    required this.cartItemId,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.size,
    required this.color,
    required this.total,
    required this.isRated,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      cartItemId: (map['cartItemId'] ?? '').toString(),
      productId: (map['productId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0) as int,
      size: (map['size'] ?? '').toString(),
      color: (map['color'] ?? '').toString(),
      total: (map['total'] ?? 0).toDouble(),
      isRated: (map['isRated'] ?? false) as bool,
    );
  }
}

class OrderModel {
  final String orderId;
  final String userId;
  final String status;
  final String trackingNumber;
  final Map<String, dynamic> shippingAddress;
  final List<OrderItemModel> items;
  final String paymentMethod;
  final Map<String, dynamic>? selectedCard;
  final double subtotal;
  final double shippingPrice;
  final double total;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.status,
    required this.trackingNumber,
    required this.shippingAddress,
    required this.items,
    required this.paymentMethod,
    required this.selectedCard,
    required this.subtotal,
    required this.shippingPrice,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveredAt,
    required this.cancelledAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawItems = (map['items'] as List?) ?? [];

    return OrderModel(
      orderId: (map['orderId'] ?? docId).toString(),
      userId: (map['userId'] ?? '').toString(),
      status: (map['status'] ?? 'pending').toString(),
      trackingNumber: (map['trackingNumber'] ?? '').toString(),
      shippingAddress: Map<String, dynamic>.from(map['shippingAddress'] ?? {}),
      items: rawItems
          .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      paymentMethod: (map['paymentMethod'] ?? '').toString(),
      selectedCard: map['selectedCard'] != null
          ? Map<String, dynamic>.from(map['selectedCard'])
          : null,
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingPrice: (map['shippingPrice'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt']).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt']).toDate()
          : null,
      deliveredAt: map['deliveredAt'] != null
          ? (map['deliveredAt']).toDate()
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? (map['cancelledAt']).toDate()
          : null,
    );
  }
}