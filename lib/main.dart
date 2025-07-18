import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/auth_wrapper.dart';
import 'services/firebase_service.dart';
import 'services/push_notification_service.dart';

import 'services/remote_config_service.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Main entry point for the Volo Flutter application
/// 
/// This function initializes Firebase services and starts the app.
/// Features include:
/// - Firebase Core initialization with platform-specific options
/// - Firebase App Check initialization with production-ready configuration
/// - Comprehensive error handling and logging
/// - Automatic debug/production mode switching
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
    
    // Set up Firebase Cloud Messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Initialize Push Notification Service
    try {
      await PushNotificationService.initialize(
        onMessageReceived: (RemoteMessage message) {
          developer.log('Main: Foreground message received: ${message.messageId}', name: 'VoloAuth');
          // TODO: Handle foreground message (show in-app notification, update UI, etc.)
        },
        onMessageOpenedApp: (RemoteMessage message) {
          developer.log('Main: App opened from notification: ${message.messageId}', name: 'VoloAuth');
          // TODO: Handle navigation when app is opened from notification
        },
      );
    } catch (e) {
      developer.log('Main: Push Notification initialization failed: $e', name: 'VoloAuth');
    }
    
    // Ensure FCM token is updated in user profile after initialization
    // This will run after a short delay to allow Firebase to fully initialize
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        await FirebaseService.ensureFCMTokenUpdated();
      } catch (e) {
        developer.log('Main: Failed to ensure FCM token updated: $e', name: 'VoloAuth');
      }
    });
    

    
  } catch (e) {
    developer.log('App: Firebase initialization failed: $e', name: 'VoloAuth');
    rethrow;
  }
  
  runApp(const MyApp());
}

/// Root application widget for Volo
/// 
/// This widget configures the MaterialApp with:
/// - App title and branding
/// - Theme configuration with custom color scheme
/// - Initial route to AuthWrapper for authentication state management
/// - Production-ready configuration
/// - Full-screen system UI overlay handling
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volo',
      theme: ThemeData(
        // Custom theme configuration for Volo app
        // Uses a deep purple color scheme as the base
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthWrapper(), // Use AuthWrapper for authentication state management
    );
  }
}

// Note: MyHomePage class removed as it's not used in the Volo app
// The app uses custom screens for flight tracking and authentication

/// Background message handler for Firebase Cloud Messaging
/// This function must be top-level and cannot be inside a class
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background processing
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  developer.log('Main: Background message received: ${message.messageId}', name: 'VoloAuth');
  developer.log('Main: Background message data: ${message.data}', name: 'VoloAuth');
  developer.log('Main: Background message notification: ${message.notification?.title} - ${message.notification?.body}', name: 'VoloAuth');
  
  // TODO: Handle background message processing
  // This will be implemented when we have proper background processing
  // For now, just log the message
}
