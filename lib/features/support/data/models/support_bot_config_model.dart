import 'package:cloud_firestore/cloud_firestore.dart';

class SupportBotConfigModel {
  final bool enabled;
  final bool allowHumanHandoff;
  final String defaultAgentName;
  final String welcomeMessage;
  final DateTime? updatedAt;

  const SupportBotConfigModel({
    required this.enabled,
    required this.allowHumanHandoff,
    required this.defaultAgentName,
    required this.welcomeMessage,
    required this.updatedAt,
  });

  factory SupportBotConfigModel.empty() {
    return const SupportBotConfigModel(
      enabled: true,
      allowHumanHandoff: true,
      defaultAgentName: 'Customer Service AI',
      welcomeMessage:
      'Hello! Welcome to Customer Care Service. We will be happy to help you. Please provide us more details about your issue before we can start.',
      updatedAt: null,
    );
  }

  SupportBotConfigModel copyWith({
    bool? enabled,
    bool? allowHumanHandoff,
    String? defaultAgentName,
    String? welcomeMessage,
    DateTime? updatedAt,
  }) {
    return SupportBotConfigModel(
      enabled: enabled ?? this.enabled,
      allowHumanHandoff: allowHumanHandoff ?? this.allowHumanHandoff,
      defaultAgentName: defaultAgentName ?? this.defaultAgentName,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SupportBotConfigModel.fromMap(Map<String, dynamic> data) {
    return SupportBotConfigModel(
      enabled: data['enabled'] as bool? ?? true,
      allowHumanHandoff: data['allowHumanHandoff'] as bool? ?? true,
      defaultAgentName: data['defaultAgentName'] as String? ?? 'Tarek Ashraf',
      welcomeMessage: data['welcomeMessage'] as String? ?? '',
      updatedAt: _dateTimeFromTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'allowHumanHandoff': allowHumanHandoff,
      'defaultAgentName': defaultAgentName,
      'welcomeMessage': welcomeMessage,
      'updatedAt': _timestampFromDateTime(updatedAt),
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