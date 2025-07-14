import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'core/auth_wrapper.dart';
import 'services/firebase_service.dart';
import 'services/ai_service.dart';
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
    
    // Initialize AI Service AFTER App Check, passing the App Check instance
    await AIService().initialize(appCheck: FirebaseAppCheck.instance);
    
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
