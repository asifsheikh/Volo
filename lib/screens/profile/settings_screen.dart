import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final String username;
  final String phoneNumber;

  const SettingsScreen({
    Key? key,
    required this.username,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  /// Handle sign out
  Future<void> _signOut() async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('SettingsScreen: Signing out user', name: 'VoloAuth');
      
      // Sign out from Firebase
      await FirebaseService.signOut();
      
      developer.log('SettingsScreen: Sign out successful', name: 'VoloAuth');
      
      // Navigate back to welcome screen (AuthWrapper will handle routing)
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      developer.log('SettingsScreen: Error signing out: $e', name: 'VoloAuth');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to sign out. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Handle delete account
  Future<void> _deleteAccount() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFFEF4444),
            ),
          ),
          content: const Text(
            'This action cannot be undone. All your flight data and contacts will be permanently deleted.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('SettingsScreen: Deleting user account', name: 'VoloAuth');
      
      // Delete user account and data
      await FirebaseService.deleteUserAccount();
      
      developer.log('SettingsScreen: Account deletion successful', name: 'VoloAuth');
      
      // Navigate back to welcome screen (AuthWrapper will handle routing)
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      developer.log('SettingsScreen: Error deleting account: $e', name: 'VoloAuth');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to delete account. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Show help and support dialog
  void _showHelpAndSupport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Help & Support',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'For help and support, please contact us at:\n\nsupport@volo.com\n\nWe\'ll get back to you within 24 hours.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF008080),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show privacy policy dialog
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Privacy Policy',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information.\n\n'
              '• We collect only the information necessary to provide our services\n'
              '• Your data is encrypted and stored securely\n'
              '• We do not sell or share your personal information with third parties\n'
              '• You can request deletion of your data at any time\n\n'
              'For the complete privacy policy, visit: volo.com/privacy',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF008080),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show terms and services dialog
  void _showTermsAndServices() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Terms & Services',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'By using Volo, you agree to these terms and conditions:\n\n'
              '• You must be at least 18 years old to use this service\n'
              '• You are responsible for maintaining the security of your account\n'
              '• We reserve the right to modify these terms at any time\n'
              '• The service is provided "as is" without warranties\n'
              '• We are not liable for any damages arising from use of the service\n\n'
              'For the complete terms, visit: volo.com/terms',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF008080),
                ),
              ),
            ),
          ],
        );
      },
    );
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
        title: Text(
          'Settings',
          style: AppTheme.headlineMedium,
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Support & Legal
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(0x33008080),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.help_outline,
                                color: Color(0xFF008080),
                                size: 20,
                              ),
                            ),
                          ),
                          title: const Text(
                            'Help & Support',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF333333),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          onTap: _showHelpAndSupport,
                        ),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                        ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(0x33008080),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.privacy_tip_outlined,
                                color: Color(0xFF008080),
                                size: 20,
                              ),
                            ),
                          ),
                          title: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF333333),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          onTap: _showPrivacyPolicy,
                        ),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                        ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(0x33008080),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.description_outlined,
                                color: Color(0xFF008080),
                                size: 20,
                              ),
                            ),
                          ),
                          title: const Text(
                            'Terms & Services',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF333333),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          onTap: _showTermsAndServices,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Account Actions (moved to end)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.logout, color: Color(0xFFFFA726)),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF111827),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          onTap: _isLoading ? null : _signOut,
                        ),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE6E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                          ),
                          title: const Text(
                            'Delete Account',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                          onTap: _isLoading ? null : _deleteAccount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 