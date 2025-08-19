import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'core/auth_wrapper.dart';
import 'theme/app_theme.dart';
import 'dart:developer' as developer;

// Global navigator key for accessing context from providers
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize App Check
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('your-recaptcha-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );
    
    developer.log('Firebase initialized successfully', name: 'VoloApp');
  } catch (e) {
    developer.log('Firebase initialization failed: $e', name: 'VoloApp');
  }
  
  developer.log('App starting...', name: 'VoloApp');
  
  runApp(
    const ProviderScope(
      child: VoloApp(),
    ),
  );
}

class VoloApp extends ConsumerWidget {
  const VoloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Volo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: ThemeMode.system,
      navigatorKey: navigatorKey,
      home: const AuthWrapper(),
    );
  }
}
