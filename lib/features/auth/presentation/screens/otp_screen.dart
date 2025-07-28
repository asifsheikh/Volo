import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../../../../theme/app_theme.dart';
import '../../../../services/firebase_service.dart';
import '../providers/auth_provider.dart';
import '../../../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../../../features/onboarding/presentation/screens/welcome_back_screen.dart';

/// OTP Verification Screen for Volo App using Riverpod + Clean Architecture
/// 
/// This screen handles OTP verification for Firebase phone authentication.
/// Features include:
/// - 6-digit OTP input with auto-focus and formatting
/// - Automatic OTP verification on completion
/// - Resend OTP functionality with countdown timer
/// - Comprehensive error handling for production use
/// - User-friendly error messages and loading states
/// - Auto-verification support for test numbers
class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;
  
  const OtpScreen({
    Key? key, 
    required this.phoneNumber,
    required this.verificationId,
  }) : super(key: key);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // State variables for OTP handling
  String _otp = '';
  bool _canResend = true;
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  bool _hasAttemptedVerification = false; // Track if user has attempted verification

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
    _countdownTimer?.cancel();
    super.dispose();
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
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  /// Check if the OTP is valid for enabling the button
  bool get _isOtpValid {
    return _otp.length == 6;
  }

  /// Handles OTP verification when user enters the 6-digit code
  /// 
  /// This method:
  /// 1. Validates that a 6-digit OTP has been entered
  /// 2. Calls the auth provider to verify OTP
  /// 3. Handles success and error cases
  /// 4. Shows appropriate user feedback
  Future<void> _onVerify() async {
    // Set flag that user has attempted verification
    setState(() {
      _hasAttemptedVerification = true;
    });

    if (_otp.length != 6) {
      // Show error via Riverpod state
      return;
    }

    try {
      // Clear any existing errors before starting verification
      ref.read(authNotifierProvider).clearError();

      // Verify OTP via Riverpod
      await ref.read(authNotifierProvider).signInWithPhone(
        phoneNumber: widget.phoneNumber,
        verificationId: widget.verificationId,
        smsCode: _otp,
      );

      // Clear any errors after successful verification
      ref.read(authNotifierProvider).clearError();

      // Handle post-authentication routing
      await _handlePostAuthentication();
    } catch (e) {
      // Error handling is done via Riverpod state
      print('Error in _onVerify: $e');
    }
  }

  /// Handles post-authentication navigation
  /// 
  /// This method:
  /// 1. Checks if user profile exists in Firestore
  /// 2. Navigates to appropriate screen based on profile status
  /// 3. Handles errors gracefully
  Future<void> _handlePostAuthentication() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Check if user profile exists in Firestore by phone number
      final userProfile = await FirebaseService.getUserProfileByPhoneNumber(user.phoneNumber ?? '');
      
      if (userProfile != null) {
        // Migrate profile to current UID if needed
        await FirebaseService.migrateUserProfileToCurrentUid(user.phoneNumber ?? '');
        
        // User profile exists - show WelcomeBackScreen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => WelcomeBackScreen(
                userName: userProfile['firstName'] ?? 'User',
              ),
            ),
            (route) => false,
          );
        }
      } else {
        // No user profile - show onboarding screen
        if (mounted) {
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

  /// Handles resend OTP functionality
  /// 
  /// This method:
  /// 1. Validates that countdown timer has finished
  /// 2. Calls the auth provider to resend OTP
  /// 3. Handles success and error cases
  /// 4. Restarts countdown timer
  Future<void> _resendOTP() async {
    // Check if resend is allowed (countdown finished)
    if (!_canResend) {
      return;
    }
    
    try {
      // Resend OTP via Riverpod
      await ref.read(authNotifierProvider).sendOTP(
        phoneNumber: widget.phoneNumber,
      );
      
      // Start countdown timer
      _startResendCountdown();
    } catch (e) {
      // Error handling is done via Riverpod state
      print('Error in _resendOTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state from Riverpod
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;

    // Debug logging to understand error state
    if (error != null) {
      print('OTPScreen: Error detected - $error');
      print('OTPScreen: _hasAttemptedVerification: $_hasAttemptedVerification');
      print('OTPScreen: isLoading: $isLoading');
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
                        'Enter verification code',
                        style: AppTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'We sent a 6-digit code to ${widget.phoneNumber}',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // OTP input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Center(
                              child: PinCodeTextField(
                                appContext: context,
                                length: 6,
                                onChanged: (value) {
                                  setState(() {
                                    _otp = value;
                                    if (_otp.length == 6) {
                                      // Clear error when user types
                                      ref.read(authNotifierProvider).clearError();
                                    }
                                  });
                                },
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(12),
                                  fieldHeight: 56,
                                  fieldWidth: 52,
                                  activeColor: AppTheme.textSecondary,
                                  selectedColor: AppTheme.textPrimary,
                                  inactiveColor: AppTheme.textSecondary,
                                  activeFillColor: AppTheme.cardBackground,
                                  selectedFillColor: AppTheme.cardBackground,
                                  inactiveFillColor: AppTheme.cardBackground,
                                  borderWidth: 2,
                                ),
                                keyboardType: TextInputType.number,
                                animationType: AnimationType.fade,
                                enableActiveFill: true,
                                cursorColor: const Color(0xFF1F2937),
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              ),
                            ),
                            if (error != null && _hasAttemptedVerification) ...[
                              const SizedBox(height: 8),
                              Text(
                                error,
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
                            onPressed: (isLoading || !_isOtpValid) ? null : _onVerify,
                            style: AppTheme.primaryButton.copyWith(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return AppTheme.primary.withOpacity(0.5);
                                }
                                return AppTheme.primary;
                              }),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Verify & Continue',
                                    style: AppTheme.titleLarge.copyWith(
                                      color: _isOtpValid ? AppTheme.textOnPrimary : AppTheme.textOnPrimary.withOpacity(0.7),
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
                          Text(
                            "Didn't receive the code? ",
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                          ),
                          if (_canResend)
                            GestureDetector(
                              onTap: _resendOTP,
                              child: Text(
                                'Resend code',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Resend in $_resendCountdown seconds',
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Change number
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Use different number',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
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
              child: Text.rich(
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
            ),
          ],
        ),
      ),
    );
  }
} 