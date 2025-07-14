import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../config/remote_config_defaults.dart';
import 'dart:developer' as developer;

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isInitialized = false;

  /// Initialize Remote Config with default values and fetch from server
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      developer.log('Starting Remote Config initialization...', name: 'VoloRemoteConfig');
      
      // Set minimum fetch interval (0 for development, higher for production)
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero, // Allow immediate fetch for development
      ));
      
      developer.log('Remote Config settings set', name: 'VoloRemoteConfig');

      // Set default values
      await _remoteConfig.setDefaults({
        'use_mock_flight_data': RemoteConfigDefaults.useMockFlightData,
      });
      
      developer.log('Remote Config defaults set: use_mock_flight_data = ${RemoteConfigDefaults.useMockFlightData}', name: 'VoloRemoteConfig');

      // Fetch and activate config
      developer.log('Fetching Remote Config from Firebase...', name: 'VoloRemoteConfig');
      final bool activated = await _remoteConfig.fetchAndActivate();
      
      developer.log('Remote Config fetch result: activated = $activated', name: 'VoloRemoteConfig');
      developer.log('Remote Config last fetch time: ${_remoteConfig.lastFetchTime}', name: 'VoloRemoteConfig');
      developer.log('Remote Config last fetch status: ${_remoteConfig.lastFetchStatus}', name: 'VoloRemoteConfig');
      
      _isInitialized = true;
      
      // Log the actual value retrieved
      final actualValue = _remoteConfig.getBool('use_mock_flight_data');
      developer.log('Remote Config initialized successfully', name: 'VoloRemoteConfig');
      developer.log('use_mock_flight_data from Firebase: $actualValue', name: 'VoloRemoteConfig');
      
      // Log all available parameters for debugging
      final allParameters = _remoteConfig.getAll();
      developer.log('All Remote Config parameters: $allParameters', name: 'VoloRemoteConfig');
      
      // Test different ways to get the value
      developer.log('Testing different value retrieval methods:', name: 'VoloRemoteConfig');
      developer.log('getBool: ${_remoteConfig.getBool('use_mock_flight_data')}', name: 'VoloRemoteConfig');
      developer.log('getString: ${_remoteConfig.getString('use_mock_flight_data')}', name: 'VoloRemoteConfig');
      developer.log('getInt: ${_remoteConfig.getInt('use_mock_flight_data')}', name: 'VoloRemoteConfig');
      developer.log('getDouble: ${_remoteConfig.getDouble('use_mock_flight_data')}', name: 'VoloRemoteConfig');
      
    } catch (e) {
      developer.log('Remote Config initialization failed: $e', name: 'VoloRemoteConfig');
      developer.log('Stack trace: ${StackTrace.current}', name: 'VoloRemoteConfig');
      // Continue with default values
      _isInitialized = true;
    }
  }

  /// Get the use_mock_flight_data parameter value
  /// Returns true if mock data should be used, false for real API
  bool getUseMockFlightData() {
    try {
      if (!_isInitialized) {
        developer.log('Remote Config not initialized, using default value', name: 'VoloRemoteConfig');
        return RemoteConfigDefaults.useMockFlightData;
      }
      
      // Try multiple ways to get the value
      final boolValue = _remoteConfig.getBool('use_mock_flight_data');
      final stringValue = _remoteConfig.getString('use_mock_flight_data');
      
      developer.log('Remote Config: use_mock_flight_data = $boolValue', name: 'VoloRemoteConfig');
      developer.log('Remote Config string value: $stringValue', name: 'VoloRemoteConfig');
      
      // Log all parameters for debugging
      final allParams = _remoteConfig.getAll();
      developer.log('All Remote Config parameters: $allParams', name: 'VoloRemoteConfig');
      
      // Log the actual value type and source
      developer.log('Value type: ${boolValue.runtimeType}', name: 'VoloRemoteConfig');
      developer.log('Default value: ${RemoteConfigDefaults.useMockFlightData}', name: 'VoloRemoteConfig');
      
      // Check if the parameter exists in the config
      if (allParams.containsKey('use_mock_flight_data')) {
        developer.log('Parameter exists in config: ${allParams['use_mock_flight_data']}', name: 'VoloRemoteConfig');
      } else {
        developer.log('Parameter NOT found in config!', name: 'VoloRemoteConfig');
      }
      
      return boolValue;
    } catch (e) {
      developer.log('Error getting use_mock_flight_data, using default: $e', name: 'VoloRemoteConfig');
      return RemoteConfigDefaults.useMockFlightData;
    }
  }

  /// Force refresh remote config values
  Future<void> refresh() async {
    try {
      developer.log('Forcing Remote Config refresh...', name: 'VoloRemoteConfig');
      final bool activated = await _remoteConfig.fetchAndActivate();
      developer.log('Remote Config refresh result: activated = $activated', name: 'VoloRemoteConfig');
      developer.log('use_mock_flight_data after refresh: ${getUseMockFlightData()}', name: 'VoloRemoteConfig');
      
      // Log all parameters after refresh
      final allParams = _remoteConfig.getAll();
      developer.log('All parameters after refresh: $allParams', name: 'VoloRemoteConfig');
    } catch (e) {
      developer.log('Remote Config refresh failed: $e', name: 'VoloRemoteConfig');
    }
  }

  /// Check if remote config is initialized
  bool get isInitialized => _isInitialized;

  /// Get all current config values for debugging
  Map<String, dynamic> getAllConfigValues() {
    if (!_isInitialized) {
      return {
        'use_mock_flight_data': RemoteConfigDefaults.useMockFlightData,
        'status': 'not_initialized',
      };
    }

    try {
      final allParams = _remoteConfig.getAll();
      return {
        'use_mock_flight_data': getUseMockFlightData(),
        'status': 'initialized',
        'last_fetch_time': _remoteConfig.lastFetchTime?.toIso8601String(),
        'last_fetch_status': _remoteConfig.lastFetchStatus.toString(),
        'all_parameters': allParams,
        'default_value': RemoteConfigDefaults.useMockFlightData,
        'string_value': _remoteConfig.getString('use_mock_flight_data'),
        'parameter_exists': allParams.containsKey('use_mock_flight_data'),
      };
    } catch (e) {
      return {
        'use_mock_flight_data': RemoteConfigDefaults.useMockFlightData,
        'status': 'error_getting_values',
        'error': e.toString(),
      };
    }
  }
} 