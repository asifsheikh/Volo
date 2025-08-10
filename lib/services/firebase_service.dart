import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Configure Firestore settings
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is authenticated
  static bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  // Get user's phone number
  static String? getUserPhoneNumber() {
    return _auth.currentUser?.phoneNumber;
  }

  // Get user's UID
  static String? getUserUid() {
    return _auth.currentUser?.uid;
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Save user profile data to Firestore (without email)
  static Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Get FCM token if available
      String? fcmToken;
      try {
        fcmToken = await _messaging.getToken();
      } catch (e) {
        // FCM token not available yet, will be updated later
        developer.log('FirebaseService: FCM token not available during profile creation: $e', name: 'VoloAuth');
      }

      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'fcmToken': fcmToken, // Include FCM token in initial profile
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isOnboarded': true,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      
      developer.log('FirebaseService: User profile created with FCM token: ${fcmToken != null ? 'Yes' : 'No'}', name: 'VoloAuth');
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile data from Firestore
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Find user profile by phone number
  static Future<Map<String, dynamic>?> getUserProfileByPhoneNumber(String phoneNumber) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Migrate user profile to new UID if needed
  static Future<void> migrateUserProfileToCurrentUid(String phoneNumber) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final query = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final oldDoc = query.docs.first;
      if (oldDoc.id != currentUser.uid) {
        final data = oldDoc.data();
        await _firestore.collection('users').doc(currentUser.uid).set(data);
        await oldDoc.reference.delete();
      }
    }
  }

  // Check if user has completed onboarding (by phone number)
  static Future<bool> isUserOnboarded() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      final profile = await getUserProfileByPhoneNumber(user.phoneNumber ?? '');
      // If found, migrate to current UID if needed
      if (profile != null) {
        await migrateUserProfileToCurrentUid(user.phoneNumber ?? '');
      }
      return profile != null && (profile['isOnboarded'] == true);
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account and data
  static Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete the user account
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Listen to authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Listen to user changes
  static Stream<User?> get userChanges => _auth.userChanges();

  // FCM Token Management
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Save FCM token to user profile
  static Future<void> saveFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      developer.log('FirebaseService: FCM token saved to user profile', name: 'VoloAuth');
    } catch (e) {
      developer.log('FirebaseService: Failed to save FCM token: $e', name: 'VoloAuth');
      rethrow;
    }
  }

  /// Ensure FCM token is up to date in user profile
  static Future<void> ensureFCMTokenUpdated() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final currentToken = await _messaging.getToken();
      if (currentToken == null) return;

      final storedToken = await getFCMToken();
      
      // Only update if token has changed or doesn't exist
      if (storedToken != currentToken) {
        await saveFCMToken(currentToken);
        developer.log('FirebaseService: FCM token updated in user profile', name: 'VoloAuth');
      }
    } catch (e) {
      developer.log('FirebaseService: Failed to ensure FCM token updated: $e', name: 'VoloAuth');
    }
  }

  /// Get FCM token for current user
  static Future<String?> getFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['fcmToken'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete FCM token from user profile
  static Future<void> deleteFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }


} 