import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static late final FirebaseFirestore _firestore;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Initialize Firestore with the correct database name
    _firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'Volo', // Use the "Volo" database
    );
    
    developer.log('FirebaseService: Initialized with database: Volo', name: 'FirebaseService');
  }

  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      developer.log('FirebaseService: Testing Firestore connection...', name: 'FirebaseService');
      
      // Try to access Firestore users collection
      final querySnapshot = await _firestore.collection('users').limit(1).get();
      developer.log('FirebaseService: Connection test successful - found ${querySnapshot.docs.length} documents', name: 'FirebaseService');
      return true;
    } catch (e) {
      developer.log('FirebaseService: Connection test failed: $e', name: 'FirebaseService');
      developer.log('FirebaseService: Error type: ${e.runtimeType}', name: 'FirebaseService');
      return false;
    }
  }

  // Comprehensive Firestore test
  static Future<Map<String, dynamic>> testFirestoreComprehensive() async {
    final results = <String, dynamic>{};
    
    try {
      developer.log('FirebaseService: Starting comprehensive Firestore test', name: 'FirebaseService');
      
      // Test 1: Basic connection
      results['basic_connection'] = await testConnection();
      
      // Test 2: Authentication status
      final user = _auth.currentUser;
      results['user_authenticated'] = user != null;
      results['user_uid'] = user?.uid;
      results['user_phone'] = user?.phoneNumber;
      
      // Test 3: Try to write a test document
      if (user != null) {
        try {
          final testData = {
            'test': true,
            'timestamp': FieldValue.serverTimestamp(),
          };
          
          await _firestore.collection('users').doc('test_${user.uid}').set(testData);
          results['write_test'] = true;
          
          // Clean up test document
          await _firestore.collection('users').doc('test_${user.uid}').delete();
          results['delete_test'] = true;
          
        } catch (e) {
          results['write_test'] = false;
          results['write_error'] = e.toString();
        }
      } else {
        results['write_test'] = false;
        results['write_error'] = 'No authenticated user';
      }
      
      developer.log('FirebaseService: Comprehensive test results: $results', name: 'FirebaseService');
      
    } catch (e) {
      developer.log('FirebaseService: Comprehensive test failed: $e', name: 'FirebaseService');
      results['overall_error'] = e.toString();
    }
    
    return results;
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
      developer.log('FirebaseService: Starting saveUserProfile', name: 'FirebaseService');
      
      final user = _auth.currentUser;
      developer.log('FirebaseService: Current user: ${user?.uid ?? 'null'}', name: 'FirebaseService');
      
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

      developer.log('FirebaseService: User data prepared: $userData', name: 'FirebaseService');
      developer.log('FirebaseService: Attempting to save to users/${user.uid}', name: 'FirebaseService');

      // Test Firestore connection first
      final connectionTest = await testConnection();
      developer.log('FirebaseService: Connection test result: $connectionTest', name: 'FirebaseService');
      
      if (!connectionTest) {
        throw Exception('Firestore connection failed');
      }

      await _firestore.collection('users').doc(user.uid).set(userData);
      developer.log('FirebaseService: User profile saved successfully', name: 'FirebaseService');
    } catch (e) {
      developer.log('FirebaseService: Error saving user profile: $e', name: 'FirebaseService');
      developer.log('FirebaseService: Error type: ${e.runtimeType}', name: 'FirebaseService');
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
      
      await _firestore.collection('users').doc(user.uid).update(updates);
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
      await _firestore.collection('users').doc(user.uid).delete();
      
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