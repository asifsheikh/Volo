import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText;
  String _countryCode = '+91';
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _onContinue() async {
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
      String formattedCountryCode = _countryCode.trim();
      String formattedNumber = _phoneController.text.trim();
      if (formattedNumber.startsWith('+')) {
        formattedNumber = formattedNumber.substring(1);
      }
      
      String fullPhoneNumber = '+$formattedCountryCode$formattedNumber';
      
      // Send OTP via Firebase
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification if SMS is not required
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
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            if (e.code == 'invalid-phone-number') {
              _errorText = 'Invalid phone number';
            } else if (e.code == 'too-many-requests') {
              _errorText = 'Too many requests. Please try again later.';
            } else {
              _errorText = 'Failed to send OTP. Please try again.';
            }
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                phoneNumber: fullPhoneNumber,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _isLoading = false;
          });
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
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
                        'Enter your phone number',
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
                      const Text(
                        "We'll help you get started with Volo",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color(0xFF4B5563),
                        ),
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
                                  _countryCode = phone.countryCode.replaceAll('+', '');
                                  if (_phoneController.text.isNotEmpty) {
                                    _errorText = null;
                                  }
                                });
                              },
                              onCountryChanged: (country) {
                                setState(() {
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
                                    'Continue',
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
                      const Text(
                        "We'll send you an OTP to verify your number",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 20 / 12,
                          color: Color(0xFF6B7280),
                        ),
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
} 