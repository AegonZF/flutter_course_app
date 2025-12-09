import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_course_app/FirebaseNotifications/firebase_notification_service.dart';
import 'package:flutter_course_app/Provider/auth_provider.dart';
import 'package:flutter_course_app/Provider/poll_provider.dart';
import 'package:flutter_course_app/Screens/Home%20Screen/create_poll_screen.dart';
import 'package:flutter_course_app/Screens/Home%20Screen/home_show_poll_screen.dart';
import 'package:flutter_course_app/Screens/Onboarding/splash_screen.dart';
import 'package:flutter_course_app/Screens/signin_screen.dart';
import 'package:flutter_course_app/Screens/signup_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

FirebaseNotificationService firebaseNotificationService =
    FirebaseNotificationService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  log('Handling a background message ${message.messageId}');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    firebaseNotificationService.requestNotificationPermissions();
    firebaseNotificationService.foregroundMessage();
    firebaseNotificationService.setupInteractMessage(context);
    firebaseNotificationService.getDeviceToken().then((value) => log(value));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PollProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Course App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SigninScreen(),
      ),
    );
  }
}
