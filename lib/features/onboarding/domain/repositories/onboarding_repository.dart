import '../entities/onboarding_state.dart';

abstract class OnboardingRepository {
  /// Get onboarding data
  Future<OnboardingState> getOnboardingData(String phoneNumber);
  
  /// Validate first name
  bool validateFirstName(String firstName);
  
  /// Complete onboarding and save user profile
  Future<void> completeOnboarding({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });
  
  /// Check if user is authenticated
  bool isUserAuthenticated();
  
  /// Get current user
  dynamic getCurrentUser();
} 