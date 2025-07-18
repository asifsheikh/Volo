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

    // Configure App Check
    #if targetEnvironment(simulator)
      let providerFactory = AppCheckDebugProviderFactory()
    #else
      // For production, use AppAttestProviderFactory or DeviceCheckProviderFactory
      let providerFactory = AppCheckDebugProviderFactory()
    #endif

    AppCheck.setAppCheckProviderFactory(providerFactory)
    
    // Configure Firebase before registering plugins
    FirebaseApp.configure()
    
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up Firebase Messaging delegate
    Messaging.messaging().delegate = self
    
    // Set up notification center delegate
    UNUserNotificationCenter.current().delegate = self
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle custom URL schemes for Firebase Auth
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if Auth.auth().canHandle(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
  
  // Handle push notifications for Firebase Auth
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification notification: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if Auth.auth().canHandleNotification(notification) {
      completionHandler(.noData)
      return
    }
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
    
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Handle push notification registration failure
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}

// MARK: - Firebase Messaging Delegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
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
    // Show the notification even when app is in foreground
    completionHandler([[.alert, .sound, .badge]])
  }
  
  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
  }
}
