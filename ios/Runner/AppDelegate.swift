import Flutter
import UIKit
import Firebase
import FirebaseAuth
import FirebaseAppCheck
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // --- RE-ADD THIS ENTIRE BLOCK! ---
    #if targetEnvironment(simulator)
      let providerFactory = AppCheckDebugProviderFactory()
      print("AppDelegate: Setting AppCheckDebugProviderFactory for simulator.")
    #else
      // IMPORTANT: For production, this MUST be a real attestation provider
      // like AppAttestProviderFactory or DeviceCheckProviderFactory.
      // For now, if you're only testing debug builds, keeping DebugProviderFactory is fine,
      // but ensure you plan for production security.
      let providerFactory = AppCheckDebugProviderFactory()
    #endif

    // Set the provider factory BEFORE configuring FirebaseApp.
    // This is crucial for FirebaseAuth to pick it up correctly.
    AppCheck.setAppCheckProviderFactory(providerFactory)
    // --- END OF BLOCK TO RE-ADD ---
    
    // Configure Firebase before registering plugins
    FirebaseApp.configure()
    
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up Firebase Messaging delegate
    Messaging.messaging().delegate = self
    
    // Request notification permissions (Flutter will handle this, but we can also do it here)
    UNUserNotificationCenter.current().delegate = self
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle custom URL schemes for Firebase Auth
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Pass the URL to Firebase Auth to handle phone authentication redirects
    if Auth.auth().canHandle(url) {
      return true
    }
    // URL not auth related; it should be handled separately.
    return super.application(app, open: url, options: options)
  }
  
  // Handle push notifications for Firebase Auth
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification notification: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // Pass notification to auth and check if they can handle it
    if Auth.auth().canHandleNotification(notification) {
      completionHandler(.noData)
      return
    }
    // This notification is not auth related; it should be handled separately.
    super.application(application, didReceiveRemoteNotification: notification, fetchCompletionHandler: completionHandler)
  }
  
  // Handle APNs device token for Firebase Auth and Messaging
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Pass device token to Firebase Auth
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    
    // Pass device token to Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    
    // Log the token for debugging
    let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
    print("✅ APNs device token: \(tokenString)")
    
    // Further handling of the device token if needed by the app
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Handle push notification registration failure
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}

// MARK: - Firebase Messaging Delegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("✅ Firebase registration token: \(fcmToken ?? "nil")")
    
    // Store the token for later use
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}

// MARK: - UNUserNotificationCenter Delegate
extension AppDelegate {
  // Handle notifications when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("📱 Foreground notification received: \(userInfo)")
    
    // Show the notification even when app is in foreground
    completionHandler([[.alert, .sound, .badge]])
  }
  
  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("👆 Notification tapped: \(userInfo)")
    
    completionHandler()
  }
}
