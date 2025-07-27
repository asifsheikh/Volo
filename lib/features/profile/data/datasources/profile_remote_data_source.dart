import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_state.dart' as domain;
import '../../../../services/firebase_service.dart';
import '../../../../services/profile_picture_service.dart';
import '../../../../services/push_notification_service.dart';

part 'profile_remote_data_source.g.dart';

/// Remote data source for profile
@riverpod
class ProfileRemoteDataSource extends _$ProfileRemoteDataSource {
  @override
  Future<domain.ProfileState> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  /// Get profile data
  Future<domain.ProfileState> getProfileData(String username, String phoneNumber) async {
    try {
      // Load profile picture
      final profilePictureUrl = await ProfilePictureService.getUserProfilePictureUrl();
      
      return domain.ProfileState(
        username: username,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
      );
    } catch (e) {
      throw Exception('Failed to get profile data: $e');
    }
  }

  /// Load user's profile picture
  Future<String?> loadProfilePicture() async {
    try {
      return await ProfilePictureService.getUserProfilePictureUrl();
    } catch (e) {
      throw Exception('Failed to load profile picture: $e');
    }
  }

  /// Update profile picture
  Future<bool> updateProfilePicture() async {
    try {
      // Note: This requires BuildContext, so we'll handle it in the repository
      throw UnimplementedError('updateProfilePicture requires BuildContext and should be handled in repository');
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await FirebaseService.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      // Note: This requires BuildContext, so we'll handle it in the repository
      throw UnimplementedError('deleteAccount requires BuildContext and should be handled in repository');
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await FirebaseService.getFCMToken();
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  /// Test Firebase messaging
  Future<void> testFirebaseMessaging() async {
    try {
      await PushNotificationService.testFirebaseMessaging();
    } catch (e) {
      throw Exception('Failed to test Firebase messaging: $e');
    }
  }

  /// Test local notification
  Future<void> testLocalNotification() async {
    try {
      await PushNotificationService.testLocalNotification();
    } catch (e) {
      throw Exception('Failed to test local notification: $e');
    }
  }
} 