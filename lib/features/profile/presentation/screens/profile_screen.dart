import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../providers/profile_provider.dart';
import '../../domain/entities/profile_state.dart' as domain;
import '../../domain/usecases/get_profile_data.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/profile_picture_service.dart';
import '../../../../services/remote_config_service.dart';
import '../../../../features/ai_demo/ai_demo_screen.dart';
import '../../../../theme/app_theme.dart';
import '../screens/push_notification_test_screen.dart';
import '../../../../screens/profile/settings_screen.dart';
import '../../../../screens/profile/debug_tools_screen.dart';

/// Profile Screen using Riverpod + Clean Architecture
class ProfileScreen extends ConsumerStatefulWidget {
  final String username;
  final String phoneNumber;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUpdatingProfilePicture = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  /// Load user's profile picture from Firestore
  Future<void> _loadProfilePicture() async {
    try {
      await ref.read(getProfileDataProvider(widget.username, widget.phoneNumber).notifier).loadProfilePicture();
    } catch (e) {
      developer.log('ProfileScreen: Error loading profile picture: $e', name: 'VoloProfile');
    }
  }

  /// Handle profile picture update
  Future<void> _updateProfilePicture() async {
    if (_isUpdatingProfilePicture) return;

    setState(() {
      _isUpdatingProfilePicture = true;
    });

    try {
      final bool success = await ProfilePictureService.updateProfilePicture(context);
      if (success && mounted) {
        // Reload profile picture
        await _loadProfilePicture();
      }
    } catch (e) {
      developer.log('ProfileScreen: Error updating profile picture: $e', name: 'VoloProfile');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingProfilePicture = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(getProfileDataProvider(widget.username, widget.phoneNumber));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: AppTheme.headlineMedium,
        ),
        centerTitle: false,
      ),
      body: profileState.when(
        data: (profileData) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Picture Section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Profile picture with teal border
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF008080), // Teal border
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: profileData.profilePictureUrl != null
                                  ? NetworkImage(profileData.profilePictureUrl!)
                                  : null,
                              child: profileData.profilePictureUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 48,
                                      color: Color(0xFF9CA3AF),
                                    )
                                  : null,
                            ),
                          ),
                          // Camera button
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _isUpdatingProfilePicture ? null : _updateProfilePicture,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _isUpdatingProfilePicture 
                                        ? Color(0xFF9CA3AF)
                                        : Color(0xFF008080),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: _isUpdatingProfilePicture
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profileData.username,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 6),
                          Text(
                            profileData.phoneNumber,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'To change your phone number, please log out and log in again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Main Sections
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // My Circle
                      ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(0x33008080),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.groups,
                              color: Color(0xFF008080),
                              size: 20,
                            ),
                          ),
                        ),
                        title: const Text(
                          'My Circle',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Color(0xFF333333),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF9CA3AF),
                          size: 16,
                        ),
                        onTap: () {
                          // TODO: Navigate to My Circle screen
                        },
                      ),
                      const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                      
                      // My Flight Journey
                      ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(0x33008080),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.flight_takeoff,
                              color: Color(0xFF008080),
                              size: 20,
                            ),
                          ),
                        ),
                        title: const Text(
                          'My Flight Journey',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Color(0xFF333333),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF9CA3AF),
                          size: 16,
                        ),
                        onTap: () {
                          // TODO: Navigate to My Flight Journey screen
                        },
                      ),
                      const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                      
                      // Settings
                      ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(0x33008080),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.settings,
                              color: Color(0xFF008080),
                              size: 20,
                            ),
                          ),
                        ),
                        title: const Text(
                          'Settings',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Color(0xFF333333),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF9CA3AF),
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(
                                username: profileData.username,
                                phoneNumber: profileData.phoneNumber,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Debug Tools (only in debug mode)
                      if (kDebugMode) ...[
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                        ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(0x33008080),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.bug_report,
                                color: Color(0xFF008080),
                                size: 20,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              const Text(
                                'Debug Tools',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'DEBUG',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DebugToolsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
} 