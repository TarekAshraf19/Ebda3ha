class AppNotification {
  final String id;
  final String title;
  final String body;
  final String userId;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.isRead,
  });

  factory AppNotification.fromDoc(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      title: (data['title'] ?? '').toString(),
      body: (data['body'] ?? '').toString(),
      userId: (data['userId'] ?? '').toString(),
      isRead: (data['isRead'] ?? false) == true,
    );
  }
}