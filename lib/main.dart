import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart'; 
import 'dart:io'; 
import 'screen/logo_screen.dart';
import 'theme/theme_provider.dart';
import 'firebase_options.dart';
import 'services/firebase_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const NotificationWrapper(),
    ),
  );
}

class NotificationWrapper extends StatefulWidget {
  const NotificationWrapper({Key? key}) : super(key: key);

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await FirebaseNotificationService.initialize(context);
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token: $fcmToken");
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MultiGame',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeProvider.themeMode,
      home:  SplashScreen(),
    );
  }
}