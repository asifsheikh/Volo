import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_provider.dart';
import '../../domain/usecases/get_profile_data.dart';
import '../../../../services/push_notification_service.dart';
import '../../../../services/firebase_service.dart';
import '../../../../theme/app_theme.dart';
import 'dart:developer' as developer;

/// Push Notification Test Screen using Riverpod + Clean Architecture
class PushNotificationTestScreen extends ConsumerStatefulWidget {
  const PushNotificationTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PushNotificationTestScreen> createState() => _PushNotificationTestScreenState();
}

class _PushNotificationTestScreenState extends ConsumerState<PushNotificationTestScreen> {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FCM Token',
                style: AppTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Token:',
                      style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fcmToken ?? 'Loading...',
                      style: AppTheme.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Stored Token:',
                      style: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _storedFCMToken ?? 'Not stored',
                      style: AppTheme.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Test Notifications',
                style: AppTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _testFirebaseMessaging,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059393),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Test Firebase Messaging',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _testLocalNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Test Local Notification',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadFCMToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Refresh FCM Token',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 