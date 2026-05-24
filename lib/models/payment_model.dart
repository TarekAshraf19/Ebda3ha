class PaymentCardModel {
  final String id;
  final String brand;
  final String last4;
  final String holderName;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  PaymentCardModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holderName,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });

  factory PaymentCardModel.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentCardModel(
      id: docId,
      brand: (map['brand'] ?? '').toString(),
      last4: (map['last4'] ?? '').toString(),
      holderName: (map['holderName'] ?? '').toString(),
      expMonth: (map['expMonth'] ?? 0) as int,
      expYear: (map['expYear'] ?? 0) as int,
      isDefault: (map['isDefault'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'last4': last4,
      'holderName': holderName,
      'expMonth': expMonth,
      'expYear': expYear,
      'isDefault': isDefault,
    };
  }
}