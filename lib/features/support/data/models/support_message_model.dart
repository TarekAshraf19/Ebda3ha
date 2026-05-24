import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/enums/support_enums.dart';

class SupportMessageModel {
  final String id;
  final SenderType senderType;
  final String senderId;
  final String senderName;
  final MessageType messageType;
  final String text;
  final String quickReplyValue;
  final String quickReplyLabel;
  final String relatedOrderId;
  final DateTime? createdAt;

  const SupportMessageModel({
    required this.id,
    required this.senderType,
    required this.senderId,
    required this.senderName,
    required this.messageType,
    required this.text,
    required this.quickReplyValue,
    required this.quickReplyLabel,
    required this.relatedOrderId,
    required this.createdAt,
  });

  factory SupportMessageModel.empty() {
    return const SupportMessageModel(
      id: '',
      senderType: SenderType.system,
      senderId: '',
      senderName: '',
      messageType: MessageType.text,
      text: '',
      quickReplyValue: '',
      quickReplyLabel: '',
      relatedOrderId: '',
      createdAt: null,
    );
  }

  SupportMessageModel copyWith({
    String? id,
    SenderType? senderType,
    String? senderId,
    String? senderName,
    MessageType? messageType,
    String? text,
    String? quickReplyValue,
    String? quickReplyLabel,
    String? relatedOrderId,
    DateTime? createdAt,
  }) {
    return SupportMessageModel(
      id: id ?? this.id,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      messageType: messageType ?? this.messageType,
      text: text ?? this.text,
      quickReplyValue: quickReplyValue ?? this.quickReplyValue,
      quickReplyLabel: quickReplyLabel ?? this.quickReplyLabel,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SupportMessageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? <String, dynamic>{};

    return SupportMessageModel(
      id: doc.id,
      senderType: SenderTypeX.fromString(data['senderType'] as String?),
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      messageType: MessageTypeX.fromString(data['messageType'] as String?),
      text: data['text'] as String? ?? '',
      quickReplyValue: data['quickReplyValue'] as String? ?? '',
      quickReplyLabel: data['quickReplyLabel'] as String? ?? '',
      relatedOrderId: data['relatedOrderId'] as String? ?? '',
      createdAt: _dateTimeFromTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderType': senderType.value,
      'senderId': senderId,
      'senderName': senderName,
      'messageType': messageType.value,
      'text': text,
      'quickReplyValue': quickReplyValue,
      'quickReplyLabel': quickReplyLabel,
      'relatedOrderId': relatedOrderId,
      'createdAt': _timestampFromDateTime(createdAt),
    };
  }

  static DateTime? _dateTimeFromTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }

  static Timestamp? _timestampFromDateTime(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }
}