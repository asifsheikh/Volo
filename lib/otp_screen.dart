import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'onboarding_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  String? _errorText;

  void _onVerify() {
    setState(() {
      if (_otp.length != 6) {
        _errorText = 'Please enter the 6-digit code';
      } else {
        _errorText = null;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(phoneNumber: widget.phoneNumber),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 48,
              left: 24,
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
            // Main content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
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
                          onPressed: _onVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F2937),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Colors.black.withOpacity(0.1),
                            elevation: 8,
                          ),
                          child: const Text(
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
                        GestureDetector(
                          onTap: () {
                            // Resend logic or print message
                          },
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 