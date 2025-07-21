import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;
import 'dart:core';
import '../../services/firebase_service.dart';
import '../../services/profile_picture_service.dart';
import '../../services/network_service.dart';
import '../../features/add_flight/add_flight_screen.dart';
import '../../features/add_flight/controller/add_flight_controller.dart';
import '../profile/profile_screen.dart';

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
      backgroundColor: const Color(0xFFF7F8FA),
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
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 28,
                        color: Color(0xFF1F2937),
                      ),
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
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 24, // Reduced from 28 for better hierarchy
                        height: 1.3,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    
                    const SizedBox(height: 20), // Increased spacing for breathing room
                    
                    // Subtitle - Tertiary level (significantly de-emphasized)
                    Text(
                      'Add your flight details and Volo will keep your family and friends updated in real time, so you can focus on your journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400, // Regular weight instead of medium
                        fontSize: 14, // Reduced from 16 for de-emphasis
                        height: 1.6, // Increased line height for lighter feel
                        color: const Color(0xFF9CA3AF).withOpacity(0.8), // Tertiary color with reduced opacity
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
                              builder: (context) => ChangeNotifierProvider(
                                create: (context) => AddFlightController(),
                                child: const AddFlightScreen(),
                              ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047C7C), // Updated to new primary color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
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
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400, // Reduced from 500 for de-emphasis
                          fontSize: 12, // Reduced from 14 for subtlety
                          color: const Color(0xFF6B7280).withOpacity(0.7), // Secondary color with reduced opacity
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            // TODO: Implement navigation logic
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight_outlined),
              activeIcon: Icon(Icons.flight),
              label: 'Flights',
            ),
          ],
          selectedItemColor: Color(0xFF047C7C), // Updated to new primary color
          unselectedItemColor: Color(0xFF9CA3AF),
          selectedLabelStyle: TextStyle(
            fontFamily: 'Inter', 
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Inter', 
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
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
      return const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(
          color: Color(0xFF9CA3AF),
        ),
      );
    }

    if (_isOffline) {
      return const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.signal_wifi_off,
          size: 28,
          color: Color(0xFF9CA3AF),
        ),
      );
    }

    if (_profilePictureUrl != null) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(_profilePictureUrl!),
      );
    }

    return const CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: 28,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
} 