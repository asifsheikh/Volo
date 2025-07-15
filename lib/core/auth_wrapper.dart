import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // Import App Check
import 'dart:developer' as developer;
import 'dart:async';
import '../services/firebase_service.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/home/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isOnboarded = false;
  User? _currentUser;

  // Add a StreamSubscription to manage the authStateChanges listener
  // so we can cancel it when the widget is disposed.
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Start listening to App Check token changes first
    _waitForAppCheckAndAuthState();
  }

  // Dispose of the subscription when the widget is removed
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// Wait for App Check to be ready, then check authentication state
  Future<void> _waitForAppCheckAndAuthState() async {
    try {
      // Step 1: Wait for an App Check token to be available.
      // This will ensure App Check has initialized and propagated its state.
      // We can use the 'getToken' method which will implicitly activate
      // the App Check attestation if it hasn't already.
      // Setting `forceRefresh: true` ensures we try to get a new token.
      developer.log('AuthWrapper: Waiting for App Check token...', name: 'VoloAuth');
      await FirebaseAppCheck.instance.getToken(true);
      developer.log('AuthWrapper: App Check token obtained, proceeding to auth state.', name: 'VoloAuth');

      // Step 2: Now that App Check is ready, set up the authStateChanges listener
      _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        developer.log('AuthWrapper: Auth state changed: ${user == null ? "Logged out" : "Logged in"}', name: 'VoloAuth');
        if (user != null) {
          // User is authenticated, check onboarding status
          final isOnboarded = await FirebaseService.isUserOnboarded();

          // Double-check: if user profile doesn't exist, they're not onboarded
          final userProfile = await FirebaseService.getUserProfile();
          final hasProfile = userProfile != null;

          if (mounted) {
            setState(() {
              _currentUser = user;
              _isOnboarded = isOnboarded && hasProfile;
              _isLoading = false;
            });
          }
        } else {
          // User is not authenticated
          if (mounted) {
            setState(() {
              _currentUser = null;
              _isOnboarded = false;
              _isLoading = false;
            });
          }
        }
      });
    } catch (e) {
      developer.log('AuthWrapper: Error during App Check or Auth state check: $e', name: 'VoloAuth');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of your build method, _buildLoadingScreen, _buildHomeScreen remain the same)
    // Show loading screen while checking authentication state
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // User is not authenticated OR user is authenticated but not onboarded
    if (_currentUser == null || !_isOnboarded) {
      developer.log('AuthWrapper: Routing to WelcomeScreen', name: 'VoloAuth');
      developer.log('  - Reason: ${_currentUser == null ? "Not authenticated" : "Not onboarded"}', name: 'VoloAuth');
      return const WelcomeScreen();
    }

    // User is authenticated and onboarded
    developer.log('AuthWrapper: Routing to HomeScreen', name: 'VoloAuth');
    return _buildHomeScreen();
  }

  // ... (Your _buildLoadingScreen and _buildHomeScreen methods)
  /// Build loading screen while checking authentication state
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(24),
              shadowColor: Colors.black.withOpacity(0.08),
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/volo_app_icon.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build home screen with user data
  Widget _buildHomeScreen() {
    // Get user profile data for display name
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirebaseService.getUserProfile(),
      builder: (context, snapshot) {
        // If still loading, show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // If no data or error, user is not properly onboarded
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // User profile doesn't exist, they haven't completed onboarding
          // Sign them out and redirect to welcome screen
          FirebaseService.signOut();
          return const WelcomeScreen();
        }

        // User profile exists, get display name
        String displayName = 'User';
        final firstName = snapshot.data!['firstName'] as String?;
        if (firstName != null && firstName.isNotEmpty) {
          displayName = firstName;
        }

        return HomeScreen(username: displayName);
      },
    );
  }
}
