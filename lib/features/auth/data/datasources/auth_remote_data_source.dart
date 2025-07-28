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
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<String> sendOTP({
    required String phoneNumber,
  }) async {
    developer.log('AuthRemoteDataSourceImpl: Starting sendOTP for phone: $phoneNumber', name: 'VoloAuth');
    try {
      final completer = Completer<String>();
      Exception? verificationError;
      
      developer.log('AuthRemoteDataSourceImpl: Calling Firebase verifyPhoneNumber', name: 'VoloAuth');
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          developer.log('AuthRemoteDataSourceImpl: Auto-verification completed', name: 'VoloAuth');
          // Auto-verification if possible
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          developer.log('AuthRemoteDataSourceImpl: Verification failed - Code: ${e.code}, Message: ${e.message}', name: 'VoloAuth');
          verificationError = Exception('Verification failed: ${e.message}');
          if (!completer.isCompleted) {
            completer.completeError(verificationError!);
          }
        },
        codeSent: (String vid, int? resendToken) {
          developer.log('AuthRemoteDataSourceImpl: Code sent successfully - verificationId: $vid', name: 'VoloAuth');
          if (!completer.isCompleted) {
            completer.complete(vid);
          }
        },
        codeAutoRetrievalTimeout: (String vid) {
          developer.log('AuthRemoteDataSourceImpl: Auto-retrieval timeout - verificationId: $vid', name: 'VoloAuth');
          if (!completer.isCompleted) {
            completer.complete(vid);
          }
        },
        timeout: const Duration(seconds: 60),
      );
      
      developer.log('AuthRemoteDataSourceImpl: Waiting for completer result', name: 'VoloAuth');
      // Wait for the result from the callbacks
      final result = await completer.future;
      
      if (verificationError != null) {
        developer.log('AuthRemoteDataSourceImpl: Throwing verification error', name: 'VoloAuth');
        throw verificationError!;
      }
      
      if (result == null || result.isEmpty) {
        developer.log('AuthRemoteDataSourceImpl: No verification ID received', name: 'VoloAuth');
        throw Exception('Failed to get verification ID');
      }
      
      developer.log('AuthRemoteDataSourceImpl: Successfully returning verificationId: $result', name: 'VoloAuth');
      return result;
    } catch (e) {
      developer.log('AuthRemoteDataSourceImpl: Exception in sendOTP: $e', name: 'VoloAuth');
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
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRemoteDataSourceImpl(firebaseAuth, firestore);
} 