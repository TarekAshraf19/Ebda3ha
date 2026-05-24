import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/enums/support_enums.dart';

class SupportConversationModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userPhoto;

  final ConversationStatus status;
  final IssueType issueType;
  final String issueTitle;

  final String orderId;
  final String orderNumber;
  final String orderStatus;

  final bool botEnabled;
  final bool isAssignedToAdmin;
  final String assignedAdminId;
  final String assignedAdminName;
  final String assignedAdminPhoto;

  final bool adminTyping;
  final String adminTypingName;

  final bool userTyping;
  final String userTypingName;

  final String priority;
  final String source;

  final String lastMessage;
  final String lastMessageSenderType;

  final DateTime? lastMessageAt;
  final int unreadCountUser;
  final int unreadCountAdmin;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  const SupportConversationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userPhoto,
    required this.status,
    required this.issueType,
    required this.issueTitle,
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.botEnabled,
    required this.isAssignedToAdmin,
    required this.assignedAdminId,
    required this.assignedAdminName,
    required this.assignedAdminPhoto,
    required this.adminTyping,
    required this.adminTypingName,
    required this.userTyping,
    required this.userTypingName,
    required this.priority,
    required this.source,
    required this.lastMessage,
    required this.lastMessageSenderType,
    required this.lastMessageAt,
    required this.unreadCountUser,
    required this.unreadCountAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.resolvedAt,
    required this.closedAt,
  });

  factory SupportConversationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? <String, dynamic>{};

    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return SupportConversationModel(
      id: doc.id,
      userId: (data['userId'] ?? '').toString(),
      userName: (data['userName'] ?? '').toString(),
      userEmail: (data['userEmail'] ?? '').toString(),
      userPhone: (data['userPhone'] ?? '').toString(),
      userPhoto: (data['userPhoto'] ?? data['photoUrl'] ?? '').toString(),
      status: ConversationStatusX.fromString(data['status']?.toString()),
      issueType: IssueTypeX.fromString(data['issueType']?.toString()),
      issueTitle: (data['issueTitle'] ?? '').toString(),
      orderId: (data['orderId'] ?? '').toString(),
      orderNumber: (data['orderNumber'] ?? '').toString(),
      orderStatus: (data['orderStatus'] ?? '').toString(),
      botEnabled: data['botEnabled'] == true,
      isAssignedToAdmin: data['isAssignedToAdmin'] == true,
      assignedAdminId: (data['assignedAdminId'] ?? '').toString(),
      assignedAdminName: (data['assignedAdminName'] ?? '').toString(),
      assignedAdminPhoto:
      (data['assignedAdminPhoto'] ?? data['assignedAdminAvatar'] ?? '')
          .toString(),
      adminTyping: data['adminTyping'] == true,
      adminTypingName: (data['adminTypingName'] ?? '').toString(),
      userTyping: data['userTyping'] == true,
      userTypingName: (data['userTypingName'] ?? '').toString(),
      priority: (data['priority'] ?? '').toString(),
      source: (data['source'] ?? '').toString(),
      lastMessage: (data['lastMessage'] ?? '').toString(),
      lastMessageSenderType: (data['lastMessageSenderType'] ?? '').toString(),
      lastMessageAt: parseTimestamp(data['lastMessageAt']),
      unreadCountUser: (data['unreadCountUser'] ?? 0) as int,
      unreadCountAdmin: (data['unreadCountAdmin'] ?? 0) as int,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
      resolvedAt: parseTimestamp(data['resolvedAt']),
      closedAt: parseTimestamp(data['closedAt']),
    );
  }
}