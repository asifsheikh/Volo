import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/profile_state.dart' as domain;
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../../../services/profile_picture_service.dart';
import '../../../../services/firebase_service.dart';

part 'profile_repository_impl.g.dart';

/// Repository implementation for profile
@riverpod
class ProfileRepositoryImpl extends _$ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<void> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  @override
  Future<domain.ProfileState> getProfileData(String username, String phoneNumber) async {
    final dataSource = ref.read(profileRemoteDataSourceProvider.notifier);
    return await dataSource.getProfileData(username, phoneNumber);
  }

  @override
  Future<String?> loadProfilePicture() async {
    final dataSource = ref.read(profileRemoteDataSourceProvider.notifier);
    return await dataSource.loadProfilePicture();
  }

  @override
  Future<bool> updateProfilePicture() async {
    try {
      // This requires BuildContext, so we'll handle it in the screen
      // For now, return false to indicate it needs to be handled differently
      return false;
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  @override
  Future<void> signOut() async {
    final dataSource = ref.read(profileRemoteDataSourceProvider.notifier);
    return await dataSource.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // This requires BuildContext, so we need to handle it differently
      // For now, we'll just sign out
      await FirebaseService.signOut();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  @override
  Future<String?> getFCMToken() async {
    final dataSource = ref.read(profileRemoteDataSourceProvider.notifier);
    return await dataSource.getFCMToken();
  }

  @override
  Future<void> testFirebaseMessaging() async {
    final dataSource = ref.read(profileRemoteDataSourceProvider.notifier);
    return await dataSource.testFirebaseMessaging();
  }

  @override
  Future<void> testLocalNotification() async {
    final dataSource = ref.read(profileRemoteDataSourceProvider.notifier);
    return await dataSource.testLocalNotification();
  }
} 