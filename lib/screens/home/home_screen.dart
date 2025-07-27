import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;
import 'dart:core';
import '../../services/firebase_service.dart';
import '../../services/profile_picture_service.dart';
import '../../services/network_service.dart';
import '../../features/add_flight/add_flight_screen.dart';
import '../profile/profile_screen.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profilePictureUrl;
  bool _isLoadingProfile = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkNetworkAndLoadProfile();
  }

  /// Check network status and load profile picture accordingly
  Future<void> _checkNetworkAndLoadProfile() async {
    try {
      final networkService = NetworkService();
      final hasInternet = await networkService.hasInternetConnection();
      
      if (!hasInternet) {
        developer.log('HomeScreen: No internet connection, skipping profile picture load', name: 'VoloProfile');
        if (mounted) {
          setState(() {
            _isOffline = true;
            _isLoadingProfile = false;
          });
        }
        return;
      }

      // Only load profile picture if we have internet
      await _loadProfilePicture();
    } catch (e) {
      developer.log('HomeScreen: Error checking network or loading profile: $e', name: 'VoloProfile');
      if (mounted) {
        setState(() {
          _isOffline = true;
          _isLoadingProfile = false;
        });
      }
    }
  }

  /// Load user's profile picture from Firestore
  Future<void> _loadProfilePicture() async {
    try {
      final String? url = await ProfilePictureService.getUserProfilePictureUrl();
      if (mounted) {
        setState(() {
          _profilePictureUrl = url;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      developer.log('HomeScreen: Error loading profile picture: $e', name: 'VoloProfile');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header section with greeting and profile
            Padding(
              padding: EdgeInsets.only(
                left: 24.0, 
                right: 24.0,
                top: MediaQuery.of(context).padding.top > 0 ? 16.0 : 24.0,
                bottom: 32.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Hey, ${widget.username} 👋',
                      style: AppTheme.headlineLarge.copyWith(fontWeight: FontWeight.w400),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateToProfile(context);
                    },
                    child: _buildProfileAvatar(),
                  ),
                ],
              ),
            ),
            
            // Main content area with improved visual hierarchy
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main title - Secondary level prominence
                    Text(
                      'Travel confidently—Volo updates your loved ones automatically',
                      textAlign: TextAlign.center,
                      style: AppTheme.headlineMedium,
                    ),
                    
                    const SizedBox(height: 20), // Increased spacing for breathing room
                    
                    // Subtitle - Tertiary level (significantly de-emphasized)
                    Text(
                      'Add your flight details and Volo will keep your family and friends updated in real time, so you can focus on your journey.',
                      textAlign: TextAlign.center,
                                              style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.8),
                        ),
                    ),
                    
                    const SizedBox(height: 56), // Increased spacing to emphasize CTA
                    
                    // Primary CTA Button - Most prominent element
                    SizedBox(
                      width: double.infinity,
                      height: 60, // Slightly increased height for prominence
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddFlightScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.flight_takeoff, 
                          color: Colors.white, 
                          size: 24,
                        ),
                        label: const Text(
                          'Add Your Flight',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 18, // Increased to 18pt for accessibility compliance
                            color: Colors.white,
                          ),
                        ),
                        style: AppTheme.primaryButton,
                      ),
                    ),
                    
                    const SizedBox(height: 32), // Increased spacing
                    
                    // Secondary link - Very subtle (optional secondary action)
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to "How does Volo work?" screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('How does Volo work? - Coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'How does Volo work?',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary.withOpacity(0.7),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  /// Navigate to profile screen with user data
  void _navigateToProfile(BuildContext context) {
    final phoneNumber = FirebaseService.getUserPhoneNumber() ?? 'Unknown';
    developer.log('HomeScreen: Navigating to profile with phone: $phoneNumber', name: 'VoloAuth');
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          username: widget.username,
          phoneNumber: phoneNumber,
        ),
      ),
    ).then((_) {
      // Refresh profile picture when returning from profile screen
      _checkNetworkAndLoadProfile();
    });
  }

  Widget _buildProfileAvatar() {
    if (_isLoadingProfile) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.cardBackground,
        child: CircularProgressIndicator(
          color: AppTheme.textSecondary,
        ),
      );
    }

    if (_isOffline) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.cardBackground,
        child: Icon(
          Icons.signal_wifi_off,
          size: 28,
          color: AppTheme.textSecondary,
        ),
      );
    }

    if (_profilePictureUrl != null) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.cardBackground,
        backgroundImage: NetworkImage(_profilePictureUrl!),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppTheme.cardBackground,
      child: Icon(
        Icons.person,
        size: 28,
        color: AppTheme.textSecondary,
      ),
    );
  }
} 