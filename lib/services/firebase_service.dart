import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // Try to access Firestore Users collection
      await _firestore.collection('Users').limit(1).get();
      developer.log('Firebase connection test successful', name: 'FirebaseService');
      return true;
    } catch (e) {
      developer.log('Firebase connection test failed: $e', name: 'FirebaseService');
      return false;
    }
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
      developer.log('User signed out successfully', name: 'FirebaseService');
    } catch (e) {
      developer.log('Error signing out: $e', name: 'FirebaseService');
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

      await _firestore.collection('Users').doc(user.uid).set(userData);
      developer.log('User profile saved successfully', name: 'FirebaseService');
    } catch (e) {
      developer.log('Error saving user profile: $e', name: 'FirebaseService');
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

      final doc = await _firestore.collection('Users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        developer.log('User profile retrieved successfully', name: 'FirebaseService');
        return data;
      } else {
        developer.log('User profile not found', name: 'FirebaseService');
        return null;
      }
    } catch (e) {
      developer.log('Error getting user profile: $e', name: 'FirebaseService');
      return null;
    }
  }

  // Check if user has completed onboarding
  static Future<bool> isUserOnboarded() async {
    try {
      final profile = await getUserProfile();
      return profile != null && (profile['isOnboarded'] == true);
    } catch (e) {
      developer.log('Error checking onboarding status: $e', name: 'FirebaseService');
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
      
      await _firestore.collection('Users').doc(user.uid).update(updates);
      developer.log('User profile updated successfully', name: 'FirebaseService');
    } catch (e) {
      developer.log('Error updating user profile: $e', name: 'FirebaseService');
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
      await _firestore.collection('Users').doc(user.uid).delete();
      
      // Delete the user account
      await user.delete();
      
      developer.log('User account deleted successfully', name: 'FirebaseService');
    } catch (e) {
      developer.log('Error deleting user account: $e', name: 'FirebaseService');
      rethrow;
    }
  }

  // Listen to authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Listen to user changes
  static Stream<User?> get userChanges => _auth.userChanges();
} 