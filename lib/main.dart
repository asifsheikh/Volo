import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'firebase_options.dart';
import 'core/auth_wrapper.dart';
import 'services/firebase_service.dart';
import 'services/remote_config_service.dart';

// Background message handler for Firebase Cloud Messaging
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
        // Add custom page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionsBuilder(),
            TargetPlatform.iOS: CustomPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AuthWrapper(), // Use AuthWrapper for authentication state management
    );
  }
}

// Custom page transitions for smooth navigation
class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  const CustomPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}
