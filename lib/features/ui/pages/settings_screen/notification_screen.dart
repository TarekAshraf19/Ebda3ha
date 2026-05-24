import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../models/notification_model.dart';
import '../../../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _didMarkAll = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didMarkAll) {
      _didMarkAll = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationService.instance.markAllAsRead();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.kPrimaryPink,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.kPrimaryPink,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.kPrimaryPink,
                size: 18,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          context.tr.tr('notifications'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: NotificationService.instance.notificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${context.tr.tr("error")}: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                context.tr.tr('no_notifications_yet'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            );
          }

          final notifications = docs
              .map((doc) => AppNotification.fromDoc(doc.id, doc.data()))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final item = notifications[index];

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: item.isRead
                      ? Colors.white.withOpacity(0.92)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.isRead
                        ? Colors.grey.shade300
                        : AppColors.kPrimaryPink,
                    width: item.isRead ? 1 : 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      textDirection:
                      isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 18,
                      ).copyWith(
                        fontWeight:
                        item.isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.body,
                      textDirection:
                      isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}