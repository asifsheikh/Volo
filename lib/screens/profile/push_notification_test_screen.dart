import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/push_notification_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import 'dart:developer' as developer;

class PushNotificationTestScreen extends StatefulWidget {
  const PushNotificationTestScreen({Key? key}) : super(key: key);

  @override
  State<PushNotificationTestScreen> createState() => _PushNotificationTestScreenState();
}

class _PushNotificationTestScreenState extends State<PushNotificationTestScreen> {
  String? _fcmToken;
  String? _storedFCMToken;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    try {
      final token = await PushNotificationService.getCurrentToken();
      final storedToken = await FirebaseService.getFCMToken();
      
      setState(() {
        _fcmToken = token;
        _storedFCMToken = storedToken;
      });
    } catch (e) {
      developer.log('Failed to load FCM token: $e', name: 'PushTest');
    }
  }



  Future<void> _testFirebaseMessaging() async {
    try {
      await PushNotificationService.testFirebaseMessaging();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firebase Messaging test completed. Check console logs.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase Messaging test failed: $e')),
        );
      }
    }
  }



  Future<void> _testLocalNotification() async {
    try {
      await PushNotificationService.testLocalNotification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local notification test sent. Check for notification.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Local notification test failed: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Push Notification Test',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textSecondary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _fcmToken != null ? Icons.check_circle : Icons.error,
                        color: _fcmToken != null ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Push Notification Status',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _fcmToken != null 
                        ? '✅ Push notifications are ready'
                        : '❌ Push notifications not configured',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: _fcmToken != null ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // FCM Token Section
            Text(
              'FCM Token Status',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: _fcmToken != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Device Token
                        Text(
                          'Device Token:',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _fcmToken!,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Stored Token Status
                        Text(
                          'Stored in Profile:',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _storedFCMToken != null ? Icons.check_circle : Icons.error,
                              color: _storedFCMToken != null ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _storedFCMToken != null 
                                  ? 'Token saved to user profile'
                                  : 'Token not saved to profile',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: _storedFCMToken != null ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        
                        if (_storedFCMToken != null && _fcmToken != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _storedFCMToken == _fcmToken ? Icons.check_circle : Icons.warning,
                                color: _storedFCMToken == _fcmToken ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _storedFCMToken == _fcmToken 
                                    ? 'Tokens match'
                                    : 'Tokens do not match (needs refresh)',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: _storedFCMToken == _fcmToken ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ]
                  )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fcmToken?.startsWith('mock_') == true 
                              ? 'Mock FCM token (iOS Simulator Debug Mode)'
                              : 'No FCM token available',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: _fcmToken?.startsWith('mock_') == true 
                                ? const Color(0xFFF59E0B) 
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFEAA7)),
                          ),
                          child: Text(
                            'Note: On iOS simulator, APNS tokens may not be available. Try on a physical device for full functionality. If you\'re on a physical device and still seeing this, check your Apple Developer account and push notification certificates.',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: const Color(0xFF856404),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Actions
            Text(
              'Test Actions',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testFirebaseMessaging,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Test Firebase Messaging',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testLocalNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Test Local Notification',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      Text(
                        'Testing Instructions',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Copy the FCM token above\n'
                    '2. Use Firebase Console to send a test message\n'
                    '3. Check console logs for message handling',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: const Color(0xFF92400E),
                    ),
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