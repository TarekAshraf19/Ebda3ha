import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/support_message_model.dart';
import '../repositories/support_repository.dart';
import '../../domain/enums/support_enums.dart';

class SupportChatStartResult {
  final String conversationId;
  final bool isNewConversation;

  const SupportChatStartResult({
    required this.conversationId,
    required this.isNewConversation,
  });
}

class SupportChatService {
  final SupportRepository _repository;

  SupportChatService(this._repository);

  Future<SupportChatStartResult> startOrResumeSupportChat({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String userPhoto,
    required String botDisplayName,
    required String welcomeMessage,
  }) async {
    final existingConversationId =
    await _repository.getLatestOpenConversationId(userId);

    if (existingConversationId != null) {
      return SupportChatStartResult(
        conversationId: existingConversationId,
        isNewConversation: false,
      );
    }

    final newConversationId = await _repository.createConversation(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userPhoto: userPhoto,
    );

    await _repository.sendMessage(
      conversationId: newConversationId,
      message: SupportMessageModel(
        id: '',
        senderType: SenderType.bot,
        senderId: 'system_bot',
        senderName: botDisplayName,
        messageType: MessageType.text,
        text: welcomeMessage,
        quickReplyValue: '',
        quickReplyLabel: '',
        relatedOrderId: '',
        createdAt: null,
      ),
    );

    return SupportChatStartResult(
      conversationId: newConversationId,
      isNewConversation: true,
    );
  }

  Future<void> closeCurrentConversation(String conversationId) async {
    await _repository.closeConversation(conversationId);
  }

  Future<void> sendUserQuickReply({
    required String conversationId,
    required String userId,
    required String userName,
    required String label,
    required String value,
  }) async {
    await _repository.sendMessage(
      conversationId: conversationId,
      message: SupportMessageModel(
        id: '',
        senderType: SenderType.user,
        senderId: userId,
        senderName: userName,
        messageType: MessageType.quickReply,
        text: label,
        quickReplyValue: value,
        quickReplyLabel: label,
        relatedOrderId: '',
        createdAt: null,
      ),
    );
  }

  Future<void> selectIssue({
    required String conversationId,
    required String userId,
    required String userName,
    required IssueType issueType,
    required String issueTitle,
  }) async {
    await _repository.updateIssue(
      conversationId: conversationId,
      issueType: issueType,
      issueTitle: issueTitle,
    );

    await _repository.sendMessage(
      conversationId: conversationId,
      message: SupportMessageModel(
        id: '',
        senderType: SenderType.user,
        senderId: userId,
        senderName: userName,
        messageType: MessageType.quickReply,
        text: issueTitle,
        quickReplyValue: issueType.value,
        quickReplyLabel: issueTitle,
        relatedOrderId: '',
        createdAt: null,
      ),
    );
  }

  Future<void> selectOrder({
    required String conversationId,
    required String userId,
    required String userName,
    required String orderId,
    required String orderNumber,
    required String orderStatus,
  }) async {
    await _repository.updateOrder(
      conversationId: conversationId,
      orderId: orderId,
      orderNumber: orderNumber,
      orderStatus: orderStatus,
    );

    await _repository.sendMessage(
      conversationId: conversationId,
      message: SupportMessageModel(
        id: '',
        senderType: SenderType.user,
        senderId: userId,
        senderName: userName,
        messageType: MessageType.orderCard,
        text: 'Selected order $orderNumber',
        quickReplyValue: '',
        quickReplyLabel: '',
        relatedOrderId: orderId,
        createdAt: null,
      ),
    );
  }

  Future<void> sendBotTextMessage({
    required String conversationId,
    required String text,
    required String senderName,
  }) async {
    await _repository.sendMessage(
      conversationId: conversationId,
      message: SupportMessageModel(
        id: '',
        senderType: SenderType.bot,
        senderId: 'system_bot',
        senderName: senderName,
        messageType: MessageType.text,
        text: text,
        quickReplyValue: '',
        quickReplyLabel: '',
        relatedOrderId: '',
        createdAt: null,
      ),
    );
  }

  Future<void> handoffToAdmin({
    required String conversationId,
    required String systemMessage,
    required String systemSenderName,
  }) async {
    await _repository.escalateToAdmin(conversationId);

    await _repository.sendMessage(
      conversationId: conversationId,
      message: SupportMessageModel(
        id: '',
        senderType: SenderType.system,
        senderId: 'system',
        senderName: systemSenderName,
        messageType: MessageType.system,
        text: systemMessage,
        quickReplyValue: '',
        quickReplyLabel: '',
        relatedOrderId: '',
        createdAt: null,
      ),
    );

    await FirebaseFirestore.instance
        .collection('support_conversations')
        .doc(conversationId)
        .set({
      'resolvedByBot': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markConversationResolvedByBot({
    required String conversationId,
  }) async {
    await FirebaseFirestore.instance
        .collection('support_conversations')
        .doc(conversationId)
        .set({
      'status': 'resolved',
      'resolvedByBot': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'resolvedAt': FieldValue.serverTimestamp(),
      'adminTyping': false,
      'adminTypingName': '',
    }, SetOptions(merge: true));
  }
}