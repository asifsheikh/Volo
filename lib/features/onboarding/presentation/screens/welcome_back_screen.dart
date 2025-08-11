import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../screens/main_navigation_screen.dart';
import '../../../../theme/app_theme.dart';

/// Welcome Back Screen using Riverpod + Clean Architecture
class WelcomeBackScreen extends ConsumerWidget {
  final String userName;

  const WelcomeBackScreen({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // App Icon
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(24),
                  shadowColor: AppTheme.shadowPrimary,
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
                const SizedBox(height: 40),
                Text(
                  'Welcome back, $userName! 👋',
                  style: AppTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                                  Text(
                    'Ready to keep your loved ones updated about your flights?',
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppTheme.primaryButton,
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => MainNavigationScreen(username: userName)),
                        (route) => false,
                      );
                    },
                    child: const Text('Let\'s Go!'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 