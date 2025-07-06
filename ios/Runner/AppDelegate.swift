import Flutter
import UIKit
import Firebase
import FirebaseAuth

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase before registering plugins
    FirebaseApp.configure()
    
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
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
  
  // Handle APNs device token for Firebase Auth
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Pass device token to auth
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    
    // Further handling of the device token if needed by the app
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
