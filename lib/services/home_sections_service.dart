import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/home_section_model.dart';

class HomeSectionsService {
  HomeSectionsService._();
  static final instance = HomeSectionsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> sectionsRef() {
    return _db.collection('home_sections');
  }

  Stream<List<HomeSectionModel>> activeSectionsStream() {
    return sectionsRef().snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => HomeSectionModel.fromMap(doc.id, doc.data()))
          .where((section) => section.isActive)
          .toList();

      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Stream<List<HomeSectionModel>> allSectionsStream() {
    return sectionsRef().snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => HomeSectionModel.fromMap(doc.id, doc.data()))
          .toList();

      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Future<void> addSection({
    required String title,
    String subtitle = '',
    String category = '',
    required int sortOrder,
    bool isActive = true,
  }) async {
    final id = _slugify(title);

    await sectionsRef().doc(id).set({
      'title': title.trim(),
      'subtitle': subtitle.trim(),
      'category': category.trim(),
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSection({
    required String sectionId,
    required String title,
    String subtitle = '',
    String category = '',
    required int sortOrder,
    required bool isActive,
  }) async {
    await sectionsRef().doc(sectionId).update({
      'title': title.trim(),
      'subtitle': subtitle.trim(),
      'category': category.trim(),
      'sortOrder': sortOrder,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSection(String sectionId) async {
    await sectionsRef().doc(sectionId).delete();
  }

  String _slugify(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}