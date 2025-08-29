import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

enum NetworkErrorType {
  noInternet,
  serverError,
  timeout,
  unauthorized,
  notFound,
  unknown,
}

class NetworkError {
  final NetworkErrorType type;
  final String message;
  final int? statusCode;
  final Exception? originalException;

  NetworkError({
    required this.type,
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() {
    return 'NetworkError(type: $type, message: $message, statusCode: $statusCode)';
  }
}

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  /// Stream of connection status changes
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;

  /// Initialize network monitoring
  Future<void> initialize() async {
    try {
      // Get initial connectivity status
      final results = await _connectivity.checkConnectivity();
      final isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
      _updateConnectionStatus(isConnected);

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
        final isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
        _updateConnectionStatus(isConnected);
      });

      developer.log('NetworkService: Initialized successfully', name: 'VoloNetwork');
    } catch (e) {
      developer.log('NetworkService: Initialization failed: $e', name: 'VoloNetwork');
    }
  }

  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectionStatusController.add(isConnected);
      developer.log('NetworkService: Connection status changed to: ${isConnected ? 'Connected' : 'Disconnected'}', name: 'VoloNetwork');
    }
  }

  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      if (!_isConnected) return false;

      // Try to reach a reliable host
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      developer.log('NetworkService: Error checking internet connection: $e', name: 'VoloNetwork');
      return false;
    }
  }

  /// Make an HTTP request with proper error handling
  Future<http.Response> makeRequest(
    Future<http.Response> Function() request, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check connectivity first
      if (!_isConnected) {
        throw NetworkError(
          type: NetworkErrorType.noInternet,
          message: 'No internet connection available',
        );
      }

      // Check actual internet connectivity
      if (!await hasInternetConnection()) {
        throw NetworkError(
          type: NetworkErrorType.noInternet,
          message: 'No internet connection available',
        );
      }

      // Make the request with timeout
      final response = await request().timeout(timeout);
      return response;
    } on SocketException catch (e) {
      developer.log('NetworkService: Socket exception: $e', name: 'VoloNetwork');
      throw NetworkError(
        type: NetworkErrorType.noInternet,
        message: 'Unable to connect to server. Please check your internet connection.',
        originalException: e,
      );
    } on TimeoutException catch (e) {
      developer.log('NetworkService: Timeout exception: $e', name: 'VoloNetwork');
      throw NetworkError(
        type: NetworkErrorType.timeout,
        message: 'Request timed out. Please try again.',
        originalException: e,
      );
    } on NetworkError {
      rethrow;
    } catch (e) {
      developer.log('NetworkService: Unknown error: $e', name: 'VoloNetwork');
      throw NetworkError(
        type: NetworkErrorType.unknown,
        message: 'An unexpected error occurred. Please try again.',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Handle HTTP response and convert to NetworkError if needed
  NetworkError? handleHttpResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return null; // Success
      case 401:
        return NetworkError(
          type: NetworkErrorType.unauthorized,
          message: 'Authentication failed. Please log in again.',
          statusCode: response.statusCode,
        );
      case 404:
        return NetworkError(
          type: NetworkErrorType.notFound,
          message: 'The requested resource was not found.',
          statusCode: response.statusCode,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        developer.log(
          'NetworkService: Server error ${response.statusCode}. Body snippet: ' +
              (response.body.length > 400 ? response.body.substring(0, 400) + '…' : response.body),
          name: 'VoloNetwork',
        );
        return NetworkError(
          type: NetworkErrorType.serverError,
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      default:
        developer.log(
          'NetworkService: HTTP error ${response.statusCode}. Body snippet: ' +
              (response.body.length > 400 ? response.body.substring(0, 400) + '…' : response.body),
          name: 'VoloNetwork',
        );
        return NetworkError(
          type: NetworkErrorType.unknown,
          message: 'An error occurred (${response.statusCode}). Please try again.',
          statusCode: response.statusCode,
        );
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(NetworkError error) {
    switch (error.type) {
      case NetworkErrorType.noInternet:
        return 'No internet connection. Please check your network settings and try again.';
      case NetworkErrorType.serverError:
        return 'Server is temporarily unavailable. Please try again in a few minutes.';
      case NetworkErrorType.timeout:
        return 'Request timed out. Please check your connection and try again.';
      case NetworkErrorType.unauthorized:
        return 'Session expired. Please log in again.';
      case NetworkErrorType.notFound:
        return 'The requested information was not found.';
      case NetworkErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Get retry suggestion based on error type
  String getRetrySuggestion(NetworkError error) {
    switch (error.type) {
      case NetworkErrorType.noInternet:
        return 'Check your Wi-Fi or mobile data connection';
      case NetworkErrorType.serverError:
        return 'Try again in a few minutes';
      case NetworkErrorType.timeout:
        return 'Check your connection speed';
      case NetworkErrorType.unauthorized:
        return 'Log in again to continue';
      case NetworkErrorType.notFound:
        return 'Try different search criteria';
      case NetworkErrorType.unknown:
        return 'Try again or contact support';
    }
  }

  /// Check if error is retryable
  bool isRetryable(NetworkError error) {
    switch (error.type) {
      case NetworkErrorType.noInternet:
      case NetworkErrorType.serverError:
      case NetworkErrorType.timeout:
      case NetworkErrorType.unknown:
        return true;
      case NetworkErrorType.unauthorized:
      case NetworkErrorType.notFound:
        return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
} 