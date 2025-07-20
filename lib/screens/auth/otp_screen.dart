import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../onboarding/onboarding_screen.dart';
import 'dart:developer' as developer;
import 'dart:async';

import '../../services/firebase_service.dart';
import '../onboarding/welcome_back_screen.dart';

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
  final int? resendToken;
  const OtpScreen({
    Key? key, required 
    this.phoneNumber, 
    this.verificationId, 
    this.resendToken}) : super(key: key);

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
  int? _resendToken;

  @override
  void initState() {
    super.initState();
    // Initialize verification ID from widget
    _currentVerificationId = widget.verificationId;
  }

  /// Converts Firebase error codes to user-friendly error messages
  /// 
  /// This method handles all possible Firebase authentication error codes
  /// specific to OTP verification and provides clear, actionable messages.
  /// 
  /// [e] - The FirebaseAuthException containing the error details
  /// Returns a user-friendly error message string
  String _getUserFriendlyErrorMessage(FirebaseAuthException e) {
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
    setState(() {
      if (_otp.length != 6) {
        _errorText = 'Please enter the 6-digit code';
        return;
      } else {
        _errorText = null;
        _isLoading = true;
      }
    });

    try {
      // Get the verification ID for this session
      String verificationId = _currentVerificationId ?? widget.verificationId ?? '';
      
      // Handle auto-verification case (test phone numbers)
      if (verificationId.isEmpty) {
        // Auto-verified case, check if user profile exists
        await _handlePostAuthentication();
        return;
      }

      // Create PhoneAuthCredential with OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _otp,
      );

      // Sign in with Firebase using the credential
      await _auth.signInWithCredential(credential);
      
      // Show success message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Handle post-authentication routing
      await _handlePostAuthentication();
    } on FirebaseAuthException catch (e) {
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
      setState(() {
        _isLoading = false;
        _errorText = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  /// Handle post-authentication routing based on user profile existence
  Future<void> _handlePostAuthentication() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      // Check if user profile exists in Firestore by phone number
      final userProfile = await FirebaseService.getUserProfileByPhoneNumber(user.phoneNumber ?? '');
      if (userProfile != null) {
        // Migrate profile to current UID if needed
        await FirebaseService.migrateUserProfileToCurrentUid(user.phoneNumber ?? '');
      }
      if (mounted) {
        if (userProfile != null) {
          // User profile exists - show WelcomeBackScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => WelcomeBackScreen(
                userName: userProfile['firstName'] ?? 'User',
              ),
            ),
            (route) => false,
          );
        } else {
          // No user profile - show onboarding screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnboardingScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        }
      }
    } catch (e) {
      // If there's an error checking profile, default to onboarding
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(phoneNumber: widget.phoneNumber),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
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
                      const Text(
                        'Enter verification code',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          height: 30 / 24,
                          color: Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'We sent a 6-digit code to ${widget.phoneNumber}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 24 / 16,
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
                                    'Verify & Continue',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
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
                                'Resend code',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Resend in $_resendCountdown seconds',
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
                          'Use different number',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
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
    // Check if resend is allowed (countdown finished)
    if (!_canResend) {
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
        _errorText = null;
      });

      // Call Firebase to resend OTP
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        // Auto-verification callback (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            await _handlePostAuthentication();
          }
        },
        // Error handling callback
        verificationFailed: (FirebaseAuthException e) {
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
          setState(() {
            _isLoading = false;
            _currentVerificationId = verificationId;
            _resendToken = resendToken;
            _errorText = null;
          });
          
          // Start countdown timer
          _startResendCountdown();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP resent successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
        // Timeout callback
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _currentVerificationId = verificationId;
          });
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to resend OTP. Please try again.';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorText!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
} 