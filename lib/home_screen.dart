import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'services/firebase_service.dart';
import 'add_flight_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

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
                    'Hi, $username',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 32,
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
                      backgroundImage: AssetImage('assets/profile_placeholder.png'),
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
                      'No flights being tracked right now',
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
                      'Tap below to start tracking your upcoming flight',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
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
                          MaterialPageRoute(builder: (context) => const AddFlightScreen()),
                        );
                      },
                      icon: const Icon(Icons.flight_takeoff, color: Colors.white, size: 28),
                      label: const Text(
                        'Add Flight',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
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
          username: username,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }
} 