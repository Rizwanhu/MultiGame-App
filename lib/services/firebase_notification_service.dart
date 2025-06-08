import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize(BuildContext context) async {
    // 1. Request notification permissions
    await _requestPermissions();

    // 2. Set up foreground message handler with context
    _setupForegroundHandler(context);

    // 3. Handle token updates
    _handleTokenUpdates();
  }

  static Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void _setupForegroundHandler(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotificationSnackbar(
          context,
          message.notification!.title ?? 'New Reward!',
          message.notification!.body ?? 'You have unclaimed points',
        );
      }
    });
  }

  static void _handleTokenUpdates() {
    _firebaseMessaging.getToken().then((token) {
      print('Initial FCM Token: $token');
    });

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM Token: $newToken');
    });
  }

  static void _showNotificationSnackbar(
    BuildContext context,
    String title,
    String body,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(body),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}