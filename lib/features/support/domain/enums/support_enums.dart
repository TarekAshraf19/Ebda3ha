enum ConversationStatus {
  botActive,
  waitingAdmin,
  humanJoined,
  resolved,
  closed,
}

enum SenderType {
  user,
  bot,
  admin,
  system,
}

enum MessageType {
  text,
  quickReply,
  orderCard,
  voucher,
  system,
}

enum IssueType {
  orderNotReceived,
  cancelOrder,
  returnOrder,
  damagedPackage,
  paymentIssue,
  technicalAssistance,
  other,
  unknown,
}

enum MainIssueCategory {
  orderIssues,
  itemQuality,
  paymentIssues,
  technicalAssistance,
  other,
}

extension ConversationStatusX on ConversationStatus {
  String get value {
    switch (this) {
      case ConversationStatus.botActive:
        return 'bot_active';
      case ConversationStatus.waitingAdmin:
        return 'waiting_admin';
      case ConversationStatus.humanJoined:
        return 'human_joined';
      case ConversationStatus.resolved:
        return 'resolved';
      case ConversationStatus.closed:
        return 'closed';
    }
  }

  static ConversationStatus fromString(String? value) {
    switch (value) {
      case 'bot_active':
        return ConversationStatus.botActive;
      case 'waiting_admin':
        return ConversationStatus.waitingAdmin;
      case 'human_joined':
        return ConversationStatus.humanJoined;
      case 'resolved':
        return ConversationStatus.resolved;
      case 'closed':
        return ConversationStatus.closed;
      default:
        return ConversationStatus.botActive;
    }
  }
}

extension SenderTypeX on SenderType {
  String get value {
    switch (this) {
      case SenderType.user:
        return 'user';
      case SenderType.bot:
        return 'bot';
      case SenderType.admin:
        return 'admin';
      case SenderType.system:
        return 'system';
    }
  }

  static SenderType fromString(String? value) {
    switch (value) {
      case 'user':
        return SenderType.user;
      case 'bot':
        return SenderType.bot;
      case 'admin':
        return SenderType.admin;
      case 'system':
        return SenderType.system;
      default:
        return SenderType.system;
    }
  }
}

extension MessageTypeX on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.quickReply:
        return 'quick_reply';
      case MessageType.orderCard:
        return 'order_card';
      case MessageType.voucher:
        return 'voucher';
      case MessageType.system:
        return 'system';
    }
  }

  static MessageType fromString(String? value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      case 'quick_reply':
        return MessageType.quickReply;
      case 'order_card':
        return MessageType.orderCard;
      case 'voucher':
        return MessageType.voucher;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

extension IssueTypeX on IssueType {
  String get value {
    switch (this) {
      case IssueType.orderNotReceived:
        return 'order_not_received';
      case IssueType.cancelOrder:
        return 'cancel_order';
      case IssueType.returnOrder:
        return 'return_order';
      case IssueType.damagedPackage:
        return 'damaged_package';
      case IssueType.paymentIssue:
        return 'payment_issue';
      case IssueType.technicalAssistance:
        return 'technical_assistance';
      case IssueType.other:
        return 'other';
      case IssueType.unknown:
        return '';
    }
  }

  static IssueType fromString(String? value) {
    switch (value) {
      case 'order_not_received':
        return IssueType.orderNotReceived;
      case 'cancel_order':
        return IssueType.cancelOrder;
      case 'return_order':
        return IssueType.returnOrder;
      case 'damaged_package':
        return IssueType.damagedPackage;
      case 'payment_issue':
        return IssueType.paymentIssue;
      case 'technical_assistance':
        return IssueType.technicalAssistance;
      case 'other':
        return IssueType.other;
      default:
        return IssueType.unknown;
    }
  }
}

extension MainIssueCategoryX on MainIssueCategory {
  String get value {
    switch (this) {
      case MainIssueCategory.orderIssues:
        return 'order_issues';
      case MainIssueCategory.itemQuality:
        return 'item_quality';
      case MainIssueCategory.paymentIssues:
        return 'payment_issues';
      case MainIssueCategory.technicalAssistance:
        return 'technical_assistance';
      case MainIssueCategory.other:
        return 'other';
    }
  }
}