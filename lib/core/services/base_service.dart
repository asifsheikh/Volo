import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/base_model.dart';
import '../../services/network_service.dart';

/// Base class for all API services
/// Provides common functionality like:
/// - HTTP request handling
/// - Error handling
/// - Response parsing
/// - Authentication
abstract class BaseService {
  final NetworkService _networkService = NetworkService();
  final String _baseUrl;

  BaseService(this._baseUrl);

  /// Make a GET request
  Future<ApiResponse<T>> get<T extends BaseModel>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _networkService.makeRequest(
        () => http.get(uri, headers: headers),
        timeout: AppConstants.apiTimeout,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Make a POST request
  Future<ApiResponse<T>> post<T extends BaseModel>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _networkService.makeRequest(
        () => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
          body: body != null ? json.encode(body) : null,
        ),
        timeout: AppConstants.apiTimeout,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Make a PUT request
  Future<ApiResponse<T>> put<T extends BaseModel>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _networkService.makeRequest(
        () => http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
          body: body != null ? json.encode(body) : null,
        ),
        timeout: AppConstants.apiTimeout,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Make a DELETE request
  Future<ApiResponse<T>> delete<T extends BaseModel>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _networkService.makeRequest(
        () => http.delete(uri, headers: headers),
        timeout: AppConstants.apiTimeout,
      );

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T extends BaseModel>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null && data['data'] != null) {
        return ApiResponse.success(fromJson(data['data']));
      } else if (fromJson != null) {
        return ApiResponse.success(fromJson(data));
      } else {
        return ApiResponse.success(data as T);
      }
    } else {
      return ApiResponse.error(
        data['error'] ?? 'HTTP ${response.statusCode}',
        message: data['message'],
      );
    }
  }

  /// Get authentication headers
  Map<String, String> getAuthHeaders() {
    // TODO: Implement authentication token retrieval
    return {
      'Authorization': 'Bearer YOUR_TOKEN_HERE',
    };
  }

  /// Add query parameters to URL
  String addQueryParams(String url, Map<String, dynamic> params) {
    if (params.isEmpty) return url;
    
    final uri = Uri.parse(url);
    final queryParams = Map<String, String>.from(uri.queryParameters);
    
    params.forEach((key, value) {
      if (value != null) {
        queryParams[key] = value.toString();
      }
    });
    
    return uri.replace(queryParameters: queryParams).toString();
  }
}

/// Base class for paginated API services
abstract class PaginatedService<T extends BaseModel> extends BaseService {
  PaginatedService(String baseUrl) : super(baseUrl);

  /// Get paginated data
  Future<PaginatedResponse<T>> getPaginated(
    String endpoint, {
    int page = 1,
    int limit = 10,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final params = {
        'page': page,
        'limit': limit,
      };
      
      final url = addQueryParams('$_baseUrl$endpoint', params);
      final uri = Uri.parse(url);
      
      final response = await _networkService.makeRequest(
        () => http.get(uri, headers: headers),
        timeout: AppConstants.apiTimeout,
      );

      return _handlePaginatedResponse(response, fromJson);
    } catch (e) {
      return PaginatedResponse.error(e.toString());
    }
  }

  /// Handle paginated response
  PaginatedResponse<T> _handlePaginatedResponse(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null) {
        return PaginatedResponse.fromJson(data, fromJson);
      } else {
        return PaginatedResponse.fromJson(data, (json) => json as T);
      }
    } else {
      return PaginatedResponse.error(
        data['error'] ?? 'HTTP ${response.statusCode}',
        message: data['message'],
      );
    }
  }
} 