import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import 'otp_screen.dart';

/// Login Screen for Volo App using Riverpod + Clean Architecture
///
/// This screen handles phone number input and Firebase phone authentication.
/// Features include:
/// - International phone number input with country code selection
/// - Firebase phone authentication with OTP using Riverpod
/// - Comprehensive error handling for production use
/// - User-friendly error messages and loading states
/// - Automatic phone number formatting and validation
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers and state variables
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = 'IN'; // Default to India (country code, not dial code)

  @override
  void initState() {
    super.initState();
    // Clear any stale errors when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider).clearError();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Check if the phone number is valid for enabling the button
  /// Uses country-specific validation to ensure correct digit count
  bool get _isPhoneNumberValid {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) return false;
    
    // Use country-specific validation
    return Validators.isPhoneLengthValidForCountry(phoneNumber, _countryCode);
  }


  /// Custom input formatter to limit digits based on country
  List<TextInputFormatter> get _inputFormatters {
    final maxLength = Validators.getPhoneLengthForCountry(_countryCode);
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  /// Get dial code for a country code
  String _getDialCodeForCountry(String countryCode) {
    const dialCodes = {
      'IN': '+91',
      'US': '+1',
      'CA': '+1',
      'GB': '+44',
      'AU': '+61',
      'DE': '+49',
      'FR': '+33',
      'IT': '+39',
      'ES': '+34',
      'BR': '+55',
      'MX': '+52',
      'JP': '+81',
      'KR': '+82',
      'CN': '+86',
      'RU': '+7',
      'ZA': '+27',
      'NG': '+234',
      'EG': '+20',
      'SA': '+966',
      'AE': '+971',
      'SG': '+65',
      'MY': '+60',
      'TH': '+66',
      'ID': '+62',
      'PH': '+63',
      'VN': '+84',
    };
    return dialCodes[countryCode.toUpperCase()] ?? '+91'; // Default to India
  }

  /// Handles the continue button press and initiates phone authentication
  ///
  /// This method:
  /// 1. Validates the phone number input
  /// 2. Formats the phone number with country code
  /// 3. Calls Firebase phone authentication via Riverpod
  /// 4. Handles all possible outcomes (success, failure, auto-verification)
  /// 5. Shows appropriate user feedback
  Future<void> _onContinue() async {
    // Validate phone number input using country-specific validation
    final validationError = Validators.validatePhone(_phoneController.text, countryCode: _countryCode);
    if (validationError != null) {
      // Phone number validation failed
      return;
    }

    try {
      // Clear any existing errors before starting
      ref.read(authNotifierProvider).clearError();

      // Get the dial code for the selected country
      // We need to get the actual dial code (like +91, +1, etc.) from the IntlPhoneField
      // For now, we'll use a simple mapping or get it from the phone field
      String dialCode = _getDialCodeForCountry(_countryCode);
      String formattedNumber = _phoneController.text.trim();

      // Clean up the phone number - remove any non-digit characters
      formattedNumber = formattedNumber.replaceAll(RegExp(r'[^\d]'), '');

      String fullPhoneNumber = '$dialCode$formattedNumber';

      // Send OTP via Riverpod
      final verificationId = await ref.read(authNotifierProvider).sendOTP(
        phoneNumber: fullPhoneNumber,
      );

      // If successful, navigate to OTP screen
      if (mounted && verificationId != null) {
        // Clear any errors before navigation since we're successful
        ref.read(authNotifierProvider).clearError();
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: fullPhoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      }
    } catch (e) {
      // Error handling is done via Riverpod state
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state from Riverpod
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back button at top
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // Rounded corner illustration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 200, // 3:2 aspect ratio maintained
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/welcome.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Content below illustration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    // Main text (Welcome to Volo) - at center
                    Text(
                      'Welcome to Volo! ✈️',
                      style: AppTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your phone number to get started',
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Phone input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntlPhoneField(
                          controller: _phoneController,
                          initialCountryCode: 'IN',
                          validator: (phone) => null, // Always return null (no validation)
                          invalidNumberMessage: '', // Empty error message
                          inputFormatters: _inputFormatters, // Limit input length based on country
                          decoration: AppTheme.inputDecoration.copyWith(
                            labelText: 'Phone number',
                            errorText: null, // Never show error text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.borderPrimary,
                              ),
                            ),
                          ),
                          onChanged: (phone) {
                            setState(() {
                              // Store country code (like 'IN', 'US', etc.)
                              _countryCode = phone.countryISOCode;
                              if (_phoneController.text.isNotEmpty) {
                                // Clear auth errors when user types, but keep validation errors
                                ref.read(authNotifierProvider).clearError();
                              }
                            });
                          },
                          onCountryChanged: (country) {
                            setState(() {
                              // Store country code (like 'IN', 'US', etc.)
                              _countryCode = country.code;
                              // Clear the phone number when country changes to avoid confusion
                              _phoneController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (isLoading || !_isPhoneNumberValid) ? null : _onContinue,
                        style: (isLoading || !_isPhoneNumberValid)
                            ? AppTheme.disabledButton
                            : AppTheme.primaryButton,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textOnPrimary),
                                ),
                              )
                            : const Text('Send OTP'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Info Text
                    Text(
                      "We'll send a verification code to your phone number",
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 