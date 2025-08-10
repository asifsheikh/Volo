import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'push_notification_test_screen.dart';
import 'settings_screen.dart';
import 'debug_tools_screen.dart';

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
                  decoration: AppTheme.elevatedCardDecoration.copyWith(
                    borderRadius: BorderRadius.circular(24),
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
                                color: AppTheme.primary,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: AppTheme.cardBackground,
                              backgroundImage: profileData.profilePictureUrl != null
                                  ? NetworkImage(profileData.profilePictureUrl!)
                                  : null,
                              child: profileData.profilePictureUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 48,
                                      color: AppTheme.textSecondary,
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
                                        ? AppTheme.textSecondary
                                        : AppTheme.primary,
                                    shape: BoxShape.circle,
                                                                            boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.shadowPrimary,
                                            blurRadius: 6,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: AppTheme.shadowPrimary,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                  ),
                                  child: _isUpdatingProfilePicture
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textOnPrimary),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          color: AppTheme.textOnPrimary,
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
                        style: AppTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            profileData.phoneNumber,
                            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'To change your phone number, please log out and log in again.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // My Flight Journey Section
                Container(
                  decoration: AppTheme.elevatedCardDecoration,
                  child: Column(
                    children: [
                      // My Flight Journey
                      ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.flight_takeoff,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        title: Text(
                          'My Flight Journey',
                          style: AppTheme.titleMedium,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.textSecondary,
                          size: 16,
                        ),
                        onTap: () {
                          // TODO: Navigate to My Flight Journey screen
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Settings Section
                Container(
                  decoration: AppTheme.elevatedCardDecoration,
                  child: ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.cog,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      'Settings',
                      style: AppTheme.titleMedium,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.textSecondary,
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
                ),
                
                // Debug Tools Section (only in debug mode)
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: AppTheme.elevatedCardDecoration,
                    child: ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.bug_report,
                            color: AppTheme.warning,
                            size: 20,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Debug Tools',
                            style: AppTheme.titleMedium,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.warning,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'DEBUG',
                              style: AppTheme.labelSmall.copyWith(color: AppTheme.textOnPrimary),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary,
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
                  ),
                ],
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