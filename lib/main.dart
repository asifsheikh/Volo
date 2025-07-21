import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

import 'firebase_options.dart';
import 'core/auth_wrapper.dart';
import 'services/firebase_service.dart';
import 'services/remote_config_service.dart';
import 'services/network_service.dart';
import 'widgets/network_status_indicator.dart';
import 'theme/app_theme.dart';

// Background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  developer.log('Handling a background message: ${message.messageId}', name: 'VoloPush');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme, // Use centralized theme
      home: NetworkStatusIndicator(
        child: const AuthWrapper(),
      ),
    );
  }
}

void main() async {
  developer.log('Main: App starting...', name: 'VoloAuth');
  
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for a polished, full-screen look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // For Android
    statusBarBrightness: Brightness.light,    // For iOS
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  try {
    // Initialize Firebase Core with platform-specific configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Service
    await FirebaseService.initialize();
    
    // Initialize Firebase App Check FIRST (before AI Service)
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
    }
    
    // Initialize Remote Config Service
    await RemoteConfigService().initialize();
    
    // Initialize Network Service
    await NetworkService().initialize();
    
    // Set up Firebase Cloud Messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Initialize Push Notification Service
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    developer.log('Main: Firebase initialization completed successfully', name: 'VoloAuth');
  } catch (e) {
    developer.log('Main: Firebase initialization failed: $e', name: 'VoloAuth');
    // Continue with app startup even if Firebase fails
  }
  
  runApp(const MyApp());
}
