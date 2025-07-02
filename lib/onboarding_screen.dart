import 'package:flutter/material.dart';
import 'otp_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String phoneNumber;
  const OnboardingScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _firstNameError;

  bool get _isFirstNameValid =>
      _firstNameController.text.isNotEmpty && RegExp(r'^[a-zA-Z]+$').hasMatch(_firstNameController.text);

  void _onFirstNameChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _firstNameError = null;
      } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
        _firstNameError = 'Only letters are allowed';
      } else {
        _firstNameError = null;
      }
    });
  }

  void _onLastNameChanged(String value) {
    setState(() {
      if (value.isNotEmpty && !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
        // Optionally show error for last name, but not required
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: widget.phoneNumber)),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF1F2937),
                    size: 24,
                  ),
                ),
              ),
            ),
            // Main Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                          "Let's get to know you",
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
                          "We'll personalize notifications using your name.",
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
                        // First Name
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: const TextSpan(
                              text: 'First name ',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _firstNameController,
                          onChanged: _onFirstNameChanged,
                          decoration: InputDecoration(
                            hintText: 'First name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF9CA3AF), width: 2),
                            ),
                            errorText: _firstNameError,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Last Name
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Last name',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _lastNameController,
                          onChanged: _onLastNameChanged,
                          decoration: InputDecoration(
                            hintText: 'Last name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF9CA3AF), width: 2),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isFirstNameValid ? () {} : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F2937),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Colors.black.withOpacity(0.1),
                              elevation: 8,
                            ),
                            child: const Text(
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
                        const SizedBox(height: 32),
                        // Terms/Privacy
                        const Text.rich(
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
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 