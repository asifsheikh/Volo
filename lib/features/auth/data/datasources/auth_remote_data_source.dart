import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:developer' as developer;

import '../models/user_model.dart';
import '../../../../core/di/providers.dart';

part 'auth_remote_data_source.g.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  });
  
  Future<String> sendOTP({
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
      // Provide user-friendly error messages for OTP verification
      String userFriendlyMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-verification-code':
            userFriendlyMessage = 'Invalid verification code. Please check and try again.';
            break;
          case 'invalid-verification-id':
            userFriendlyMessage = 'Invalid verification ID. Please request a new code.';
            break;
          case 'session-expired':
            userFriendlyMessage = 'Verification session expired. Please request a new code.';
            break;
          case 'credential-already-in-use':
            userFriendlyMessage = 'This phone number is already registered with another account.';
            break;
          case 'user-disabled':
            userFriendlyMessage = 'This account has been disabled.';
            break;
          case 'operation-not-allowed':
            userFriendlyMessage = 'Phone authentication is not enabled.';
            break;
          default:
            userFriendlyMessage = e.message ?? 'Verification failed. Please try again.';
        }
      } else {
        userFriendlyMessage = 'Sign in failed. Please try again.';
      }
      throw Exception(userFriendlyMessage);
}
  }

  @override
  Future<String> sendOTP({
    required String phoneNumber,
  }) async {
    try {
      final completer = Completer<String>();
      Exception? verificationError;
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification if possible
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          // Provide user-friendly error messages for common iOS issues
          String userFriendlyMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              userFriendlyMessage = 'Invalid phone number. Please check and try again.';
              break;
            case 'too-many-requests':
              userFriendlyMessage = 'Too many attempts. Please try again later.';
              break;
            case 'quota-exceeded':
              userFriendlyMessage = 'SMS quota exceeded. Please try again later.';
              break;
            case 'app-not-authorized':
              userFriendlyMessage = 'App not authorized for phone authentication.';
              break;
            case 'missing-phone-number':
              userFriendlyMessage = 'Phone number is required.';
              break;
            case 'invalid-verification-code':
              userFriendlyMessage = 'Invalid verification code. Please try again.';
              break;
            case 'invalid-verification-id':
              userFriendlyMessage = 'Invalid verification ID. Please request a new code.';
              break;
            case 'session-expired':
              userFriendlyMessage = 'Verification session expired. Please request a new code.';
              break;
            default:
              userFriendlyMessage = e.message ?? 'Verification failed. Please try again.';
          }
          
          verificationError = Exception(userFriendlyMessage);
          if (!completer.isCompleted) {
            completer.completeError(verificationError!);
          }
        },
        codeSent: (String vid, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(vid);
          }
        },
        codeAutoRetrievalTimeout: (String vid) {
          if (!completer.isCompleted) {
            completer.complete(vid);
          }
        },
        timeout: const Duration(seconds: 60),
      );
      
      // Wait for the result from the callbacks
      final result = await completer.future;
      
      if (verificationError != null) {
        throw verificationError!;
      }
      
      if (result == null || result.isEmpty) {
        throw Exception('Failed to get verification ID');
      }
      
      return result;
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
      if (user == null) {
        return null;
      }
      try {
        return UserModel.fromFirebaseUser(user);
      } catch (e) {
        rethrow;
      }
    });
  }
}

// Riverpod provider for the data source
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRemoteDataSourceImpl(firebaseAuth, firestore);
} 