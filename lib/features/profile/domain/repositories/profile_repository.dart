import '../entities/profile_state.dart';

abstract class ProfileRepository {
  /// Get user profile data
  Future<ProfileState> getProfileData(String username, String phoneNumber);
  
  /// Load user's profile picture
  Future<String?> loadProfilePicture();
  
  /// Update profile picture
  Future<bool> updateProfilePicture();
  
  /// Sign out user
  Future<void> signOut();
  
  /// Delete user account
  Future<void> deleteAccount();
  
  /// Get FCM token for push notifications
  Future<String?> getFCMToken();
  
  /// Test Firebase messaging
  Future<void> testFirebaseMessaging();
  
  /// Test local notification
  Future<void> testLocalNotification();
} 