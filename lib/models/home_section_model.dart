class HomeSectionModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final bool isActive;
  final int sortOrder;

  const HomeSectionModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.category = '',
    required this.isActive,
    required this.sortOrder,
  });

  factory HomeSectionModel.fromMap(String id, Map<String, dynamic> map) {
    return HomeSectionModel(
      id: id,
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      isActive: (map['isActive'] ?? true) as bool,
      sortOrder: (map['sortOrder'] is num)
          ? (map['sortOrder'] as num).toInt()
          : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'subtitle': subtitle.trim(),
      'category': category.trim(),
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }
}