import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_screen.dart';
import 'dart:developer' as developer;
import 'dart:async';

/// OTP Verification Screen for Volo App
/// 
/// This screen handles OTP verification for Firebase phone authentication.
/// Features include:
/// - 6-digit OTP input with auto-focus and formatting
/// - Automatic OTP verification on completion
/// - Resend OTP functionality with countdown timer
/// - Comprehensive error handling for production use
/// - User-friendly error messages and loading states
/// - Auto-verification support for test numbers
class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? verificationId;
  const OtpScreen({Key? key, required this.phoneNumber, this.verificationId}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // State variables for OTP handling
  String _otp = '';
  String? _errorText;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentVerificationId;
  bool _canResend = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    // Initialize verification ID from widget
    _currentVerificationId = widget.verificationId;
    developer.log('OtpScreen: Initialized', name: 'VoloAuth');
    developer.log('  - Phone number: ${widget.phoneNumber}', name: 'VoloAuth');
    developer.log('  - Verification ID: ${widget.verificationId}', name: 'VoloAuth');
  }

  /// Converts Firebase error codes to user-friendly error messages
  /// 
  /// This method handles all possible Firebase authentication error codes
  /// specific to OTP verification and provides clear, actionable messages.
  /// 
  /// [e] - The FirebaseAuthException containing the error details
  /// Returns a user-friendly error message string
  String _getUserFriendlyErrorMessage(FirebaseAuthException e) {
    developer.log('OtpScreen: Getting user-friendly error message for code: ${e.code}', name: 'VoloAuth');
    
    switch (e.code) {
      // OTP verification specific errors
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check the code and try again';
      case 'session-expired':
        return 'OTP session expired. Please request a new code';
      case 'invalid-verification-id':
        return 'Verification session expired. Please try again';
      
      // Rate limiting and quota errors
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again';
      case 'quota-exceeded':
        return 'Service temporarily unavailable. Please try again later';
      
      // Network and connectivity errors
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      
      // Firebase configuration errors
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support';
      case 'app-not-authorized':
        return 'App not authorized. Please update the app or contact support';
      case 'invalid-app-credential':
        return 'App verification failed. Please try again';
      
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
        return 'Invalid input. Please check your OTP';
      case 'not-found':
        return 'Service not found. Please try again';
      case 'permission-denied':
        return 'Permission denied. Please try again';
      case 'resource-exhausted':
        return 'Service limit reached. Please try again later';
      case 'failed-precondition':
        return 'Operation failed. Please try again';
      case 'aborted':
        return 'Operation was aborted. Please try again';
      case 'unimplemented':
        return 'Feature not implemented. Please contact support';
      case 'data-loss':
        return 'Data loss occurred. Please try again';
      case 'unauthenticated':
        return 'Authentication required. Please try again';
      
      default:
        // Handle specific error messages in the exception
        if (e.message?.contains('Invalid app info') == true) {
          return 'App verification failed. Please try again.';
        }
        if (e.message?.contains('rate limit') == true || e.message?.contains('too many requests') == true) {
          return 'Too many requests. Please wait a few minutes and try again.';
        }
        if (e.message?.contains('network') == true || e.message?.contains('connection') == true) {
          return 'Network error. Please check your internet connection and try again.';
        }
        
        // Generic error message for unknown errors
        return 'Verification failed. Please try again.';
    }
  }

  /// Starts the resend OTP countdown timer
  /// 
  /// This method initializes a 60-second countdown timer that prevents
  /// users from spamming the resend button and helps with rate limiting.
  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60; // 60 seconds countdown
    });
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        
        if (_resendCountdown <= 0) {
          setState(() {
            _canResend = true;
          });
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Handles OTP verification when user enters the 6-digit code
  /// 
  /// This method:
  /// 1. Validates that a 6-digit OTP has been entered
  /// 2. Creates a PhoneAuthCredential with the OTP
  /// 3. Signs in the user with Firebase
  /// 4. Handles success and error cases
  /// 5. Shows appropriate user feedback
  Future<void> _onVerify() async {
    developer.log('OtpScreen: Verify button pressed', name: 'VoloAuth');
    developer.log('  - OTP length: ${_otp.length}', name: 'VoloAuth');
    developer.log('  - OTP value: $_otp', name: 'VoloAuth');
    
    setState(() {
      if (_otp.length != 6) {
        _errorText = 'Please enter the 6-digit code';
        developer.log('OtpScreen: OTP length is not 6 digits', name: 'VoloAuth');
        return;
      } else {
        _errorText = null;
        _isLoading = true;
      }
    });

    try {
      // Get the verification ID for this session
      String verificationId = _currentVerificationId ?? widget.verificationId ?? '';
      developer.log('OtpScreen: Verification details:', name: 'VoloAuth');
      developer.log('  - Current verification ID: $_currentVerificationId', name: 'VoloAuth');
      developer.log('  - Widget verification ID: ${widget.verificationId}', name: 'VoloAuth');
      developer.log('  - Final verification ID: $verificationId', name: 'VoloAuth');
      
      // Handle auto-verification case (test phone numbers)
      if (verificationId.isEmpty) {
        developer.log('OtpScreen: No verification ID, proceeding to onboarding (auto-verified)', name: 'VoloAuth');
        // Auto-verified case, proceed to onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(phoneNumber: widget.phoneNumber),
          ),
        );
        return;
      }

      // Create PhoneAuthCredential with OTP
      developer.log('OtpScreen: Creating PhoneAuthCredential', name: 'VoloAuth');
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _otp,
      );
      developer.log('OtpScreen: Credential created successfully', name: 'VoloAuth');

      // Sign in with Firebase using the credential
      developer.log('OtpScreen: Attempting to sign in with credential', name: 'VoloAuth');
      await _auth.signInWithCredential(credential);
      developer.log('OtpScreen: Sign in successful', name: 'VoloAuth');
      
      // Show success message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to onboarding screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(phoneNumber: widget.phoneNumber),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      developer.log('OtpScreen: FirebaseAuthException occurred', name: 'VoloAuth');
      developer.log('  - Error code: ${e.code}', name: 'VoloAuth');
      developer.log('  - Error message: ${e.message}', name: 'VoloAuth');
      developer.log('  - Error details: ${e.toString()}', name: 'VoloAuth');
      
      setState(() {
        _isLoading = false;
        _errorText = _getUserFriendlyErrorMessage(e);
      });
      
      // Show error snackbar for critical errors with resend option
      if (e.code == 'session-expired' || e.code == 'invalid-verification-id') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorText!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: _canResend ? SnackBarAction(
              label: 'Resend',
              textColor: Colors.white,
              onPressed: _resendOTP,
            ) : null,
          ),
        );
      }
    } catch (e) {
      // Handle any unexpected exceptions
      developer.log('OtpScreen: General exception occurred', name: 'VoloAuth');
      developer.log('  - Exception: $e', name: 'VoloAuth');
      developer.log('  - Exception type: ${e.runtimeType}', name: 'VoloAuth');
      
      setState(() {
        _isLoading = false;
        _errorText = 'An unexpected error occurred. Please try again.';
      });
      
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Column(
            children: [
              // Back button with proper top padding for status bar
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0, 
                  top: MediaQuery.of(context).padding.top > 0 ? 8.0 : 16.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 30,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
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
                      const Text(
                        'Enter the code',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          height: 30 / 24,
                          color: Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        "We've sent a 6-digit code to\n${widget.phoneNumber}",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color(0xFF4B5563),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // OTP input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            PinCodeTextField(
                              appContext: context,
                              length: 6,
                              onChanged: (value) {
                                setState(() {
                                  _otp = value;
                                  if (_otp.length == 6) _errorText = null;
                                });
                              },
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(12),
                                fieldHeight: 48,
                                fieldWidth: 48,
                                activeColor: _errorText != null ? Colors.red : const Color(0xFF9CA3AF),
                                selectedColor: const Color(0xFF1F2937),
                                inactiveColor: const Color(0xFF9CA3AF),
                                activeFillColor: Colors.white,
                                selectedFillColor: Colors.white,
                                inactiveFillColor: Colors.white,
                                borderWidth: 2,
                              ),
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.fade,
                              enableActiveFill: true,
                              cursorColor: const Color(0xFF1F2937),
                            ),
                            if (_errorText != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _errorText!,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Verify Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F2937),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Colors.black.withOpacity(0.1),
                              elevation: 8,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Verify',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                      height: 22 / 18,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Info Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive the code? ",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          if (_canResend)
                            GestureDetector(
                              onTap: _resendOTP,
                              child: const Text(
                                'Resend',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Resend in $_resendCountdown',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Change number
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Change number',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF1F2937),
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
              child: const Text.rich(
                TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  /// Handles resend OTP functionality
  /// 
  /// This method:
  /// 1. Validates that countdown timer has finished
  /// 2. Calls Firebase to resend OTP
  /// 3. Handles success and error cases
  /// 4. Restarts countdown timer
  Future<void> _resendOTP() async {
    developer.log('OtpScreen: Resend OTP button pressed', name: 'VoloAuth');
    developer.log('  - Phone number: ${widget.phoneNumber}', name: 'VoloAuth');
    
    // Check if resend is allowed (countdown finished)
    if (!_canResend) {
      developer.log('OtpScreen: Resend blocked - countdown active', name: 'VoloAuth');
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
        _errorText = null;
      });

      // Call Firebase to resend OTP
      developer.log('OtpScreen: Calling Firebase verifyPhoneNumber for resend', name: 'VoloAuth');
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        // Auto-verification callback (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          developer.log('OtpScreen: Resend - Auto-verification completed', name: 'VoloAuth');
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => OnboardingScreen(phoneNumber: widget.phoneNumber),
              ),
            );
          }
        },
        // Error handling callback
        verificationFailed: (FirebaseAuthException e) {
          developer.log('OtpScreen: Resend - Verification failed', name: 'VoloAuth');
          developer.log('  - Error code: ${e.code}', name: 'VoloAuth');
          developer.log('  - Error message: ${e.message}', name: 'VoloAuth');
          developer.log('  - Error details: ${e.toString()}', name: 'VoloAuth');
          
          setState(() {
            _isLoading = false;
            _errorText = _getUserFriendlyErrorMessage(e);
          });
          
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorText!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        },
        // Success callback - OTP resent successfully
        codeSent: (String verificationId, int? resendToken) {
          developer.log('OtpScreen: Resend - OTP code sent successfully', name: 'VoloAuth');
          developer.log('  - New verification ID: $verificationId', name: 'VoloAuth');
          developer.log('  - Resend token: $resendToken', name: 'VoloAuth');
          
          setState(() {
            _isLoading = false;
            _errorText = null;
          });
          
          // Update the verification ID for this session
          _currentVerificationId = verificationId;
          
          // Restart countdown timer
          _startResendCountdown();
          
          // Show success message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP resent to ${widget.phoneNumber}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        // Auto-retrieval timeout callback
        codeAutoRetrievalTimeout: (String verificationId) {
          developer.log('OtpScreen: Resend - Auto-retrieval timeout', name: 'VoloAuth');
          developer.log('  - Verification ID: $verificationId', name: 'VoloAuth');
          
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
    } catch (e) {
      // Handle any unexpected exceptions during resend
      developer.log('OtpScreen: Resend - Exception occurred', name: 'VoloAuth');
      developer.log('  - Exception: $e', name: 'VoloAuth');
      developer.log('  - Exception type: ${e.runtimeType}', name: 'VoloAuth');
      
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to resend OTP. Please try again.';
      });
      
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
} 