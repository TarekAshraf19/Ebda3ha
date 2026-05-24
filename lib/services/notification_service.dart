import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// كل الإشعارات = الفردية + العامة
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> notificationsStream() {
    final uid = _uid;
    if (uid == null) {
      return const Stream.empty();
    }

    final singleStream = _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    final broadcastStream = _db
        .collection('broadcast_notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    return Rx.combineLatest2<
        List<QueryDocumentSnapshot<Map<String, dynamic>>>,
        List<QueryDocumentSnapshot<Map<String, dynamic>>>,
        List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      singleStream,
      broadcastStream,
          (singleDocs, broadcastDocs) {
        final allDocs = [...singleDocs, ...broadcastDocs];

        allDocs.sort((a, b) {
          final aData = a.data();
          final bData = b.data();

          final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);

          return bTime.compareTo(aTime);
        });

        return allDocs;
      },
    );
  }

  /// تعليم إشعار واحد كمقروء
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print("Error markAsRead: $e");
    }
  }

  /// تعليم كل الإشعارات الفردية كمقروءة
  Future<void> markAllAsRead() async {
    final uid = _uid;
    if (uid == null) return;

    final query = await _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();

    for (var doc in query.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  /// عدد الإشعارات غير المقروءة
  /// هنا بنحسب الفردية غير المقروءة + كل broadcast
  Stream<int> unreadCountStream() {
    final uid = _uid;
    if (uid == null) {
      return const Stream.empty();
    }

    final singleUnreadStream = _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    final broadcastCountStream = _db
        .collection('broadcast_notifications')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    return Rx.combineLatest2<int, int, int>(
      singleUnreadStream,
      broadcastCountStream,
          (singleUnread, broadcastCount) => singleUnread + broadcastCount,
    );
  }
}