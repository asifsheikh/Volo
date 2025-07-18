import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Singleton pattern
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  // Notification handlers
  static Function(RemoteMessage)? _onMessageReceived;
  static Function(RemoteMessage)? _onMessageOpenedApp;

  /// Initialize push notification service
  static Future<void> initialize({
    Function(RemoteMessage)? onMessageReceived,
    Function(RemoteMessage)? onBackgroundMessage,
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    try {
      developer.log('PushNotificationService: Starting initialization...', name: 'VoloPush');
      
      _onMessageReceived = onMessageReceived;
      _onMessageOpenedApp = onMessageOpenedApp;
      // _onBackgroundMessage = onBackgroundMessage; // This line is removed

      // Request permission for iOS
      developer.log('PushNotificationService: Requesting permissions...', name: 'VoloPush');
      await _requestPermission();
      
      // Initialize local notifications
      developer.log('PushNotificationService: Initializing local notifications...', name: 'VoloPush');
      await _initializeLocalNotifications();
      
      // Set up Firebase messaging handlers
      await _setupFirebaseMessaging();
      
      // Set up token refresh listener
      _setupTokenRefreshListener();
      
      // Get FCM token
      await _getFCMToken();
      
      developer.log('PushNotificationService: Initialized successfully', name: 'VoloPush');
    } catch (e) {
      developer.log('PushNotificationService: Initialization failed: $e', name: 'VoloPush');
      rethrow;
    }
  }

  /// Request notification permissions
  static Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('PushNotificationService: Permission status: ${settings.authorizationStatus}', name: 'VoloPush');
    } catch (e) {
      developer.log('PushNotificationService: Permission request failed: $e', name: 'VoloPush');
    }
  }

  /// Initialize local notifications plugin
  static Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      developer.log('PushNotificationService: Local notifications initialized', name: 'VoloPush');
    } catch (e) {
      developer.log('PushNotificationService: Local notifications initialization failed: $e', name: 'VoloPush');
    }
  }

  /// Set up Firebase messaging handlers
  static Future<void> _setupFirebaseMessaging() async {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message when app is opened from terminated state
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        developer.log('PushNotificationService: Found initial message: ${initialMessage.messageId}', name: 'VoloPush');
        _handleMessageOpenedApp(initialMessage);
      }

      developer.log('PushNotificationService: Firebase messaging handlers set up successfully', name: 'VoloPush');
    } catch (e) {
      developer.log('PushNotificationService: Firebase messaging setup failed: $e', name: 'VoloPush');
    }
  }

  /// Get FCM token for this device
  static Future<String?> _getFCMToken() async {
    try {
      // For iOS, ensure APNS token is available first
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        developer.log('PushNotificationService: APNS Token: ${apnsToken ?? 'Not available'}', name: 'VoloPush');
        
        // If APNS token is not available, wait a bit and try again
        if (apnsToken == null) {
          developer.log('PushNotificationService: APNS token not available, waiting...', name: 'VoloPush');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _firebaseMessaging.getAPNSToken();
          developer.log('PushNotificationService: APNS Token after delay: ${apnsToken ?? 'Still not available'}', name: 'VoloPush');
        }
        
        // Only use mock token on iOS simulator, not on physical devices
        // We'll try to get the FCM token first, and only use mock if that fails
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          developer.log('PushNotificationService: FCM Token: $token', name: 'VoloPush');
          await _saveFCMTokenToUserProfile(token);
          return token;
        }
        
        // If FCM token is null and we're in debug mode, use mock token for simulator
        if (kDebugMode && token == null) {
          const mockToken = 'mock_fcm_token_ios_simulator_debug_mode';
          developer.log('PushNotificationService: Using mock FCM token for iOS simulator debug mode', name: 'VoloPush');
          await _saveFCMTokenToUserProfile(mockToken);
          return mockToken;
        }
        
        // If on physical device but FCM token is null, log the issue
        if (token == null) {
          developer.log('PushNotificationService: WARNING - FCM token is null on physical device. This may indicate a configuration issue.', name: 'VoloPush');
        }
        
        return token;
      }
      
      // For non-iOS platforms, get FCM token directly
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        developer.log('PushNotificationService: FCM Token: $token', name: 'VoloPush');
        await _saveFCMTokenToUserProfile(token);
      } else {
        developer.log('PushNotificationService: FCM token is null', name: 'VoloPush');
      }
      return token;
    } catch (e) {
      developer.log('PushNotificationService: Failed to get FCM token: $e', name: 'VoloPush');
      return null;
    }
  }



  /// Listen for FCM token refresh and update user profile
  static void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      developer.log('PushNotificationService: FCM token refreshed', name: 'VoloPush');
      await _saveFCMTokenToUserProfile(newToken);
    });
  }

  /// Save FCM token to user profile
  static Future<void> _saveFCMTokenToUserProfile(String token) async {
    try {
      await FirebaseService.saveFCMToken(token);
      developer.log('PushNotificationService: FCM token saved to user profile', name: 'VoloPush');
    } catch (e) {
      developer.log('PushNotificationService: Failed to save FCM token: $e', name: 'VoloPush');
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    developer.log('PushNotificationService: Foreground message received: ${message.messageId}', name: 'VoloPush');
    developer.log('PushNotificationService: Message data: ${message.data}', name: 'VoloPush');
    developer.log('PushNotificationService: Message notification: ${message.notification?.title} - ${message.notification?.body}', name: 'VoloPush');
    
    // Show local notification
    _showLocalNotification(message);
    
    // Call custom handler if provided
    _onMessageReceived?.call(message);
  }

  /// Handle when app is opened from notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    developer.log('PushNotificationService: App opened from notification: ${message.messageId}', name: 'VoloPush');
    
    // Call custom handler if provided
    _onMessageOpenedApp?.call(message);
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    developer.log('PushNotificationService: Local notification tapped: ${response.payload}', name: 'VoloPush');
    
    // TODO: Handle navigation based on notification payload
    // This will be implemented when we have proper navigation setup
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'volo_flight_updates',
        'Flight Updates',
        channelDescription: 'Notifications for flight status updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'Flight Update',
        message.notification?.body ?? 'You have a new flight update',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    } catch (e) {
      developer.log('PushNotificationService: Failed to show local notification: $e', name: 'VoloPush');
    }
  }



  /// Get current FCM token
  static Future<String?> getCurrentToken() async {
    try {
      // For iOS, ensure APNS token is available first
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          developer.log('PushNotificationService: APNS token not available for manual refresh', name: 'VoloPush');
          return null;
        }
      }
      
      return await _firebaseMessaging.getToken();
    } catch (e) {
      developer.log('PushNotificationService: Failed to get current token: $e', name: 'VoloPush');
      return null;
    }
  }

  /// Delete FCM token
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      developer.log('PushNotificationService: FCM token deleted', name: 'VoloPush');
    } catch (e) {
      developer.log('PushNotificationService: Failed to delete FCM token: $e', name: 'VoloPush');
    }
  }



  /// Test Firebase Messaging functionality
  static Future<void> testFirebaseMessaging() async {
    try {
      developer.log('PushNotificationService: Testing Firebase Messaging...', name: 'VoloPush');
      
      // Test getting current token
      final token = await _firebaseMessaging.getToken();
      developer.log('PushNotificationService: Current FCM token: $token', name: 'VoloPush');
      
      // Test getting APNS token (iOS only)
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        developer.log('PushNotificationService: Current APNS token: $apnsToken', name: 'VoloPush');
      }
      
      // Test notification settings
      final settings = await _firebaseMessaging.getNotificationSettings();
      developer.log('PushNotificationService: Notification settings: $settings', name: 'VoloPush');
      
      developer.log('PushNotificationService: Firebase Messaging test completed', name: 'VoloPush');
    } catch (e) {
      developer.log('PushNotificationService: Firebase Messaging test failed: $e', name: 'VoloPush');
      rethrow;
    }
  }



  /// Test local notification display
  static Future<void> testLocalNotification() async {
    try {
      developer.log('PushNotificationService: Testing local notification...', name: 'VoloPush');
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'volo_test_channel',
        'Test Notifications',
        channelDescription: 'Test notifications for debugging',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        999999, // Use a unique ID for test
        'Test Notification',
        'This is a test notification from Volo app',
        platformChannelSpecifics,
        payload: 'test_notification',
      );
      
      developer.log('PushNotificationService: Local notification sent successfully', name: 'VoloPush');
    } catch (e) {
      developer.log('PushNotificationService: Local notification failed: $e', name: 'VoloPush');
      rethrow;
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  // await Firebase.initializeApp();
  
  developer.log('PushNotificationService: Background message received: ${message.messageId}', name: 'VoloPush');
  
  // TODO: Handle background message processing
  // This will be implemented when we have proper background processing
} 