class Product {
  final String id;
  final String name;
  final String image;
  final num price;
  final String description;
  final String category;
  final double rating;
  final int reviewsCount;
  final List<String> sectionIds;
  final bool isActive;

  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.description = '',
    this.category = '',
    this.rating = 0,
    this.reviewsCount = 0,
    this.sectionIds = const [],
    this.isActive = true,
  });

  String get normalizedCategory {
    final value = category.trim().toLowerCase();

    switch (value) {
      case 'bags':
      case 'accessories':
        return 'Accessories';

      case 'others':
      case 'collection':
        return 'Collection';

      case 'clothing':
        return 'Clothing';

      case 'shoes':
        return 'Shoes';

      default:
        return category.trim();
    }
  }

  factory Product.fromDoc(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: (data['name'] ?? data['title'] ?? '').toString(),
      image: (data['image'] ?? data['imageUrl'] ?? '').toString(),
      price: (data['price'] is num) ? (data['price'] as num) : 0,
      description: (data['description'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      rating: (data['rating'] is num)
          ? (data['rating'] as num).toDouble()
          : 0.0,
      reviewsCount: (data['reviewsCount'] is num)
          ? (data['reviewsCount'] as num).toInt()
          : 0,
      sectionIds: data['sectionIds'] is List
          ? List<String>.from(data['sectionIds'])
          : [],
      isActive: (data['isActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': name,
      'image': image,
      'imageUrl': image,
      'price': price,
      'description': description,
      'category': normalizedCategory,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'sectionIds': sectionIds,
      'isActive': isActive,
    };
  }
}