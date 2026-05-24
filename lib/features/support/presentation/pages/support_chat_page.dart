import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/support_conversation_model.dart';
import '../../data/models/support_message_model.dart';
import '../../data/models/support_order_item_model.dart';
import '../../data/repositories/support_repository.dart';
import '../../data/services/support_bot_flow_service.dart';
import '../../data/services/support_chat_service.dart';
import '../controllers/support_chat_controller.dart';
import '../../domain/enums/support_enums.dart';
import '../strings/support_chat_strings.dart';

enum SupportLang { en, ar }

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  late final SupportRepository _repository;
  late final SupportChatService _service;
  late final SupportChatController _controller;
  late final SupportBotFlowService _botFlowService;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  Timer? _userTypingTimer;

  SupportLang? _selectedLang;
  bool _showMainCategoryOptions = false;
  bool _showSubIssueOptions = false;
  bool _showOrderOptions = false;
  bool _didRestoreUiState = false;
  bool _checkedExistingConversation = false;

  MainIssueCategory? _selectedMainCategory;
  IssueType? _selectedIssueType;
  List<SupportSubIssueOption> _currentSubIssues = [];

  SupportChatStrings get _strings {
    if (_selectedLang == SupportLang.ar) {
      return SupportChatStrings.arabic();
    }
    return SupportChatStrings.english();
  }

  @override
  void initState() {
    super.initState();

    _repository = SupportRepository();
    _service = SupportChatService(_repository);
    _controller = SupportChatController(
      repository: _repository,
      service: _service,
    );
    _botFlowService = const SupportBotFlowService();

    _controller.onChanged = () {
      if (!mounted) return;
      _restoreUiStateFromConversationIfNeeded();
      setState(() {});
      _scrollToBottom();
    };

    _controller.onError = (message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    };

    _checkExistingConversationOnOpen();
  }

  Future<void> _checkExistingConversationOnOpen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _checkedExistingConversation = true;
      });
      return;
    }

    final opened = await _controller.tryOpenExistingConversation(
      userId: user.uid,
    );

    if (!mounted) return;

    setState(() {
      _checkedExistingConversation = true;
    });

    if (!opened) {
      setState(() {
        _selectedLang = null;
        _showMainCategoryOptions = false;
        _showSubIssueOptions = false;
        _showOrderOptions = false;
      });
    }
  }

  @override
  void dispose() {
    _userTypingTimer?.cancel();
    _setUserTyping(false);
    _scrollController.dispose();
    _messageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _isArabicSelected => _selectedLang == SupportLang.ar;

  Future<String> _resolveCurrentUserPhoto(User user) async {
    if ((user.photoURL ?? '').trim().isNotEmpty) {
      return user.photoURL!.trim();
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data() ?? <String, dynamic>{};
      final photo =
      (data['photoUrl'] ?? data['userPhoto'] ?? '').toString().trim();

      return photo;
    } catch (_) {
      return '';
    }
  }

  Future<void> _setUserTyping(bool isTyping) async {
    if (_controller.conversationId == null) return;

    final user = FirebaseAuth.instance.currentUser!;
    final userName = user.displayName ?? 'User';

    await FirebaseFirestore.instance
        .collection('support_conversations')
        .doc(_controller.conversationId)
        .set({
      'userTyping': isTyping,
      'userTypingName': isTyping ? userName : '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _onUserTypingChanged(String value) {
    _userTypingTimer?.cancel();

    if (value.trim().isNotEmpty) {
      _setUserTyping(true);

      _userTypingTimer = Timer(const Duration(seconds: 4), () async {
        await _setUserTyping(false);
      });
    } else {
      _setUserTyping(false);
    }
  }

  Future<void> _startChatWithLanguage(SupportLang lang) async {
    final user = FirebaseAuth.instance.currentUser!;
    final strings = lang == SupportLang.ar
        ? SupportChatStrings.arabic()
        : SupportChatStrings.english();

    final resolvedPhoto = await _resolveCurrentUserPhoto(user);

    setState(() {
      _selectedLang = lang;
      _showMainCategoryOptions = true;
      _showSubIssueOptions = false;
      _showOrderOptions = false;
      _selectedMainCategory = null;
      _selectedIssueType = null;
      _currentSubIssues = [];
      _didRestoreUiState = false;
    });

    await _controller.initChat(
      userId: user.uid,
      userName: user.displayName ?? 'User',
      userEmail: user.email ?? '',
      userPhone: '',
      userPhoto: resolvedPhoto,
      botDisplayName: strings.botName,
      welcomeMessage: strings.welcomeMessage,
    );
  }

  Future<void> _startNewChatFromBeginning() async {
    if (_controller.conversationId != null) {
      await _controller.closeCurrentConversation();
    }

    await _controller.resetForNewChat();

    if (!mounted) return;

    setState(() {
      _selectedLang = null;
      _showMainCategoryOptions = false;
      _showSubIssueOptions = false;
      _showOrderOptions = false;
      _selectedMainCategory = null;
      _selectedIssueType = null;
      _currentSubIssues = [];
      _didRestoreUiState = false;
      _checkedExistingConversation = true;
    });

    _messageController.clear();
  }

  Future<void> _onChooseMainCategory(MainIssueCategory category) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userName = user.displayName ?? 'User';

    final label = _mainCategoryLabel(category);

    await _controller.sendQuickReply(
      userId: user.uid,
      userName: userName,
      label: label,
      value: category.value,
    );

    final result = _botFlowService.handleMainCategorySelection(
      category: category,
      strings: _strings,
    );

    for (final message in result.botMessages) {
      await _controller.sendBotReply(
        text: message,
        senderName: _strings.botName,
      );
    }

    if (result.transferToAdmin && result.systemMessage != null) {
      await _controller.transferToAdmin(
        systemMessage: result.systemMessage!,
        systemSenderName: _strings.systemName,
      );
    }

    setState(() {
      _selectedMainCategory = category;
      _currentSubIssues = result.subIssues;
      _showMainCategoryOptions = false;
      _showSubIssueOptions = result.showSubIssues;
      _showOrderOptions = false;
    });
  }

  Future<void> _onChooseSubIssue(SupportSubIssueOption option) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userName = user.displayName ?? 'User';

    await _controller.chooseIssue(
      userId: user.uid,
      userName: userName,
      issueType: option.issueType,
      issueTitle: option.label,
    );

    await _controller.sendBotReply(
      text: _strings.selectOrderMessage,
      senderName: _strings.botName,
    );

    setState(() {
      _selectedIssueType = option.issueType;
      _showSubIssueOptions = false;
      _showOrderOptions = true;
    });
  }

  Future<void> _onSelectOrder(SupportOrderItemModel order) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userName = user.displayName ?? 'User';
    final issueType = _selectedIssueType ?? IssueType.other;
    final canAutoCancel = _canAutoCancel(order);

    await _controller.chooseOrder(
      userId: user.uid,
      userName: userName,
      orderId: order.id,
      orderNumber: order.orderNumber,
      orderStatus: order.orderStatus,
    );

    final result = _botFlowService.handleOrderSelection(
      issueType: issueType,
      orderStatus: order.orderStatus,
      canAutoCancel: canAutoCancel,
      strings: _strings,
    );

    if (result.shouldAutoCancel) {
      await _repository.cancelUserOrder(
        userId: user.uid,
        orderId: order.id,
      );
    }

    for (final message in result.botMessages) {
      await _controller.sendBotReply(
        text: message,
        senderName: _strings.botName,
      );
    }

    if (result.transferToAdmin && result.systemMessage != null) {
      await _controller.transferToAdmin(
        systemMessage: result.systemMessage!,
        systemSenderName: _strings.systemName,
      );
    } else {
      await _controller.resolveByBot();
    }

    setState(() {
      _showOrderOptions = false;
    });
  }

  List<SupportOrderItemModel> _filterOrders(
      List<SupportOrderItemModel> orders,
      ) {
    final issueType = _selectedIssueType;

    if (issueType == null) return orders;

    if (issueType == IssueType.orderNotReceived) {
      return orders;
    }

    if (issueType == IssueType.cancelOrder) {
      return orders.where((order) {
        final status = order.orderStatus.toLowerCase();
        return status == 'pending' || status == 'processing';
      }).toList();
    }

    if (issueType == IssueType.returnOrder ||
        issueType == IssueType.damagedPackage) {
      return orders.where((order) {
        final status = order.orderStatus.toLowerCase();
        return status == 'delivered';
      }).toList();
    }

    return orders;
  }

  bool _canAutoCancel(SupportOrderItemModel order) {
    if (order.createdAt == null) return false;

    final now = DateTime.now();
    final createdAt = order.createdAt!;

    return now.year == createdAt.year &&
        now.month == createdAt.month &&
        now.day == createdAt.day;
  }

  String _mainCategoryLabel(MainIssueCategory category) {
    switch (category) {
      case MainIssueCategory.orderIssues:
        return _strings.mainOrderIssues;
      case MainIssueCategory.itemQuality:
        return _strings.mainItemQuality;
      case MainIssueCategory.paymentIssues:
        return _strings.mainPaymentIssues;
      case MainIssueCategory.technicalAssistance:
        return _strings.mainTechnicalAssistance;
      case MainIssueCategory.other:
        return _strings.mainOther;
    }
  }

  MainIssueCategory? _inferMainCategoryFromIssueType(IssueType issueType) {
    switch (issueType) {
      case IssueType.orderNotReceived:
      case IssueType.cancelOrder:
      case IssueType.returnOrder:
        return MainIssueCategory.orderIssues;
      case IssueType.damagedPackage:
        return MainIssueCategory.itemQuality;
      case IssueType.paymentIssue:
        return MainIssueCategory.paymentIssues;
      case IssueType.technicalAssistance:
        return MainIssueCategory.technicalAssistance;
      case IssueType.other:
        return MainIssueCategory.other;
      case IssueType.unknown:
        return null;
    }
  }

  List<SupportSubIssueOption> _buildSubIssuesForCategory(
      MainIssueCategory category,
      ) {
    final result = _botFlowService.handleMainCategorySelection(
      category: category,
      strings: _strings,
    );
    return result.subIssues;
  }

  SupportLang _detectLanguageFromMessages() {
    final hasArabic = _controller.messages.any((message) {
      return RegExp(r'[\u0600-\u06FF]').hasMatch(message.text);
    });

    return hasArabic ? SupportLang.ar : SupportLang.en;
  }

  void _restoreUiStateFromConversationIfNeeded() {
    if (_controller.conversation == null) return;
    if (_selectedLang == null && _controller.didResumeExistingConversation) {
      _selectedLang = _detectLanguageFromMessages();
    }
    if (_selectedLang == null) return;
    if (_didRestoreUiState) return;

    final conversation = _controller.conversation!;
    final issueType = conversation.issueType;
    final hasOrder = conversation.orderId.isNotEmpty;
    final status = conversation.status;

    if (status == ConversationStatus.waitingAdmin ||
        status == ConversationStatus.humanJoined ||
        status == ConversationStatus.resolved ||
        status == ConversationStatus.closed) {
      setState(() {
        _selectedIssueType =
        issueType == IssueType.unknown ? null : conversation.issueType;
        _selectedMainCategory = issueType == IssueType.unknown
            ? null
            : _inferMainCategoryFromIssueType(issueType);
        _currentSubIssues = _selectedMainCategory == null
            ? []
            : _buildSubIssuesForCategory(_selectedMainCategory!);
        _showMainCategoryOptions = false;
        _showSubIssueOptions = false;
        _showOrderOptions = false;
        _didRestoreUiState = true;
      });
      return;
    }

    if (issueType == IssueType.unknown) {
      setState(() {
        _selectedMainCategory = null;
        _selectedIssueType = null;
        _currentSubIssues = [];
        _showMainCategoryOptions = true;
        _showSubIssueOptions = false;
        _showOrderOptions = false;
        _didRestoreUiState = true;
      });
      return;
    }

    final inferredCategory = _inferMainCategoryFromIssueType(issueType);
    final subIssues = inferredCategory == null
        ? <SupportSubIssueOption>[]
        : _buildSubIssuesForCategory(inferredCategory);

    if (!hasOrder) {
      setState(() {
        _selectedMainCategory = inferredCategory;
        _selectedIssueType = issueType;
        _currentSubIssues = subIssues;
        _showMainCategoryOptions = false;
        _showSubIssueOptions = false;
        _showOrderOptions = true;
        _didRestoreUiState = true;
      });
      return;
    }

    setState(() {
      _selectedMainCategory = inferredCategory;
      _selectedIssueType = issueType;
      _currentSubIssues = subIssues;
      _showMainCategoryOptions = false;
      _showSubIssueOptions = false;
      _showOrderOptions = false;
      _didRestoreUiState = true;
    });
  }

  Future<void> _sendFreeTextMessage() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userName = user.displayName ?? 'User';
    final text = _messageController.text.trim();

    if (text.isEmpty) return;
    if (_controller.conversationId == null) return;

    await _controller.sendQuickReply(
      userId: user.uid,
      userName: userName,
      label: text,
      value: 'free_text',
    );

    _userTypingTimer?.cancel();
    await _setUserTyping(false);

    _messageController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool _isUserMessage(SupportMessageModel message) {
    return message.senderType == SenderType.user;
  }

  bool _shouldShowStartNewChatButton() {
    final status = _controller.conversation?.status;
    return status == ConversationStatus.waitingAdmin ||
        status == ConversationStatus.humanJoined ||
        status == ConversationStatus.resolved ||
        status == ConversationStatus.closed;
  }

  String _pageTitle() {
    final conversation = _controller.conversation;
    if (conversation != null &&
        conversation.assignedAdminName.trim().isNotEmpty) {
      return conversation.assignedAdminName;
    }
    return _selectedLang == null
        ? SupportChatStrings.english().title
        : _strings.title;
  }

  String _pageSubtitle() {
    final conversation = _controller.conversation;
    if (conversation != null &&
        conversation.assignedAdminName.trim().isNotEmpty) {
      return _selectedLang == SupportLang.ar
          ? 'موظف خدمة العملاء'
          : 'Support Agent';
    }
    return _selectedLang == null
        ? SupportChatStrings.english().subtitle
        : _strings.subtitle;
  }

  Widget _leadingAvatar() {
    final conversation = _controller.conversation;
    if (conversation != null &&
        conversation.assignedAdminName.trim().isNotEmpty) {
      return _CircleAvatarWidget(
        imageUrl: conversation.assignedAdminPhoto,
        name: conversation.assignedAdminName,
        backgroundColor: const Color(0xFFF7D7E7),
        icon: Icons.person,
        iconColor: const Color(0xFFC2187A),
      );
    }

    return const _CircleAvatarWidget(
      imageUrl: '',
      name: 'Bot',
      backgroundColor: Color(0xFFF7D7E7),
      icon: Icons.support_agent,
      iconColor: Color(0xFFC2187A),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F4F4);
    final botBubbleColor = const Color(0xFFC2187A);
    final adminBubbleColor =
    isDark ? const Color(0xFF253144) : const Color(0xFFE8F1FF);
    final systemBubbleColor =
    isDark ? const Color(0xFF4A235A) : const Color(0xFFF2E8FF);
    final userBubbleColor = isDark ? Colors.white : Colors.black;
    final userTextColor = isDark ? Colors.black : Colors.white;
    final botTextColor = Colors.white;
    final adminTextColor =
    isDark ? Colors.white : const Color(0xFF102A43);
    final systemTextColor =
    isDark ? Colors.white : const Color(0xFF5B2C6F);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final softPanelColor =
    isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7D7E7);
    final primaryText = isDark ? Colors.white : Colors.black;
    final secondaryText = isDark ? Colors.white70 : Colors.black54;
    final borderColor =
    isDark ? const Color(0xFF3A3A3A) : const Color(0xFFC2187A);

    if (!_checkedExistingConversation) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: primaryText,
        titleSpacing: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: Center(child: _leadingAvatar()),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pageTitle(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _pageSubtitle(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedLang != null)
            TextButton.icon(
              onPressed: _startNewChatFromBeginning,
              icon: const Icon(Icons.add_comment_outlined),
              label: Text(_strings.startNewChat),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (_controller.isStartingChat)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  (_showMainCategoryOptions ||
                      _showSubIssueOptions ||
                      _showOrderOptions)
                      ? 20
                      : 12,
                ),
                children: [
                  for (int index = 0;
                  index < _controller.messages.length;
                  index++)
                    Builder(
                      builder: (context) {
                        final message = _controller.messages[index];
                        final isUser = _isUserMessage(message);
                        final isAdmin = message.senderType == SenderType.admin;
                        final isSystem = message.senderType == SenderType.system;

                        if (message.messageType == MessageType.orderCard) {
                          return StreamBuilder<List<SupportOrderItemModel>>(
                            stream: _repository.streamUserOrders(
                              FirebaseAuth.instance.currentUser!.uid,
                            ),
                            builder: (context, snapshot) {
                              final orders = snapshot.data ?? [];
                              final matched = orders
                                  .where((e) => e.id == message.relatedOrderId)
                                  .toList();

                              if (matched.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final order = matched.first;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: _OrderSummaryCard(
                                    order: order,
                                    isDark: isDark,
                                    borderColor: borderColor,
                                    textColor: primaryText,
                                    subTextColor: secondaryText,
                                    strings: _strings,
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        final bubbleColor = isUser
                            ? userBubbleColor
                            : isAdmin
                            ? adminBubbleColor
                            : isSystem
                            ? systemBubbleColor
                            : botBubbleColor;

                        final bubbleTextColor = isUser
                            ? userTextColor
                            : isAdmin
                            ? adminTextColor
                            : isSystem
                            ? systemTextColor
                            : botTextColor;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isUser) ...[
                                  if (isAdmin)
                                    _CircleAvatarWidget(
                                      imageUrl: _controller
                                          .conversation?.assignedAdminPhoto ??
                                          '',
                                      name: _controller
                                          .conversation?.assignedAdminName ??
                                          'A',
                                      backgroundColor:
                                      const Color(0xFFE8F1FF),
                                      icon: Icons.person,
                                      iconColor: const Color(0xFF2D6CDF),
                                    )
                                  else
                                    const _CircleAvatarWidget(
                                      imageUrl: '',
                                      name: 'Bot',
                                      backgroundColor: Color(0xFFF7D7E7),
                                      icon: Icons.support_agent,
                                      iconColor: Color(0xFFC2187A),
                                    ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.68,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bubbleColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        bottomLeft:
                                        Radius.circular(isUser ? 18 : 6),
                                        bottomRight:
                                        Radius.circular(isUser ? 6 : 18),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        if (!isUser)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              message.senderName,
                                              style: TextStyle(
                                                color: bubbleTextColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          message.text,
                                          textDirection: _isArabicSelected
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                          style: TextStyle(
                                            color: bubbleTextColor,
                                            fontSize: 15,
                                            height: 1.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isUser) ...[
                                  const SizedBox(width: 8),
                                  _CircleAvatarWidget(
                                    imageUrl:
                                    _controller.conversation?.userPhoto ?? '',
                                    name:
                                    _controller.conversation?.userName ?? '',
                                    backgroundColor: Colors.grey.shade300,
                                    icon: Icons.person,
                                    iconColor: Colors.black54,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  if (_controller.conversation?.adminTyping == true &&
                      (_controller.conversation?.assignedAdminName ?? '')
                          .isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          _CircleAvatarWidget(
                            imageUrl:
                            _controller.conversation?.assignedAdminPhoto ??
                                '',
                            name:
                            _controller.conversation?.assignedAdminName ??
                                '',
                            backgroundColor: const Color(0xFFE8F1FF),
                            icon: Icons.person,
                            iconColor: const Color(0xFF2D6CDF),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF253144)
                                  : const Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              _selectedLang == SupportLang.ar
                                  ? '${_controller.conversation?.adminTypingName.isNotEmpty == true ? _controller.conversation!.adminTypingName : _controller.conversation!.assignedAdminName} يكتب الآن...'
                                  : '${_controller.conversation?.adminTypingName.isNotEmpty == true ? _controller.conversation!.adminTypingName : _controller.conversation!.assignedAdminName} is typing...',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF102A43),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_shouldShowStartNewChatButton()) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 360),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: botBubbleColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _strings.newChatHintMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _startNewChatFromBeginning,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC2187A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.add_comment_outlined),
                            label: Text(_strings.startNewChat),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            if (_selectedLang == null)
              _LanguagePickerPanel(
                title: SupportChatStrings.english().chooseLanguageTitle,
                cardColor: cardColor,
                onEnglish: () => _startChatWithLanguage(SupportLang.en),
                onArabic: () => _startChatWithLanguage(SupportLang.ar),
              ),
            if (_selectedLang != null && _showMainCategoryOptions)
              _MainCategoryPanel(
                cardColor: cardColor,
                title: _strings.mainTitle,
                categories: [
                  _MainCategoryItem(
                    category: MainIssueCategory.orderIssues,
                    label: _strings.mainOrderIssues,
                  ),
                  _MainCategoryItem(
                    category: MainIssueCategory.itemQuality,
                    label: _strings.mainItemQuality,
                  ),
                  _MainCategoryItem(
                    category: MainIssueCategory.paymentIssues,
                    label: _strings.mainPaymentIssues,
                  ),
                  _MainCategoryItem(
                    category: MainIssueCategory.technicalAssistance,
                    label: _strings.mainTechnicalAssistance,
                  ),
                  _MainCategoryItem(
                    category: MainIssueCategory.other,
                    label: _strings.mainOther,
                  ),
                ],
                onTap: _onChooseMainCategory,
              ),
            if (_selectedLang != null && _showSubIssueOptions)
              _SubIssuePanel(
                cardColor: cardColor,
                title: _strings.subIssueTitle,
                issues: _currentSubIssues,
                onTap: _onChooseSubIssue,
              ),
            if (_selectedLang != null && _showOrderOptions)
              _OrderOptionsPanel(
                repository: _repository,
                userId: FirebaseAuth.instance.currentUser!.uid,
                cardColor: cardColor,
                secondaryText: secondaryText,
                borderColor: borderColor,
                textColor: primaryText,
                subTextColor: secondaryText,
                strings: _strings,
                filterOrders: _filterOrders,
                onSelectOrder: _onSelectOrder,
              ),
            if (_selectedLang != null &&
                !_showMainCategoryOptions &&
                !_showSubIssueOptions &&
                !_showOrderOptions)
              _BottomInputPanel(
                softPanelColor: softPanelColor,
                cardColor: cardColor,
                hintText: _strings.writeMessageHint,
                secondaryText: secondaryText,
                controller: _messageController,
                onChanged: _onUserTypingChanged,
                onSend: _sendFreeTextMessage,
                isArabic: _isArabicSelected,
              ),
          ],
        ),
      ),
    );
  }
}

class _MainCategoryItem {
  final MainIssueCategory category;
  final String label;

  const _MainCategoryItem({
    required this.category,
    required this.label,
  });
}

class _LanguagePickerPanel extends StatelessWidget {
  final String title;
  final Color cardColor;
  final VoidCallback onEnglish;
  final VoidCallback onArabic;

  const _LanguagePickerPanel({
    required this.title,
    required this.cardColor,
    required this.onEnglish,
    required this.onArabic,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEnglish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2187A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('English'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onArabic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2187A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('العربية'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MainCategoryPanel extends StatelessWidget {
  final Color cardColor;
  final String title;
  final List<_MainCategoryItem> categories;
  final Future<void> Function(MainIssueCategory category) onTap;

  const _MainCategoryPanel({
    required this.cardColor,
    required this.title,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 320),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories
                    .map(
                      (item) => _QuickReplyChip(
                    label: item.label,
                    onTap: () => onTap(item.category),
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubIssuePanel extends StatelessWidget {
  final Color cardColor;
  final String title;
  final List<SupportSubIssueOption> issues;
  final Future<void> Function(SupportSubIssueOption option) onTap;

  const _SubIssuePanel({
    required this.cardColor,
    required this.title,
    required this.issues,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 280),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: issues
                    .map(
                      (issue) => _QuickReplyChip(
                    label: issue.label,
                    onTap: () => onTap(issue),
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderOptionsPanel extends StatelessWidget {
  final SupportRepository repository;
  final String userId;
  final Color cardColor;
  final Color secondaryText;
  final Color borderColor;
  final Color textColor;
  final Color subTextColor;
  final SupportChatStrings strings;
  final List<SupportOrderItemModel> Function(List<SupportOrderItemModel>)
  filterOrders;
  final Future<void> Function(SupportOrderItemModel order) onSelectOrder;

  const _OrderOptionsPanel({
    required this.repository,
    required this.userId,
    required this.cardColor,
    required this.secondaryText,
    required this.borderColor,
    required this.textColor,
    required this.subTextColor,
    required this.strings,
    required this.filterOrders,
    required this.onSelectOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 340),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: StreamBuilder<List<SupportOrderItemModel>>(
          stream: repository.streamUserOrders(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data ?? [];
            final filteredOrders = filterOrders(orders);

            if (filteredOrders.isEmpty) {
              return Center(
                child: Text(
                  strings.noMatchingOrders,
                  style: TextStyle(color: secondaryText),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: filteredOrders
                    .map(
                      (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => onSelectOrder(order),
                      child: _SelectableOrderCard(
                        order: order,
                        isDark: isDark,
                        borderColor: borderColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        strings: strings,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BottomInputPanel extends StatelessWidget {
  final Color softPanelColor;
  final Color cardColor;
  final String hintText;
  final Color secondaryText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onSend;
  final bool isArabic;

  const _BottomInputPanel({
    required this.softPanelColor,
    required this.cardColor,
    required this.hintText,
    required this.secondaryText,
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          12 + MediaQuery.of(context).viewPadding.bottom,
        ),
        color: softPanelColor,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintTextDirection:
                    isArabic ? TextDirection.rtl : TextDirection.ltr,
                    hintStyle: TextStyle(
                      color: secondaryText,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onSend,
              child: const _BottomIconButton(icon: Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomIconButton extends StatelessWidget {
  final IconData icon;

  const _BottomIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFC2187A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickReplyChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFC2187A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: pink),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: pink,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final String name;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  const _CircleAvatarWidget({
    required this.imageUrl,
    required this.name,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter =
    name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'A';

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Text(
              firstLetter,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      )
          : Center(
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final SupportOrderItemModel order;
  final bool isDark;
  final Color borderColor;
  final Color textColor;
  final Color subTextColor;
  final SupportChatStrings strings;

  const _OrderSummaryCard({
    required this.order,
    required this.isDark,
    required this.borderColor,
    required this.textColor,
    required this.subTextColor,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: subTextColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${strings.orderLabel} ${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.itemCount} ${strings.itemsLabel}',
                  style: TextStyle(
                    fontSize: 13,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order.orderStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableOrderCard extends StatelessWidget {
  final SupportOrderItemModel order;
  final bool isDark;
  final Color borderColor;
  final Color textColor;
  final Color subTextColor;
  final SupportChatStrings strings;

  const _SelectableOrderCard({
    required this.order,
    required this.isDark,
    required this.borderColor,
    required this.textColor,
    required this.subTextColor,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: subTextColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${strings.orderLabel} ${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.itemCount} ${strings.itemsLabel}',
                  style: TextStyle(
                    fontSize: 13,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order.orderStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFC2187A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              strings.selectLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}