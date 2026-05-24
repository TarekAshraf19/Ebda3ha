class CartItem {
  final String cartItemId;
  final String productId;
  final String name;
  final String image;
  final num price;
  final int quantity;
  final String size;
  final String color;

  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.size,
    required this.color,
  });

  num get total => price * quantity;

  factory CartItem.fromMap(Map<String, dynamic> data, {String? docId}) {
    return CartItem(
      cartItemId: (data['cartItemId'] ?? docId ?? '').toString(),
      productId: (data['productId'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      image: (data['image'] ?? '').toString(),
      price: (data['price'] ?? 0) as num,
      quantity: (data['quantity'] ?? 1) as int,
      size: (data['size'] ?? '').toString(),
      color: (data['color'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'cartItemId': cartItemId,
    'productId': productId,
    'name': name,
    'image': image,
    'price': price,
    'quantity': quantity,
    'size': size,
    'color': color,
  };
}