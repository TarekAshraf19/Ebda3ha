import '../../domain/enums/support_enums.dart';
import '../../presentation/strings/support_chat_strings.dart';

class SupportSubIssueOption {
  final IssueType issueType;
  final String label;

  const SupportSubIssueOption({
    required this.issueType,
    required this.label,
  });
}

class MainCategoryFlowResult {
  final List<String> botMessages;
  final bool showSubIssues;
  final bool transferToAdmin;
  final String? systemMessage;
  final List<SupportSubIssueOption> subIssues;

  const MainCategoryFlowResult({
    required this.botMessages,
    required this.showSubIssues,
    required this.transferToAdmin,
    required this.systemMessage,
    required this.subIssues,
  });
}

class OrderFlowResult {
  final List<String> botMessages;
  final bool transferToAdmin;
  final String? systemMessage;
  final bool shouldAutoCancel;

  const OrderFlowResult({
    required this.botMessages,
    required this.transferToAdmin,
    required this.systemMessage,
    required this.shouldAutoCancel,
  });
}

class SupportBotFlowService {
  const SupportBotFlowService();

  MainCategoryFlowResult handleMainCategorySelection({
    required MainIssueCategory category,
    required SupportChatStrings strings,
  }) {
    if (category == MainIssueCategory.orderIssues) {
      return MainCategoryFlowResult(
        botMessages: [strings.chooseOrderIssueTypeMessage],
        showSubIssues: true,
        transferToAdmin: false,
        systemMessage: null,
        subIssues: [
          SupportSubIssueOption(
            issueType: IssueType.orderNotReceived,
            label: strings.issueNotReceived,
          ),
          SupportSubIssueOption(
            issueType: IssueType.cancelOrder,
            label: strings.issueCancelOrder,
          ),
          SupportSubIssueOption(
            issueType: IssueType.returnOrder,
            label: strings.issueReturnOrder,
          ),
        ],
      );
    }

    if (category == MainIssueCategory.itemQuality) {
      return MainCategoryFlowResult(
        botMessages: [strings.chooseItemQualityIssueTypeMessage],
        showSubIssues: true,
        transferToAdmin: false,
        systemMessage: null,
        subIssues: [
          SupportSubIssueOption(
            issueType: IssueType.damagedPackage,
            label: strings.issueDamaged,
          ),
        ],
      );
    }

    if (category == MainIssueCategory.paymentIssues) {
      return MainCategoryFlowResult(
        botMessages: [strings.transferToPaymentSupport],
        showSubIssues: false,
        transferToAdmin: true,
        systemMessage: strings.transferredToSupportAgentSystemMessage,
        subIssues: const [],
      );
    }

    if (category == MainIssueCategory.technicalAssistance) {
      return MainCategoryFlowResult(
        botMessages: [strings.transferToTechnicalSupport],
        showSubIssues: false,
        transferToAdmin: true,
        systemMessage: strings.transferredToSupportAgentSystemMessage,
        subIssues: const [],
      );
    }

    return MainCategoryFlowResult(
      botMessages: [strings.transferToSupportAgent],
      showSubIssues: false,
      transferToAdmin: true,
      systemMessage: strings.transferredToSupportAgentSystemMessage,
      subIssues: const [],
    );
  }

  OrderFlowResult handleOrderSelection({
    required IssueType issueType,
    required String orderStatus,
    required bool canAutoCancel,
    required SupportChatStrings strings,
  }) {
    final status = orderStatus.toLowerCase();

    if (issueType == IssueType.orderNotReceived) {
      if (status == 'pending' || status == 'processing') {
        return OrderFlowResult(
          botMessages: [
            strings.checkingOrderNow,
            strings.orderPendingOrProcessingReply,
          ],
          transferToAdmin: false,
          systemMessage: null,
          shouldAutoCancel: false,
        );
      }

      if (status == 'shipped') {
        return OrderFlowResult(
          botMessages: [
            strings.checkingOrderNow,
            strings.orderShippedDelayedReply,
          ],
          transferToAdmin: false,
          systemMessage: null,
          shouldAutoCancel: false,
        );
      }

      if (status == 'cancelled') {
        return OrderFlowResult(
          botMessages: [
            strings.checkingOrderNow,
            strings.orderCancelledReply,
          ],
          transferToAdmin: true,
          systemMessage: strings.transferredToSupportAgentSystemMessage,
          shouldAutoCancel: false,
        );
      }

      return OrderFlowResult(
        botMessages: [
          strings.checkingOrderNow,
          strings.orderDeliveredTransferReply,
        ],
        transferToAdmin: true,
        systemMessage: strings.transferredToSupportAgentSystemMessage,
        shouldAutoCancel: false,
      );
    }

    if (issueType == IssueType.cancelOrder) {
      if ((status == 'pending' || status == 'processing') && canAutoCancel) {
        return OrderFlowResult(
          botMessages: [
            strings.checkingOrderNow,
            strings.cancelPossibleReply,
          ],
          transferToAdmin: false,
          systemMessage: null,
          shouldAutoCancel: true,
        );
      }

      return OrderFlowResult(
        botMessages: [
          strings.checkingOrderNow,
          strings.cancelNotPossibleReply,
        ],
        transferToAdmin: true,
        systemMessage: strings.transferredToSupportAgentSystemMessage,
        shouldAutoCancel: false,
      );
    }

    if (issueType == IssueType.returnOrder) {
      return OrderFlowResult(
        botMessages: [strings.returnNeedsAgentReply],
        transferToAdmin: true,
        systemMessage: strings.transferredToSupportAgentSystemMessage,
        shouldAutoCancel: false,
      );
    }

    if (issueType == IssueType.damagedPackage) {
      return OrderFlowResult(
        botMessages: [strings.damagedNeedsAgentReply],
        transferToAdmin: true,
        systemMessage: strings.transferredToSupportAgentSystemMessage,
        shouldAutoCancel: false,
      );
    }

    return OrderFlowResult(
      botMessages: [strings.transferToSupportAgent],
      transferToAdmin: true,
      systemMessage: strings.transferredToSupportAgentSystemMessage,
      shouldAutoCancel: false,
    );
  }
}