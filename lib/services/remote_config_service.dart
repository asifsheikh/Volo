import 'package:firebase_remote_config/firebase_remote_config.dart';
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
        // Add future remote config parameters here
      });
      
      developer.log('Remote Config defaults set', name: 'VoloRemoteConfig');

      // Fetch and activate config
      developer.log('Fetching Remote Config from Firebase...', name: 'VoloRemoteConfig');
      final bool activated = await _remoteConfig.fetchAndActivate();
      
      developer.log('Remote Config fetch result: activated = $activated', name: 'VoloRemoteConfig');
      developer.log('Remote Config last fetch time: ${_remoteConfig.lastFetchTime}', name: 'VoloRemoteConfig');
      developer.log('Remote Config last fetch status: ${_remoteConfig.lastFetchStatus}', name: 'VoloRemoteConfig');
      
      _isInitialized = true;
      
      developer.log('Remote Config initialized successfully', name: 'VoloRemoteConfig');
      
      // Log all available parameters for debugging
      final allParameters = _remoteConfig.getAll();
      developer.log('All Remote Config parameters: $allParameters', name: 'VoloRemoteConfig');
      
    } catch (e) {
      developer.log('Remote Config initialization failed: $e', name: 'VoloRemoteConfig');
      developer.log('Stack trace: ${StackTrace.current}', name: 'VoloRemoteConfig');
      // Continue with default values
      _isInitialized = true;
    }
  }



  /// Force refresh remote config values
  Future<void> refresh() async {
    try {
      developer.log('Forcing Remote Config refresh...', name: 'VoloRemoteConfig');
      final bool activated = await _remoteConfig.fetchAndActivate();
      developer.log('Remote Config refresh result: activated = $activated', name: 'VoloRemoteConfig');
      
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
        'status': 'not_initialized',
      };
    }

    try {
      final allParams = _remoteConfig.getAll();
      return {
        'status': 'initialized',
        'last_fetch_time': _remoteConfig.lastFetchTime?.toIso8601String() ?? 'never',
        'last_fetch_status': _remoteConfig.lastFetchStatus.toString(),
        'all_parameters': allParams,
      };
    } catch (e) {
      return {
        'status': 'error_getting_values',
        'error': e.toString(),
      };
    }
  }
  
  /// Get clean config values for UI display (read-only)
  Map<String, dynamic> getDisplayConfigValues() {
    if (!_isInitialized) {
      return {
        'status': 'not_initialized',
      };
    }

    try {
      return {
        'status': 'initialized',
        'last_fetch_time': _remoteConfig.lastFetchTime?.toIso8601String() ?? 'never',
      };
    } catch (e) {
      return {
        'status': 'error_getting_values',
      };
    }
  }
} 