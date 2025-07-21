import '../constants/app_constants.dart';

/// Common validation utilities for the app
class Validators {
  /// Validate phone number format
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid phone number (7-15 digits)
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return AppConstants.invalidPhoneMessage;
    }
    
    return null;
  }

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppConstants.invalidEmailMessage;
    }
    
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName is required' 
          : AppConstants.requiredFieldMessage;
    }
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    if (value.length < 6) {
      return AppConstants.passwordTooShortMessage;
    }
    
    return null;
  }

  /// Validate flight number format
  static String? validateFlightNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Flight number is optional
    }
    
    // Flight number should be 2-6 characters (airline code + numbers)
    final flightRegex = RegExp(r'^[A-Z]{2,3}\d{1,4}$');
    if (!flightRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid flight number (e.g., BA142, EK123)';
    }
    
    return null;
  }

  /// Validate IATA airport code
  static String? validateIataCode(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    // IATA codes are exactly 3 letters
    final iataRegex = RegExp(r'^[A-Z]{3}$');
    if (!iataRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid 3-letter airport code';
    }
    
    return null;
  }

  /// Validate date format (YYYY-MM-DD)
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
    
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      
      // Check if date is in the past
      if (date.isBefore(DateTime(now.year, now.month, now.day))) {
        return 'Date cannot be in the past';
      }
      
      // Check if date is too far in the future (1 year)
      final maxDate = DateTime(now.year + 1, now.month, now.day);
      if (date.isAfter(maxDate)) {
        return 'Date cannot be more than 1 year in the future';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }
    
    return null;
  }

  /// Validate file size
  static String? validateFileSize(int sizeInBytes) {
    if (sizeInBytes > AppConstants.maxProfileImageSize) {
      return 'File size must be less than 5MB';
    }
    return null;
  }

  /// Validate file type
  static String? validateFileType(String fileName) {
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    
    if (!allowedExtensions.contains(extension)) {
      return 'Only JPG, PNG, and PDF files are allowed';
    }
    
    return null;
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }
    
    return phone;
  }

  /// Format currency for display
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Format duration for display
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  /// Sanitize input (remove special characters)
  static String sanitizeInput(String input) {
    return input.replaceAll(RegExp(r'[^\w\s-]'), '');
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
} 