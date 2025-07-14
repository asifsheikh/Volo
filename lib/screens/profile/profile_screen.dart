import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import 'dart:developer' as developer;
import '../../services/firebase_service.dart';
import '../../services/profile_picture_service.dart';
import '../../services/remote_config_service.dart';
import '../ai/ai_demo_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String phoneNumber;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  String? _profilePictureUrl;
  bool _isUpdatingProfilePicture = false;

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

    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('ProfileScreen: Signing out user', name: 'VoloAuth');
      
      // Sign out from Firebase
      await FirebaseService.signOut();
      
      developer.log('ProfileScreen: Sign out successful', name: 'VoloAuth');
      
      // Navigate back to welcome screen (AuthWrapper will handle routing)
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      developer.log('ProfileScreen: Error signing out: $e', name: 'VoloAuth');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

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

    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('ProfileScreen: Deleting user account', name: 'VoloAuth');
      
      // Delete user account and data
      await FirebaseService.deleteUserAccount();
      
      developer.log('ProfileScreen: Account deletion successful', name: 'VoloAuth');
      
      // Navigate back to welcome screen (AuthWrapper will handle routing)
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      developer.log('ProfileScreen: Error deleting account: $e', name: 'VoloAuth');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

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

  /// Show remote config values in a clean, read-only dialog
  void _showRemoteConfigStatus() async {
    final remoteConfig = RemoteConfigService();
    final configValues = remoteConfig.getDisplayConfigValues();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Remote Config Values',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: configValues['status'] == 'initialized' 
                        ? const Color(0xFFD1FAE5) 
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    configValues['status'] == 'initialized' ? 'Active' : 'Not Initialized',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: configValues['status'] == 'initialized' 
                          ? const Color(0xFF065F46) 
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Config values list
                ...configValues.entries
                    .where((entry) => entry.key != 'status' && 
                                     entry.key != 'last_fetch_time' && 
                                     entry.key != 'last_fetch_status' &&
                                     entry.key != 'all_parameters' &&
                                     entry.key != 'default_value' &&
                                     entry.key != 'string_value' &&
                                     entry.key != 'parameter_exists' &&
                                     entry.key != 'error')
                    .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xFF1F2937),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                
                // Last fetch time (if available)
                if (configValues['last_fetch_time'] != null) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${configValues['last_fetch_time']}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Refresh remote config
                Navigator.of(context).pop();
                await remoteConfig.refresh();
                // Show updated values
                _showRemoteConfigStatus();
              },
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF008080),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E7EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: _profilePictureUrl != null
                                  ? NetworkImage(_profilePictureUrl!)
                                  : null,
                              child: _profilePictureUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 48,
                                      color: Color(0xFF9CA3AF),
                                    )
                                  : null,
                            ),
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
                          widget.username,
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
                              widget.phoneNumber,
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
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
                          onTap: () {},
                        ),
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
                          onTap: () {},
                        ),
                        // Debug-only options
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
                                  Icons.psychology,
                                  color: Color(0xFF008080),
                                  size: 20,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                const Text(
                                  'AI Demo',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'DEBUG',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const AIDemoScreen()),
                              );
                            },
                          ),
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
                                  Icons.settings,
                                  color: Color(0xFF008080),
                                  size: 20,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                const Text(
                                  'Remote Configs',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'DEBUG',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Show remote config status in a dialog
                              _showRemoteConfigStatus();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                          onTap: _isLoading ? null : _signOut,
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
                          onTap: _isLoading ? null : _deleteAccount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 