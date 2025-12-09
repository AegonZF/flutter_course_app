import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  FirebaseMessaging messages = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> setupInteractMessage(BuildContext context) async {
    RemoteMessage? initialMessage = await messages.getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onMessageOpenedApp.listen((event) {});
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messages.getToken();
    messages.onTokenRefresh.listen((event) {
      token = event;
    });
    return token!;
  }

  Future<void> initLocalNotification() async {
    var androidInitialize = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
      android: androidInitialize,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void requestNotificationPermissions() async {
    NotificationSettings settings = await messages.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('User denied permission');
    }
  }

  Future<void> foregroundMessage() async {
    await messages.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteNotification message) async {
    var androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'description',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_launcher',
    );
    var platformDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      message.title,
      message.body,
      platformDetails,
    );
  }
}
