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

  /// Handle sign out
  Future<void> _signOut() async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) {
      return;
    }

    try {
      developer.log('ProfileScreen: Signing out user', name: 'VoloAuth');
      
      // Sign out using the use case
      await ref.read(getProfileDataProvider(widget.username, widget.phoneNumber).notifier).signOut();
      
      developer.log('ProfileScreen: Sign out successful', name: 'VoloAuth');
      
      // Navigate back to welcome screen (AuthWrapper will handle routing)
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      developer.log('ProfileScreen: Error signing out: $e', name: 'VoloAuth');
      
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to sign out. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Handle delete account
  Future<void> _deleteAccount() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFFEF4444),
            ),
          ),
          content: const Text(
            'This action cannot be undone. All your flight data and contacts will be permanently deleted.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      developer.log('ProfileScreen: Deleting user account', name: 'VoloAuth');
      
      // Delete account using the use case
      await ref.read(getProfileDataProvider(widget.username, widget.phoneNumber).notifier).deleteAccount();
      
      developer.log('ProfileScreen: Account deletion successful', name: 'VoloAuth');
      
      // Navigate back to welcome screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      developer.log('ProfileScreen: Error deleting account: $e', name: 'VoloAuth');
      
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to delete account. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProviderProvider(widget.username, widget.phoneNumber));
    
    return profileAsync.when(
      data: (profileState) => _buildProfileContent(profileState),
      loading: () => _buildLoadingContent(),
      error: (error, stackTrace) => _buildErrorContent(error.toString()),
    );
  }

  Widget _buildLoadingContent() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Profile',
              style: AppTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(profileProviderProvider(widget.username, widget.phoneNumber));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(domain.ProfileState profileState) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppTheme.textPrimary,
                        splashRadius: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: AppTheme.headlineLarge.copyWith(fontSize: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _updateProfilePicture,
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF059393),
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _isUpdatingProfilePicture
                                      ? Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : profileState.profilePictureUrl != null
                                          ? Image.network(
                                              profileState.profilePictureUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Colors.grey[400],
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF059393),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profileState.username,
                          style: AppTheme.headlineMedium.copyWith(fontSize: 24),
                        ),
                        Text(
                          profileState.phoneNumber,
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Settings Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F3FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.settings, color: Color(0xFF059393)),
                          ),
                          title: const Text(
                            'Settings',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                          onTap: () {
                            // Navigate to settings
                          },
                        ),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F3FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.help_outline, color: Color(0xFF059393)),
                          ),
                          title: const Text(
                            'Help & Support',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                          onTap: () {
                            // Navigate to help & support
                          },
                        ),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F3FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.privacy_tip, color: Color(0xFF059393)),
                          ),
                          title: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                          onTap: () {
                            // Navigate to privacy policy
                          },
                        ),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F3FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.description, color: Color(0xFF059393)),
                          ),
                          title: const Text(
                            'Terms of Service',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
                          onTap: () {
                            // Navigate to terms of service
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Debug Section (if in debug mode)
                  if (kDebugMode) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7E6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.bug_report, color: Color(0xFFFFA726)),
                            ),
                            title: Row(
                              children: [
                                const Text(
                                  'Debug Tools',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: Color(0xFF111827),
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
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const PushNotificationTestScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Account Actions Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.logout, color: Color(0xFFFFA726)),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          onTap: _signOut,
                        ),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE6E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                          ),
                          title: const Text(
                            'Delete Account',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          onTap: _deleteAccount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 