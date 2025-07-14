/// Default values for Firebase Remote Config parameters
/// These values are used as fallback when remote config fails to fetch
class RemoteConfigDefaults {
  /// Default value for use_mock_flight_data parameter
  /// Controls whether the app uses mock flight data or real API responses
  /// Set to false to match Firebase Console setting
  static const bool useMockFlightData = false;
  
  /// Add more default values here as needed in the future
  /// Example:
  /// static const String mockDataVersion = 'v1';
  /// static const int apiTimeoutSeconds = 30;
} 