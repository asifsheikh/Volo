import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'otp_screen.dart';
import '../../services/network_service.dart';
import '../../theme/app_theme.dart';
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
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers and state variables
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText;
  String _countryCode = '+91'; // Default to India
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }





  /// Converts Firebase error codes to user-friendly error messages
  ///
  /// This method handles all possible Firebase authentication error codes
  /// and provides clear, actionable error messages for users.
  ///
  /// [e] - The FirebaseAuthException containing the error details
  /// Returns a user-friendly error message string
  String _getUserFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
    // Phone number validation errors
      case 'invalid-phone-number':
        return 'Please enter a valid phone number';

    // Rate limiting and quota errors
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again';
      case 'quota-exceeded':
        return 'Service temporarily unavailable. Please try again later';

    // App verification and reCAPTCHA errors
      case 'missing-activity-for-recaptcha':
        return 'App verification failed. Please try again';
      case 'invalid-app-credential':
        return 'App verification failed. Please try again';

    // Network and connectivity errors
      case 'network-request-failed':
        return 'No internet connection. Please check your network settings and try again.';

    // Firebase configuration errors
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support';
      case 'app-not-authorized':
        return 'App not authorized. Please update the app or contact support';

    // Verification code errors (for OTP screen)
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again';
      case 'session-expired':
        return 'Session expired. Please try again';
      case 'invalid-verification-id':
        return 'Verification failed. Please try again';

    // User account errors
      case 'user-disabled':
        return 'This account has been disabled. Please contact support';
      case 'user-not-found':
        return 'User not found. Please check your phone number';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this phone number';
      case 'requires-recent-login':
        return 'Please log in again to continue';

    // Credential errors
      case 'invalid-credential':
        return 'Invalid credentials. Please try again';
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'invalid-email':
        return 'Invalid email address';

    // Operation and timeout errors
      case 'operation-cancelled':
        return 'Operation was cancelled';
      case 'timeout':
        return 'Request timed out. Please try again';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later';

    // System and internal errors
      case 'internal-error':
        return 'An internal error occurred. Please try again';
      case 'invalid-argument':
        return 'Invalid input. Please check your phone number';
      case 'not-found':
        return 'Service not found. Please try again';
      case 'already-exists':
        return 'Account already exists';
      case 'permission-denied':
        return 'Permission denied. Please try again';
      case 'resource-exhausted':
        return 'Service limit reached. Please try again later';
      case 'failed-precondition':
        return 'Operation failed. Please try again';
      case 'aborted':
        return 'Operation was aborted. Please try again';
      case 'out-of-range':
        return 'Input out of range. Please check your phone number';
      case 'unimplemented':
        return 'Feature not implemented. Please contact support';
      case 'data-loss':
        return 'Data loss occurred. Please try again';
      case 'unauthenticated':
        return 'Authentication required. Please try again';

      default:
      // Handle specific error messages in the exception
        if (e.message?.contains('BILLING_NOT_ENABLED') == true) {
          return 'Phone authentication is not enabled for this project. Please contact support.';
        }
        if (e.message?.contains('Invalid app info') == true) {
          return 'App verification failed. Please try again.';
        }
        if (e.message?.contains('rate limit') == true || e.message?.contains('too many requests') == true) {
          return 'Too many requests. Please wait a few minutes and try again.';
        }
              if (e.message?.contains('network') == true || e.message?.contains('connection') == true) {
        return 'No internet connection. Please check your network settings and try again.';
      }

      // Generic error message for unknown errors
        return 'Failed to send OTP. Please try again.';
    }
  }

  /// Handles the continue button press and initiates phone authentication
  ///
  /// This method:
  /// 1. Validates the phone number input
  /// 2. Formats the phone number with country code
  /// 3. Calls Firebase phone authentication
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
      developer.log('LoginScreen: Firebase Auth instance: ${_auth.app.name}', name: 'VoloAuth');
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

      // Send OTP via Firebase Phone Authentication
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,

        // Auto-verification callback (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          developer.log('LoginScreen: Auto-verification completed', name: 'VoloAuth');
          // Auto-verification if SMS is not required (e.g., test numbers)
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => OtpScreen(
                  phoneNumber: fullPhoneNumber,
                  verificationId: null, // Auto-verified
                ),
              ),
            );
          }
        },

        // Error handling callback
        verificationFailed: (FirebaseAuthException e) {
          developer.log('LoginScreen: Verification failed - Code: ${e.code}, Message: ${e.message}', name: 'VoloAuth');
          setState(() {
            _isLoading = false;
            _errorText = _getUserFriendlyErrorMessage(e);
          });
        },

        // Success callback - OTP sent successfully
        codeSent: (String verificationId, int? resendToken) {
          developer.log('LoginScreen: OTP sent successfully, verificationId: $verificationId', name: 'VoloAuth');
          setState(() {
            _isLoading = false;
          });

          // Success - no snack bar needed

          // Navigate to OTP verification screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                phoneNumber: fullPhoneNumber,
                verificationId: verificationId,
              ),
            ),
          );
        },

        // Auto-retrieval timeout callback
        codeAutoRetrievalTimeout: (String verificationId) {
          developer.log('LoginScreen: Auto-retrieval timeout', name: 'VoloAuth');
          setState(() {
            _isLoading = false;
          });

          // Show timeout message to user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Auto-retrieval timeout. Please enter the code manually.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        },

        timeout: const Duration(seconds: 60), // 60 second timeout
      );
    } on FirebaseAuthException catch (e) {
      developer.log('LoginScreen: FirebaseAuthException - Code: ${e.code}, Message: ${e.message}', name: 'VoloAuth');
      setState(() {
        _isLoading = false;
        _errorText = _getUserFriendlyErrorMessage(e);
      });
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
