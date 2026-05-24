class SupportChatStrings {
  final String languageName;
  final String title;
  final String subtitle;
  final String chooseLanguageTitle;
  final String botName;
  final String systemName;
  final String welcomeMessage;

  final String mainTitle;
  final String subIssueTitle;

  final String mainOrderIssues;
  final String mainItemQuality;
  final String mainPaymentIssues;
  final String mainTechnicalAssistance;
  final String mainOther;

  final String issueNotReceived;
  final String issueCancelOrder;
  final String issueReturnOrder;
  final String issueDamaged;

  final String selectOrderMessage;
  final String writeMessageHint;

  final String orderLabel;
  final String itemsLabel;
  final String selectLabel;

  final String noMatchingOrders;

  final String chooseOrderIssueTypeMessage;
  final String chooseItemQualityIssueTypeMessage;

  final String transferToPaymentSupport;
  final String transferToTechnicalSupport;
  final String transferToSupportAgent;
  final String transferredToSupportAgentSystemMessage;

  final String checkingOrderNow;
  final String orderPendingOrProcessingReply;
  final String orderShippedDelayedReply;
  final String orderCancelledReply;
  final String orderDeliveredTransferReply;

  final String cancelPossibleReply;
  final String cancelNotPossibleReply;

  final String returnNeedsAgentReply;
  final String damagedNeedsAgentReply;

  final String startNewChat;
  final String newChatHintMessage;

  const SupportChatStrings({
    required this.languageName,
    required this.title,
    required this.subtitle,
    required this.chooseLanguageTitle,
    required this.botName,
    required this.systemName,
    required this.welcomeMessage,
    required this.mainTitle,
    required this.subIssueTitle,
    required this.mainOrderIssues,
    required this.mainItemQuality,
    required this.mainPaymentIssues,
    required this.mainTechnicalAssistance,
    required this.mainOther,
    required this.issueNotReceived,
    required this.issueCancelOrder,
    required this.issueReturnOrder,
    required this.issueDamaged,
    required this.selectOrderMessage,
    required this.writeMessageHint,
    required this.orderLabel,
    required this.itemsLabel,
    required this.selectLabel,
    required this.noMatchingOrders,
    required this.chooseOrderIssueTypeMessage,
    required this.chooseItemQualityIssueTypeMessage,
    required this.transferToPaymentSupport,
    required this.transferToTechnicalSupport,
    required this.transferToSupportAgent,
    required this.transferredToSupportAgentSystemMessage,
    required this.checkingOrderNow,
    required this.orderPendingOrProcessingReply,
    required this.orderShippedDelayedReply,
    required this.orderCancelledReply,
    required this.orderDeliveredTransferReply,
    required this.cancelPossibleReply,
    required this.cancelNotPossibleReply,
    required this.returnNeedsAgentReply,
    required this.damagedNeedsAgentReply,
    required this.startNewChat,
    required this.newChatHintMessage,
  });

  factory SupportChatStrings.english() {
    return const SupportChatStrings(
      languageName: 'English',
      title: 'Customer Service',
      subtitle: 'Support Chat',
      chooseLanguageTitle: 'Choose chat language',
      botName: 'Customer Service',
      systemName: 'System',
      welcomeMessage:
      'Hello! Welcome to Customer Service. We will be happy to help you. Please provide more details about your issue before we can start.',
      mainTitle: "What's your issue?",
      subIssueTitle: 'Choose the issue type',
      mainOrderIssues: 'Order Issues',
      mainItemQuality: 'Item Quality',
      mainPaymentIssues: 'Payment Issues',
      mainTechnicalAssistance: 'Technical Assistance',
      mainOther: 'Other',
      issueNotReceived: "I didn't receive my parcel",
      issueCancelOrder: 'I want to cancel my order',
      issueReturnOrder: 'I want to return my order',
      issueDamaged: 'Package was damaged',
      selectOrderMessage: 'Please select the order related to your issue.',
      writeMessageHint: 'Message',
      orderLabel: 'Order',
      itemsLabel: 'items',
      selectLabel: 'Select',
      noMatchingOrders: 'No matching orders found for this issue',
      chooseOrderIssueTypeMessage: 'Please choose the order issue type.',
      chooseItemQualityIssueTypeMessage:
      'Please choose the item quality issue type.',
      transferToPaymentSupport:
      'You will now be transferred to a support agent for payment support.',
      transferToTechnicalSupport:
      'You will now be transferred to technical support.',
      transferToSupportAgent:
      'You will now be transferred to a support agent.',
      transferredToSupportAgentSystemMessage:
      'Your conversation has been transferred to a support agent.',
      checkingOrderNow: 'Thank you. Checking your order now.',
      orderPendingOrProcessingReply:
      'Your order is still pending or being processed, and it should be shipped soon.',
      orderShippedDelayedReply:
      'I checked your order, and it seems there is a slight delay. You should receive it within 2 days.',
      orderCancelledReply:
      'This order has already been cancelled. I will transfer your chat to a support agent if you need more help.',
      orderDeliveredTransferReply:
      'Our system shows this order as delivered. I will now transfer your chat to a support agent for further help.',
      cancelPossibleReply:
      'This order can be cancelled automatically right now, and we will cancel it immediately.',
      cancelNotPossibleReply:
      'This order cannot be cancelled automatically right now. I will transfer your chat to a support agent.',
      returnNeedsAgentReply:
      'Thank you. This case needs review by a support agent. Transferring your chat now.',
      damagedNeedsAgentReply:
      'Thank you. This case needs review by a support agent. Transferring your chat now.',
      startNewChat: 'Start New Chat',
      newChatHintMessage:
      'If you have a new issue, tap "Start New Chat" to begin a new support conversation.',
    );
  }

  factory SupportChatStrings.arabic() {
    return const SupportChatStrings(
      languageName: 'العربية',
      title: 'خدمة العملاء',
      subtitle: 'الدعم الفني',
      chooseLanguageTitle: 'اختر لغة المحادثة',
      botName: 'خدمة العملاء',
      systemName: 'النظام',
      welcomeMessage:
      'مرحبًا! أهلًا بك في خدمة العملاء. يسعدنا مساعدتك. من فضلك اختر نوع المشكلة قبل أن نبدأ.',
      mainTitle: 'ما هي مشكلتك؟',
      subIssueTitle: 'اختر نوع المشكلة',
      mainOrderIssues: 'مشاكل الطلبات',
      mainItemQuality: 'جودة المنتج',
      mainPaymentIssues: 'مشاكل الدفع',
      mainTechnicalAssistance: 'الدعم الفني',
      mainOther: 'أخرى',
      issueNotReceived: 'لم أستلم طلبي',
      issueCancelOrder: 'أريد إلغاء الطلب',
      issueReturnOrder: 'أريد إرجاع الطلب',
      issueDamaged: 'الطلب تالف',
      selectOrderMessage: 'من فضلك اختر الطلب المرتبط بالمشكلة.',
      writeMessageHint: 'اكتب رسالة',
      orderLabel: 'الطلب',
      itemsLabel: 'منتج',
      selectLabel: 'اختيار',
      noMatchingOrders: 'لا توجد طلبات مناسبة لهذه المشكلة',
      chooseOrderIssueTypeMessage: 'من فضلك اختر نوع المشكلة الخاصة بالطلب.',
      chooseItemQualityIssueTypeMessage:
      'من فضلك اختر نوع المشكلة الخاصة بجودة المنتج.',
      transferToPaymentSupport:
      'سيتم تحويلك الآن إلى أحد موظفي خدمة العملاء لمساعدتك في مشكلة الدفع.',
      transferToTechnicalSupport:
      'سيتم تحويلك الآن إلى أحد موظفي الدعم الفني.',
      transferToSupportAgent:
      'سيتم تحويلك الآن إلى أحد موظفي خدمة العملاء.',
      transferredToSupportAgentSystemMessage:
      'تم تحويل المحادثة إلى أحد موظفي خدمة العملاء.',
      checkingOrderNow: 'شكرًا لك. جارٍ فحص الطلب الآن.',
      orderPendingOrProcessingReply:
      'طلبك ما زال قيد التجهيز أو الانتظار، ومن المتوقع أن يتم شحنه قريبًا.',
      orderShippedDelayedReply:
      'تحققنا من الطلب، ويبدو أن هناك تأخيرًا بسيطًا. من المتوقع أن يصلك خلال يومين.',
      orderCancelledReply:
      'هذا الطلب تم إلغاؤه بالفعل. سأحوّل المحادثة الآن إلى أحد موظفي خدمة العملاء إذا كنت تحتاج مساعدة إضافية.',
      orderDeliveredTransferReply:
      'الحالة عندنا تظهر أن الطلب تم توصيله. سنحوّل المحادثة الآن إلى أحد موظفي خدمة العملاء لمساعدتك بشكل أفضل.',
      cancelPossibleReply:
      'يمكن إلغاء هذا الطلب تلقائيًا الآن، وسنقوم بإلغائه مباشرة.',
      cancelNotPossibleReply:
      'لا يمكن إلغاء هذا الطلب تلقائيًا الآن. سنحوّل المحادثة إلى موظف خدمة العملاء.',
      returnNeedsAgentReply:
      'شكرًا لك. هذه الحالة تحتاج مراجعة من أحد موظفي خدمة العملاء. سنحوّل المحادثة الآن.',
      damagedNeedsAgentReply:
      'شكرًا لك. هذه الحالة تحتاج مراجعة من أحد موظفي خدمة العملاء. سنحوّل المحادثة الآن.',
      startNewChat: 'بدء محادثة جديدة',
      newChatHintMessage:
      'إذا كانت لديك مشكلة جديدة، اضغط على زر "بدء محادثة جديدة" لبدء محادثة دعم جديدة.',
    );
  }
}