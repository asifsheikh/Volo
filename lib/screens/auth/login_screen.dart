import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'otp_screen.dart';
import '../../services/network_service.dart';
import '../../theme/app_theme.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'dart:developer' as developer;

/// Login Screen for Volo App
///
/// This screen handles phone number input and Firebase phone authentication.
/// Features include:
/// - International phone number input with country code selection
/// - Firebase phone authentication with OTP
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
  String? _errorText;
  String _countryCode = '+91'; // Default to India
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
    // Validate phone number input
    setState(() {
      if (_phoneController.text.isEmpty) {
        _errorText = 'Please enter your phone number';
        return;
      } else {
        _errorText = null;
        _isLoading = true;
      }
    });

    try {
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
      
      // Debug logging
      developer.log('LoginScreen: Attempting to send OTP to: $fullPhoneNumber', name: 'VoloAuth');
      developer.log('LoginScreen: Debug mode: ${kDebugMode}', name: 'VoloAuth');

      // In debug mode, allow test phone numbers
      if (kDebugMode && (formattedNumber == '9999999999' || formattedNumber == '1234567890')) {
        developer.log('LoginScreen: Using test phone number in debug mode', name: 'VoloAuth');
        // For test numbers, we'll simulate a successful OTP send
        setState(() {
          _isLoading = false;
        });
        
        // Navigate to OTP screen with a mock verification ID
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: fullPhoneNumber,
              verificationId: 'test_verification_id_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );
        return;
      }

      // Send OTP via Riverpod Auth Provider
      final authNotifier = ref.read(authNotifierProvider);
      final verificationId = await authNotifier.sendOTP(phoneNumber: fullPhoneNumber);
      
      if (verificationId != null) {
        developer.log('LoginScreen: OTP sent successfully, verificationId: $verificationId', name: 'VoloAuth');
        setState(() {
          _isLoading = false;
        });

        // Navigate to OTP verification screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: fullPhoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      } else {
        // Error occurred, get error from auth state
        final authState = ref.read(authStateProvider);
        setState(() {
          _isLoading = false;
          _errorText = authState.error ?? 'Failed to send OTP. Please try again.';
        });
      }
    } catch (e) {
      developer.log('LoginScreen: General Error: $e', name: 'VoloAuth');
      setState(() {
        _isLoading = false;
        _errorText = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for errors
    final authState = ref.watch(authStateProvider);
    
    // Update error text if auth state has an error
    if (authState.error != null && _errorText != authState.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _errorText = authState.error;
          _isLoading = false;
        });
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // App Icon
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(24),
                        shadowColor: Colors.black.withOpacity(0.08),
                        color: Colors.transparent,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/volo_app_icon.png',
                            width: 72,
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        'Welcome to Volo! ✈️',
                        style: AppTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Text(
                        'Enter your phone number to get started',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Phone input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntlPhoneField(
                              controller: _phoneController,
                              initialCountryCode: 'IN',
                              decoration: InputDecoration(
                                labelText: 'Phone number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _errorText != null ? Colors.red : Colors.transparent,
                                  ),
                                ),
                                errorText: _errorText,
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                              onChanged: (phone) {
                                setState(() {
                                  // Store country code without + sign
                                  _countryCode = phone.countryCode.replaceAll('+', '');
                                  if (_phoneController.text.isNotEmpty) {
                                    _errorText = null;
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
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onContinue,
                                                  style: AppTheme.primaryButton,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Send OTP',
                                    style: AppTheme.titleLarge.copyWith(color: AppTheme.textOnPrimary),
                                  ),
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
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Terms',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
