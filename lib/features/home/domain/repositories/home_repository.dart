import '../entities/home_state.dart';

/// Repository interface for home feature
abstract class HomeRepository {
  /// Get user profile picture URL
  Future<String?> getUserProfilePictureUrl();
  
  /// Check network connectivity
  Future<bool> hasInternetConnection();
  
  /// Get user phone number
  String? getUserPhoneNumber();
} 