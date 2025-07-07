import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'services/firebase_service.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

/// Authentication wrapper that handles routing based on user authentication state
/// 
/// This widget:
/// 1. Listens to Firebase authentication state changes
/// 2. Checks if user has completed onboarding
/// 3. Routes to appropriate screen based on state:
///    - Not authenticated → Welcome screen
///    - Authenticated but not onboarded → Welcome screen (start fresh)
///    - Authenticated and onboarded → Home screen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isOnboarded = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  /// Check authentication state and onboarding status
  Future<void> _checkAuthState() async {
    try {
      // Listen to authentication state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
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
      if (mounted) {
        setState(() {
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