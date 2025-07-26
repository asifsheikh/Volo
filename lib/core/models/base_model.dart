/// Base class for all data models in the app
/// Provides common functionality like:
/// - JSON serialization/deserialization
/// - Equality comparison
/// - Copy with modifications
/// - Validation
abstract class BaseModel {
  /// Convert model to JSON
  Map<String, dynamic> toJson();

  /// Create model from JSON
  static T fromJson<T extends BaseModel>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }

  /// Validate model data
  bool isValid();

  /// Get validation errors
  List<String> getValidationErrors();

  /// Create a copy of the model with modifications
  T copyWith<T extends BaseModel>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.toJson() == toJson();
  }

  @override
  int get hashCode => toJson().hashCode;

  @override
  String toString() {
    return '${runtimeType}(toJson: ${toJson()})';
  }
}

/// Base class for API response models
abstract class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String error, {String? message}) {
    return ApiResponse(
      success: false,
      error: error,
      message: message,
    );
  }

  Map<String, dynamic> toJson();
}

/// Base class for paginated responses
abstract class PaginatedResponse<T> extends ApiResponse<List<T>> {
  final int page;
  final int limit;
  final int total;
  final bool hasNext;
  final bool hasPrevious;

  const PaginatedResponse({
    required super.success,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasNext,
    required this.hasPrevious,
    super.data,
    super.message,
    super.error,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      success: json['success'] ?? false,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList() ?? [],
      message: json['message'],
      error: json['error'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'page': page,
      'limit': limit,
      'total': total,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
      'data': data?.map((item) => (item as BaseModel).toJson()).toList(),
      'message': message,
      'error': error,
    };
  }
} 