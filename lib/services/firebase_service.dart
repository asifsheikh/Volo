import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isOnboarded': true,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
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

  // Check if user has completed onboarding
  static Future<bool> isUserOnboarded() async {
    try {
      final profile = await getUserProfile();
      // User is onboarded only if profile exists AND isOnboarded flag is true
      return profile != null && (profile['isOnboarded'] == true);
    } catch (e) {
      // If there's any error getting the profile, user is not onboarded
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
} 