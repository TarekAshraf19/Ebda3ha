import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/support_bot_config_model.dart';
import '../models/support_conversation_model.dart';
import '../models/support_message_model.dart';
import '../models/support_order_item_model.dart';
import '../../domain/enums/support_enums.dart';

class SupportRepository {
  final FirebaseFirestore _firestore;

  SupportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversationsRef =>
      _firestore.collection('support_conversations');

  CollectionReference<Map<String, dynamic>> _messagesRef(
      String conversationId,
      ) =>
      _conversationsRef.doc(conversationId).collection('messages');

  DocumentReference<Map<String, dynamic>> get _botConfigRef =>
      _firestore.collection('support_bot_config').doc('main');

  CollectionReference<Map<String, dynamic>> _userOrdersRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('orders');

  Future<String> createConversation({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String userPhoto,
  }) async {
    final now = FieldValue.serverTimestamp();
    final docRef = _conversationsRef.doc();

    await docRef.set({
      "userId": userId,
      "userName": userName,
      "userEmail": userEmail,
      "userPhone": userPhone,
      "userPhoto": userPhoto,
      "status": ConversationStatus.botActive.value,
      "issueType": "",
      "issueTitle": "",
      "orderId": "",
      "orderNumber": "",
      "orderStatus": "",
      "botEnabled": true,
      "isAssignedToAdmin": false,
      "assignedAdminId": "",
      "assignedAdminName": "",
      "priority": "medium",
      "source": "mobile_app",
      "lastMessage": "",
      "lastMessageSenderType": "",
      "lastMessageAt": null,
      "unreadCountUser": 0,
      "unreadCountAdmin": 0,
      "createdAt": now,
      "updatedAt": now,
      "resolvedAt": null,
      "closedAt": null,
    });

    return docRef.id;
  }

  Future<String?> getLatestOpenConversationId(String userId) async {
    final snapshot = await _conversationsRef
        .where('userId', isEqualTo: userId)
        .where(
      'status',
      whereIn: [
        ConversationStatus.botActive.value,
        ConversationStatus.waitingAdmin.value,
        ConversationStatus.humanJoined.value,
      ],
    )
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  Future<void> closeConversation(String conversationId) async {
    await _conversationsRef.doc(conversationId).update({
      'status': ConversationStatus.closed.value,
      'closedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage({
    required String conversationId,
    required SupportMessageModel message,
  }) async {
    final now = FieldValue.serverTimestamp();
    final msgRef = _messagesRef(conversationId).doc();

    await msgRef.set({
      ...message.toMap(),
      "createdAt": now,
    });

    await _conversationsRef.doc(conversationId).update({
      "lastMessage": message.text,
      "lastMessageSenderType": message.senderType.value,
      "lastMessageAt": now,
      "updatedAt": now,
      if (message.senderType == SenderType.user)
        "unreadCountAdmin": FieldValue.increment(1),
      if (message.senderType == SenderType.admin)
        "unreadCountUser": FieldValue.increment(1),
    });
  }

  Stream<List<SupportMessageModel>> streamMessages(String conversationId) {
    return _messagesRef(conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => SupportMessageModel.fromFirestore(doc))
          .toList(),
    );
  }

  Stream<SupportConversationModel> streamConversation(String conversationId) {
    return _conversationsRef.doc(conversationId).snapshots().map(
          (doc) => SupportConversationModel.fromFirestore(doc),
    );
  }

  Future<void> updateIssue({
    required String conversationId,
    required IssueType issueType,
    required String issueTitle,
  }) async {
    await _conversationsRef.doc(conversationId).update({
      "issueType": issueType.value,
      "issueTitle": issueTitle,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOrder({
    required String conversationId,
    required String orderId,
    required String orderNumber,
    required String orderStatus,
  }) async {
    await _conversationsRef.doc(conversationId).update({
      "orderId": orderId,
      "orderNumber": orderNumber,
      "orderStatus": orderStatus,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> escalateToAdmin(String conversationId) async {
    await _conversationsRef.doc(conversationId).update({
      "status": ConversationStatus.waitingAdmin.value,
      "botEnabled": false,
      "updatedAt": FieldValue.serverTimestamp(),
      "unreadCountAdmin": FieldValue.increment(1),
    });
  }

  Future<void> assignAdmin({
    required String conversationId,
    required String adminId,
    required String adminName,
  }) async {
    await _conversationsRef.doc(conversationId).update({
      "status": ConversationStatus.humanJoined.value,
      "isAssignedToAdmin": true,
      "assignedAdminId": adminId,
      "assignedAdminName": adminName,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveConversation(String conversationId) async {
    await _conversationsRef.doc(conversationId).update({
      "status": ConversationStatus.resolved.value,
      "resolvedAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<SupportBotConfigModel> getBotConfig() async {
    final doc = await _botConfigRef.get();
    return SupportBotConfigModel.fromMap(doc.data() ?? {});
  }

  Stream<List<SupportConversationModel>> streamWaitingChats() {
    return _conversationsRef
        .where('status', isEqualTo: ConversationStatus.waitingAdmin.value)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => SupportConversationModel.fromFirestore(doc))
          .toList(),
    );
  }

  Stream<List<SupportOrderItemModel>> streamUserOrders(String userId) {
    return _userOrdersRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => SupportOrderItemModel.fromFirestore(doc))
          .toList(),
    );
  }

  Future<void> cancelUserOrder({
    required String userId,
    required String orderId,
  }) async {
    await _userOrdersRef(userId).doc(orderId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
}