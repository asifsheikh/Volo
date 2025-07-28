import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:developer' as developer;
import 'dart:async';

import '../services/firebase_service.dart';
import '../services/network_service.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../screens/main_navigation_screen.dart';

import '../theme/app_theme.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isLoading = true;
  bool _isOnboarded = false;
  bool _isOffline = false;
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
      // Step 1: Check network connectivity first
      final networkService = NetworkService();
      final hasInternet = await networkService.hasInternetConnection();
      
      if (!hasInternet) {
        developer.log('AuthWrapper: No internet connection detected, using cached auth state', name: 'VoloAuth');
        _isOffline = true;
        
        // In offline mode, we can still check Firebase Auth state (it's cached)
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          developer.log('AuthWrapper: User is authenticated (offline mode)', name: 'VoloAuth');
          if (mounted) {
            setState(() {
              _currentUser = currentUser;
              _isOnboarded = true; // Assume onboarded in offline mode if authenticated
              _isLoading = false;
            });
          }
        } else {
          developer.log('AuthWrapper: No authenticated user (offline mode)', name: 'VoloAuth');
          if (mounted) {
            setState(() {
              _currentUser = null;
              _isOnboarded = false;
              _isLoading = false;
            });
          }
        }
        return;
      }

      // Step 2: Wait for an App Check token to be available (only when online)
      developer.log('AuthWrapper: Waiting for App Check token...', name: 'VoloAuth');
      await FirebaseAppCheck.instance.getToken(true);
      developer.log('AuthWrapper: App Check token obtained, proceeding to auth state.', name: 'VoloAuth');

      // Step 3: Now that App Check is ready, set up the authStateChanges listener
      _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        developer.log('AuthWrapper: Auth state changed: ${user == null ? "Logged out" : "Logged in"}', name: 'VoloAuth');
        if (user != null) {
          // User is authenticated - go directly to home screen (skip onboarding check)
          developer.log('AuthWrapper: User authenticated, going to home screen', name: 'VoloAuth');
          if (mounted) {
            setState(() {
              _currentUser = user;
              _isOnboarded = true; // Assume onboarded for authenticated users
              _isOffline = false;
              _isLoading = false;
            });
          }
        } else {
          // User is not authenticated
          developer.log('AuthWrapper: User not authenticated, going to welcome screen', name: 'VoloAuth');
          if (mounted) {
            setState(() {
              _currentUser = null;
              _isOnboarded = false;
              _isOffline = false;
              _isLoading = false;
            });
          }
        }
      });
    } catch (e) {
      developer.log('AuthWrapper: Error during App Check or Auth state check: $e', name: 'VoloAuth');
      // If there's an error, try to use cached auth state
      final currentUser = FirebaseAuth.instance.currentUser;
      if (mounted) {
        setState(() {
          _currentUser = currentUser;
          _isOnboarded = currentUser != null; // Assume onboarded if authenticated
          _isOffline = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking authentication state
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // User is not authenticated
    if (_currentUser == null) {
      developer.log('AuthWrapper: Routing to WelcomeScreen - User not authenticated', name: 'VoloAuth');
      return const WelcomeScreen();
    }

    // User is authenticated - go directly to home screen (skip onboarding check)
    developer.log('AuthWrapper: Routing to HomeScreen - User authenticated', name: 'VoloAuth');
    if (_isOffline) {
      developer.log('AuthWrapper: User is in offline mode', name: 'VoloAuth');
    }
    return _buildHomeScreen();
  }

  /// Build loading screen while checking authentication state
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// Build home screen with user data
  Widget _buildHomeScreen() {
    // If offline, use cached user data or default values
    if (_isOffline) {
      final user = _currentUser;
      String displayName = 'Traveler';
      
      // Try to get display name from cached user data
      if (user?.displayName != null && user!.displayName!.isNotEmpty) {
        displayName = user.displayName!;
      } else if (user?.phoneNumber != null) {
        // Use a more user-friendly format for phone number
        final phone = user!.phoneNumber!;
        if (phone.length >= 10) {
          // Show last 4 digits in a friendly format
          final lastFour = phone.substring(phone.length - 4);
          displayName = 'Traveler ($lastFour)';
        } else {
          displayName = 'Traveler';
        }
      }

      return MainNavigationScreen(username: displayName);
    }

    // Online mode - get user profile data for display name
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirebaseService.getUserProfile(),
      builder: (context, snapshot) {
        // If still loading, show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // If no data or error, try to use cached user data
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          developer.log('AuthWrapper: Could not fetch user profile, using cached data', name: 'VoloAuth');
          
          final user = _currentUser;
          String displayName = 'Traveler';
          
          if (user?.displayName != null && user!.displayName!.isNotEmpty) {
            displayName = user.displayName!;
          } else if (user?.phoneNumber != null) {
            // Use a more user-friendly format for phone number
            final phone = user!.phoneNumber!;
            if (phone.length >= 10) {
              // Show last 4 digits in a friendly format
              final lastFour = phone.substring(phone.length - 4);
              displayName = 'Traveler ($lastFour)';
            } else {
              displayName = 'Traveler';
            }
          }

          return MainNavigationScreen(username: displayName);
        }

        // User profile exists, get display name
        String displayName = 'Traveler';
        final firstName = snapshot.data!['firstName'] as String?;
        if (firstName != null && firstName.isNotEmpty) {
          displayName = firstName;
        }

        return MainNavigationScreen(username: displayName);
      },
    );
  }
}
