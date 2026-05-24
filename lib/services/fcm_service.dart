import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification_service.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> init() async {
    await _requestPermission();
    await _saveToken();
    _listenTokenRefresh();
    await _subscribeToAllUsersTopic();
    _listenForegroundMessages();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _saveToken() async {
    final uid = _uid;
    if (uid == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    print('FCM TOKEN: $token');

    await _db.collection('users').doc(uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      final uid = _uid;
      if (uid == null) return;

      print('NEW FCM TOKEN: $newToken');

      await _db.collection('users').doc(uid).set({
        'fcmToken': newToken,
      }, SetOptions(merge: true));
    });
  }

  Future<void> _subscribeToAllUsersTopic() async {
    await _messaging.subscribeToTopic('all-users');
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 New Foreground Message");

      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? '';

      await LocalNotificationService.instance.showNotification(
        title: title,
        body: body,
      );
    });
  }
}