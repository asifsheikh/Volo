import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:developer' as developer;

import '../../../../theme/app_theme.dart';
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
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers and state variables
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+91'; // Default to India
  String? _verificationId;
  bool _hasAttemptedSubmission = false; // Track if user has tried to submit

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
  bool get _isPhoneNumberValid {
    final phoneNumber = _phoneController.text.trim();
    // Basic validation: at least 10 digits for most countries
    return phoneNumber.length >= 10 && phoneNumber.length <= 15;
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
    // Set flag that user has attempted submission
    setState(() {
      _hasAttemptedSubmission = true;
    });

    // Validate phone number input
    if (_phoneController.text.isEmpty) {
      // Show error via Riverpod state
      return;
    }

    try {
      // Clear any existing errors before starting
      ref.read(authNotifierProvider).clearError();

      // Format phone number and country code
      String formattedCountryCode = _countryCode.trim();
      String formattedNumber = _phoneController.text.trim();

      // Clean up the phone number - remove any + signs
      if (formattedNumber.startsWith('+')) {
        formattedNumber = formattedNumber.substring(1);
      }

      // Clean up the country code - remove any + signs
      if (formattedCountryCode.startsWith('+')) {
        formattedCountryCode = formattedCountryCode.substring(1);
      }

      // Ensure we have a valid country code
      if (formattedCountryCode.isEmpty) {
        formattedCountryCode = '91'; // Default to India
      }

      String fullPhoneNumber = '+$formattedCountryCode$formattedNumber';

      developer.log('LoginScreen: Sending OTP for phone: $fullPhoneNumber', name: 'LoginScreen');

      // Send OTP via Riverpod
      final verificationId = await ref.read(authNotifierProvider).sendOTP(
        phoneNumber: fullPhoneNumber,
      );

      developer.log('LoginScreen: OTP result - verificationId: $verificationId', name: 'LoginScreen');

      // If successful, navigate to OTP screen
      if (mounted && verificationId != null) {
        developer.log('LoginScreen: Navigating to OTP screen', name: 'LoginScreen');
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
      } else {
        developer.log('LoginScreen: OTP sending failed - verificationId is null', name: 'LoginScreen');
      }
    } catch (e) {
      // Error handling is done via Riverpod state
      developer.log('Error in _onContinue: $e', name: 'LoginScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state from Riverpod
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content - centered
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Login illustration
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/welcome.png',
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 24),
                      // Phone input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntlPhoneField(
                              controller: _phoneController,
                              initialCountryCode: 'IN',
                              decoration: AppTheme.inputDecoration.copyWith(
                                labelText: 'Phone number',
                                errorText: (error != null && _hasAttemptedSubmission && !isLoading) ? error : null,
                                errorStyle: const TextStyle(color: AppTheme.destructive),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: (error != null && _hasAttemptedSubmission && !isLoading)
                                        ? AppTheme.destructive
                                        : AppTheme.borderPrimary,
                                  ),
                                ),
                              ),
                              onChanged: (phone) {
                                setState(() {
                                  // Store country code without + sign
                                  _countryCode = phone.countryCode.replaceAll('+', '');
                                  if (_phoneController.text.isNotEmpty) {
                                    // Clear error when user types
                                    ref.read(authNotifierProvider).clearError();
                                  }
                                });
                              },
                              onCountryChanged: (country) {
                                setState(() {
                                  // Store country code without + sign
                                  _countryCode = country.dialCode.replaceAll('+', '');
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Continue Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: SizedBox(
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
              ),
            ),
            // Terms/Privacy at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 24.0, right: 24.0),
              child: Text.rich(
                TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  children: [
                    TextSpan(
                      text: 'Terms',
                      style: AppTheme.linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          developer.log('Navigate to Terms screen', name: 'LoginScreen');
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: AppTheme.linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          developer.log('Navigate to Privacy Policy screen', name: 'LoginScreen');
                        },
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 