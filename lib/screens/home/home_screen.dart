import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;
import 'dart:core';
import '../../services/firebase_service.dart';
import '../../services/profile_picture_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  /// Load user's profile picture from Firestore
  Future<void> _loadProfilePicture() async {
    try {
      final String? url = await ProfilePictureService.getUserProfilePictureUrl();
      if (mounted) {
        setState(() {
          _profilePictureUrl = url;
        });
      }
    } catch (e) {
      developer.log('HomeScreen: Error loading profile picture: $e', name: 'VoloProfile');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 24.0, 
                right: 24.0,
                top: MediaQuery.of(context).padding.top > 0 ? 24.0 : 32.0,
                bottom: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hey, ${widget.username} 👋',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 28,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _navigateToProfile(context);
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: _profilePictureUrl != null
                          ? NetworkImage(_profilePictureUrl!)
                          : null,
                      child: _profilePictureUrl == null
                          ? Icon(
                              Icons.person,
                              size: 28,
                              color: Color(0xFF9CA3AF),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'No flights being tracked yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Add your first flight to start keeping your loved ones updated',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 320,
                    height: 60,
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
                      icon: const Icon(Icons.flight_takeoff, color: Colors.white, size: 28),
                      label: const Text(
                        'Add Your First Flight',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight),
            label: 'Flights',
          ),
        ],
        selectedItemColor: Color(0xFF059393),
        unselectedItemColor: Color(0xFF9CA3AF),
        selectedLabelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
        backgroundColor: Colors.white,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
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
      _loadProfilePicture();
    });
  }
} 