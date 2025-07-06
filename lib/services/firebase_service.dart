import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      // Try to access Firestore
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with phone number
  static Future<void> signInWithPhoneNumber(String phoneNumber) async {
    // This is a placeholder for phone authentication
    // You'll need to implement the full phone auth flow
    print('Phone authentication not yet implemented');
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Save user data to Firestore
  static Future<void> saveUserData(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set(userData);
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }
} 