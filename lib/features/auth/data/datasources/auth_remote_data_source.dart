import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';

part 'auth_remote_data_source.g.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  });
  
  Future<void> sendOTP({
    required String phoneNumber,
  });
  
  Future<UserModel?> getCurrentUser();
  
  Future<void> signOut();
  
  Future<UserModel> updateUserProfile({
    required String displayName,
    String? photoURL,
  });
  
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Create or update user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'phoneNumber': phoneNumber,
        'lastSignInAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendOTP({
    required String phoneNumber,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification if possible
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Code sent successfully
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout
        },
      );
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel> updateUserProfile({
    required String displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }
}

// Riverpod provider for the data source
@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRemoteDataSourceImpl(firebaseAuth, firestore);
} 