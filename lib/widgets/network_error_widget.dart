import 'package:flutter/material.dart';
import '../services/network_service.dart';

class NetworkErrorWidget extends StatelessWidget {
  final NetworkError error;
  final VoidCallback? onRetry;
  final String? customTitle;
  final String? customMessage;

  const NetworkErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.customTitle,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final networkService = NetworkService();
    final title = customTitle ?? _getErrorTitle(error);
    final message = customMessage ?? networkService.getUserFriendlyMessage(error);
    final suggestion = networkService.getRetrySuggestion(error);
    final isRetryable = networkService.isRetryable(error);

    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getErrorColor(error).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getErrorIcon(error),
                    size: 48,
                    color: _getErrorColor(error),
                  ),
                ),
                const SizedBox(height: 24),

                // Error Title
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Error Message
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Suggestion
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        suggestion,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                if (isRetryable && onRetry != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059393),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Back Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorTitle(NetworkError error) {
    switch (error.type) {
      case NetworkErrorType.noInternet:
        return 'No Internet Connection';
      case NetworkErrorType.serverError:
        return 'Server Error';
      case NetworkErrorType.timeout:
        return 'Connection Timeout';
      case NetworkErrorType.unauthorized:
        return 'Authentication Error';
      case NetworkErrorType.notFound:
        return 'No Results Found';
      case NetworkErrorType.unknown:
        return 'Something Went Wrong';
    }
  }

  IconData _getErrorIcon(NetworkError error) {
    switch (error.type) {
      case NetworkErrorType.noInternet:
        return Icons.wifi_off;
      case NetworkErrorType.serverError:
        return Icons.error_outline;
      case NetworkErrorType.timeout:
        return Icons.timer_off;
      case NetworkErrorType.unauthorized:
        return Icons.lock_outline;
      case NetworkErrorType.notFound:
        return Icons.search_off;
      case NetworkErrorType.unknown:
        return Icons.help_outline;
    }
  }

  Color _getErrorColor(NetworkError error) {
    switch (error.type) {
      case NetworkErrorType.noInternet:
        return const Color(0xFFEF4444); // Red
      case NetworkErrorType.serverError:
        return const Color(0xFFF59E0B); // Orange
      case NetworkErrorType.timeout:
        return const Color(0xFF8B5CF6); // Purple
      case NetworkErrorType.unauthorized:
        return const Color(0xFFDC2626); // Dark Red
      case NetworkErrorType.notFound:
        return const Color(0xFF6B7280); // Gray
      case NetworkErrorType.unknown:
        return const Color(0xFF059393); // Teal
    }
  }
} 