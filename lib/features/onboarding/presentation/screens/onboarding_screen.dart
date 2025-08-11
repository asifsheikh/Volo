import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../domain/entities/onboarding_state.dart' as domain;
import '../../domain/usecases/get_onboarding_data.dart';
import '../../../../services/firebase_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../screens/main_navigation_screen.dart';

/// Onboarding Screen using Riverpod + Clean Architecture
class OnboardingScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OnboardingScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _firstNameError;
  bool _isLoading = false;

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

  /// Handle onboarding completion
  Future<void> _completeOnboarding() async {
    if (!_isFirstNameValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Complete onboarding using the use case
      await ref.read(getOnboardingDataProvider(widget.phoneNumber).notifier).completeOnboarding(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: widget.phoneNumber,
      );

      // Navigate to home screen and clear navigation stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(
              username: _firstNameController.text.trim(),
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message to user
        String errorMessage = 'Something went wrong. Please try again.';
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'Permission denied. Please check your Firestore rules.';
        } else if (e.toString().contains('unavailable')) {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.destructive,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppTheme.textOnPrimary,
              onPressed: _completeOnboarding,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingAsync = ref.watch(onboardingProviderProvider(widget.phoneNumber));
    
    return onboardingAsync.when(
      data: (onboardingState) => _buildOnboardingContent(onboardingState),
      loading: () => _buildLoadingContent(),
      error: (error, stackTrace) => _buildErrorContent(error.toString()),
    );
  }

  Widget _buildLoadingContent() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Onboarding',
              style: AppTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTheme.bodyMediumSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(onboardingProviderProvider(widget.phoneNumber));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingContent(domain.OnboardingState onboardingState) {
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
                              'assets/app_icon.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          "Welcome to Volo! ✈️",
                          style: AppTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          "Let's set up your profile so we can keep your loved ones updated about your flights.",
                          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
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
                                  style: TextStyle(color: AppTheme.destructive),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _firstNameController,
                          onChanged: _onFirstNameChanged,
                          enabled: !_isLoading,
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
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
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
                          child: Text(
                            'Last name',
                            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _lastNameController,
                          onChanged: _onLastNameChanged,
                          enabled: !_isLoading,
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
                            onPressed: (_isFirstNameValid && !_isLoading)
                                ? _completeOnboarding
                                : null,
                            style: AppTheme.primaryButton,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Get Started',
                                    style: AppTheme.titleLarge.copyWith(color: AppTheme.textOnPrimary),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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