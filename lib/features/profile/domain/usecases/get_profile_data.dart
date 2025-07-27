import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/profile_state.dart' as domain;
import '../repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';

part 'get_profile_data.g.dart';

/// Use case for getting profile data
@riverpod
class GetProfileData extends _$GetProfileData {
  @override
  Future<domain.ProfileState> build(String username, String phoneNumber) async {
    return _getProfileData(username, phoneNumber);
  }

  Future<domain.ProfileState> _getProfileData(String username, String phoneNumber) async {
    try {
      final repository = ref.read(profileRepositoryImplProvider.notifier);
      
      // Get profile data
      final profileData = await repository.getProfileData(username, phoneNumber);
      
      return profileData;
    } catch (e) {
      throw Exception('Failed to get profile data: $e');
    }
  }

  /// Load profile picture
  Future<String?> loadProfilePicture() async {
    try {
      final repository = ref.read(profileRepositoryImplProvider.notifier);
      return await repository.loadProfilePicture();
    } catch (e) {
      throw Exception('Failed to load profile picture: $e');
    }
  }

  /// Update profile picture
  Future<bool> updateProfilePicture() async {
    try {
      final repository = ref.read(profileRepositoryImplProvider.notifier);
      return await repository.updateProfilePicture();
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      final repository = ref.read(profileRepositoryImplProvider.notifier);
      await repository.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final repository = ref.read(profileRepositoryImplProvider.notifier);
      await repository.deleteAccount();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      final repository = ref.read(profileRepositoryImplProvider.notifier);
      return await repository.getFCMToken();
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  /// Test Firebase messaging
  Future<void> testFirebaseMessaging() async {
    try {
      final repository = ref.read(profileRepositoryImplProvider.notifier);
      await repository.testFirebaseMessaging();
    } catch (e) {
      throw Exception('Failed to test Firebase messaging: $e');
    }
  }

  /// Test local notification
  Future<void> testLocalNotification() async {
    try {
      final repository = ref.read(profileRepositoryImplProvider.notifier);
      await repository.testLocalNotification();
    } catch (e) {
      throw Exception('Failed to test local notification: $e');
    }
  }
} 