import 'dart:async';

import '../../data/models/support_conversation_model.dart';
import '../../data/models/support_message_model.dart';
import '../../data/repositories/support_repository.dart';
import '../../data/services/support_chat_service.dart';
import '../../domain/enums/support_enums.dart';

class SupportChatController {
  final SupportRepository _repository;
  final SupportChatService _service;

  SupportChatController({
    required SupportRepository repository,
    required SupportChatService service,
  })  : _repository = repository,
        _service = service;

  String? conversationId;
  bool didResumeExistingConversation = false;

  StreamSubscription<SupportConversationModel>? _conversationSubscription;
  StreamSubscription<List<SupportMessageModel>>? _messagesSubscription;

  SupportConversationModel? conversation;
  List<SupportMessageModel> messages = [];

  void Function()? onChanged;
  void Function(String message)? onError;

  bool isLoading = false;
  bool isStartingChat = false;

  void _notify() {
    onChanged?.call();
  }

  void _setLoading(bool value) {
    isLoading = value;
    _notify();
  }

  Future<void> initChat({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String userPhoto,
    required String botDisplayName,
    required String welcomeMessage,
  }) async {
    try {
      isStartingChat = true;
      _notify();

      final result = await _service.startOrResumeSupportChat(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
        userPhoto: userPhoto,
        botDisplayName: botDisplayName,
        welcomeMessage: welcomeMessage,
      );

      conversationId = result.conversationId;
      didResumeExistingConversation = !result.isNewConversation;

      _listenToConversation(result.conversationId);
      _listenToMessages(result.conversationId);
    } catch (e) {
      onError?.call('Failed to initialize support chat: $e');
    } finally {
      isStartingChat = false;
      _notify();
    }
  }

  Future<bool> tryOpenExistingConversation({
    required String userId,
  }) async {
    try {
      isStartingChat = true;
      _notify();

      final existingConversationId =
      await _repository.getLatestOpenConversationId(userId);

      if (existingConversationId == null) {
        didResumeExistingConversation = false;
        return false;
      }

      conversationId = existingConversationId;
      didResumeExistingConversation = true;

      _listenToConversation(existingConversationId);
      _listenToMessages(existingConversationId);

      return true;
    } catch (e) {
      onError?.call('Failed to open existing conversation: $e');
      return false;
    } finally {
      isStartingChat = false;
      _notify();
    }
  }

  Future<void> closeCurrentConversation() async {
    if (conversationId == null) return;

    try {
      _setLoading(true);
      await _service.closeCurrentConversation(conversationId!);
    } catch (e) {
      onError?.call('Failed to close current conversation: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetForNewChat() async {
    await _conversationSubscription?.cancel();
    await _messagesSubscription?.cancel();

    _conversationSubscription = null;
    _messagesSubscription = null;

    conversationId = null;
    didResumeExistingConversation = false;
    conversation = null;
    messages = [];

    _notify();
  }

  void _listenToConversation(String conversationId) {
    _conversationSubscription?.cancel();

    _conversationSubscription =
        _repository.streamConversation(conversationId).listen(
              (conversationData) {
            conversation = conversationData;
            _notify();
          },
          onError: (error) {
            onError?.call('Conversation stream error: $error');
          },
        );
  }

  void _listenToMessages(String conversationId) {
    _messagesSubscription?.cancel();

    _messagesSubscription = _repository.streamMessages(conversationId).listen(
          (messagesData) {
        messages = messagesData;
        _notify();
      },
      onError: (error) {
        onError?.call('Messages stream error: $error');
      },
    );
  }

  Future<void> sendQuickReply({
    required String userId,
    required String userName,
    required String label,
    required String value,
  }) async {
    if (conversationId == null) return;

    try {
      _setLoading(true);

      await _service.sendUserQuickReply(
        conversationId: conversationId!,
        userId: userId,
        userName: userName,
        label: label,
        value: value,
      );
    } catch (e) {
      onError?.call('Failed to send quick reply: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> chooseIssue({
    required String userId,
    required String userName,
    required IssueType issueType,
    required String issueTitle,
  }) async {
    if (conversationId == null) return;

    try {
      _setLoading(true);

      await _service.selectIssue(
        conversationId: conversationId!,
        userId: userId,
        userName: userName,
        issueType: issueType,
        issueTitle: issueTitle,
      );
    } catch (e) {
      onError?.call('Failed to choose issue: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> chooseOrder({
    required String userId,
    required String userName,
    required String orderId,
    required String orderNumber,
    required String orderStatus,
  }) async {
    if (conversationId == null) return;

    try {
      _setLoading(true);

      await _service.selectOrder(
        conversationId: conversationId!,
        userId: userId,
        userName: userName,
        orderId: orderId,
        orderNumber: orderNumber,
        orderStatus: orderStatus,
      );
    } catch (e) {
      onError?.call('Failed to choose order: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendBotReply({
    required String text,
    required String senderName,
  }) async {
    if (conversationId == null) return;

    try {
      _setLoading(true);

      await _service.sendBotTextMessage(
        conversationId: conversationId!,
        text: text,
        senderName: senderName,
      );
    } catch (e) {
      onError?.call('Failed to send bot reply: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> transferToAdmin({
    required String systemMessage,
    required String systemSenderName,
  }) async {
    if (conversationId == null) return;

    try {
      _setLoading(true);

      await _service.handoffToAdmin(
        conversationId: conversationId!,
        systemMessage: systemMessage,
        systemSenderName: systemSenderName,
      );
    } catch (e) {
      onError?.call('Failed to transfer chat to admin: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resolveByBot() async {
    if (conversationId == null) return;

    try {
      _setLoading(true);
      await _service.markConversationResolvedByBot(
        conversationId: conversationId!,
      );
    } catch (e) {
      onError?.call('Failed to resolve chat by bot: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> dispose() async {
    await _conversationSubscription?.cancel();
    await _messagesSubscription?.cancel();
  }
}