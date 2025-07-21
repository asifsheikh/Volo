/// App-wide constants for better maintainability
class AppConstants {
  // App Information
  static const String appName = 'Volo';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseApiUrl = 'https://searchflights-3ltmkayg6q-uc.a.run.app';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Firebase Configuration
  static const String firebaseProjectId = 'volo-backend';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Colors
  static const int primaryColorValue = 0xFF059393;
  static const int secondaryColorValue = 0xFF047C7C;
  static const int backgroundColorValue = 0xFFF7F8FA;
  static const int textPrimaryColorValue = 0xFF111827;
  static const int textSecondaryColorValue = 0xFF6B7280;
  
  // Text Styles
  static const String defaultFontFamily = 'Inter';
  static const double defaultFontSize = 16.0;
  static const double headingFontSize = 24.0;
  static const double subheadingFontSize = 18.0;
  static const double captionFontSize = 12.0;
  
  // Storage Keys
  static const String userPhoneKey = 'user_phone';
  static const String userProfileKey = 'user_profile';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Error Messages
  static const String networkErrorMessage = 'No internet connection. Please check your network settings and try again.';
  static const String serverErrorMessage = 'Server is temporarily unavailable. Please try again in a few minutes.';
  static const String timeoutErrorMessage = 'Request timed out. Please check your connection and try again.';
  static const String unknownErrorMessage = 'Something went wrong. Please try again.';
  
  // Success Messages
  static const String flightAddedMessage = 'Flight added successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String contactAddedMessage = 'Contact added successfully!';
  
  // Validation Messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidPhoneMessage = 'Please enter a valid phone number';
  static const String invalidEmailMessage = 'Please enter a valid email address';
  static const String passwordTooShortMessage = 'Password must be at least 6 characters';
  
  // Navigation Routes
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String otpRoute = '/otp';
  static const String onboardingRoute = '/onboarding';
  static const String profileRoute = '/profile';
  static const String addFlightRoute = '/add-flight';
  static const String flightResultsRoute = '/flight-results';
  
  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Limits
  static const int maxContactsPerFlight = 10;
  static const int maxFlightHistory = 50;
  static const int maxProfileImageSize = 5 * 1024 * 1024; // 5MB
  
  // Timeouts
  static const Duration otpTimeout = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration cacheTimeout = Duration(hours: 1);
} 