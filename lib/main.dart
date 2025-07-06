import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'welcome_screen.dart';
import 'dart:developer' as developer;

/// Main entry point for the Volo Flutter application
/// 
/// This function initializes Firebase services and starts the app.
/// Features include:
/// - Firebase Core initialization with platform-specific options
/// - Firebase App Check initialization for security
/// - Comprehensive error handling and logging
/// - Debug mode configuration for development
void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  developer.log('App: Starting Firebase initialization', name: 'VoloAuth');
  try {
    // Initialize Firebase Core with platform-specific configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('App: Firebase initialized successfully', name: 'VoloAuth');
    
    // Initialize Firebase App Check for security and abuse prevention
    // Note: Using production providers for DeviceCheck and SafetyNet
    developer.log('App: Starting App Check initialization', name: 'VoloAuth');
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity, // Use Play Integrity for production
      appleProvider: AppleProvider.deviceCheck,       // Use DeviceCheck for production
    );
    developer.log('App: App Check initialized successfully', name: 'VoloAuth');
  } catch (e) {
    // Log and rethrow Firebase initialization errors
    developer.log('App: Firebase initialization failed: $e', name: 'VoloAuth');
    rethrow;
  }
  
  developer.log('App: Starting MyApp', name: 'VoloAuth');
  
  // Set system UI overlay style for full-screen experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.dark, // Dark status bar icons
      statusBarBrightness: Brightness.light, // Light status bar for iOS
      systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
      systemNavigationBarIconBrightness: Brightness.dark, // Dark navigation icons
    ),
  );
  
  runApp(const MyApp());
}

/// Root application widget for Volo
/// 
/// This widget configures the MaterialApp with:
/// - App title and branding
/// - Theme configuration with custom color scheme
/// - Initial route to WelcomeScreen
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
        // Configure app bar theme for full-screen experience
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      home: const WelcomeScreen(), // Start with welcome screen
    );
  }
}

// Note: MyHomePage class removed as it's not used in the Volo app
// The app uses custom screens for flight tracking and authentication
