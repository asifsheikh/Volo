import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/profile_picture_service.dart';
import '../../../../services/network_service.dart';

part 'home_remote_data_source.g.dart';

/// Remote data source for home feature
@riverpod
class HomeRemoteDataSource extends _$HomeRemoteDataSource {
  @override
  HomeRemoteDataSource build() {
    return this;
  }

  /// Get user profile picture URL
  Future<String?> getUserProfilePictureUrl() async {
    try {
      return await ProfilePictureService.getUserProfilePictureUrl();
    } catch (e) {
      throw Exception('Failed to load profile picture: $e');
    }
  }

  /// Check network connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final networkService = NetworkService();
      return await networkService.hasInternetConnection();
    } catch (e) {
      throw Exception('Failed to check network connectivity: $e');
    }
  }

  /// Get user phone number
  String? getUserPhoneNumber() {
    try {
      return FirebaseService.getUserPhoneNumber();
    } catch (e) {
      throw Exception('Failed to get user phone number: $e');
    }
  }
} 