import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/onboarding_state.dart' as domain;
import '../../../../services/firebase_service.dart';

part 'onboarding_remote_data_source.g.dart';

/// Remote data source for onboarding
@riverpod
class OnboardingRemoteDataSource extends _$OnboardingRemoteDataSource {
  @override
  Future<domain.OnboardingState> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  /// Get onboarding data
  Future<domain.OnboardingState> getOnboardingData(String phoneNumber) async {
    try {
      return domain.OnboardingState(
        phoneNumber: phoneNumber,
        firstName: '',
        lastName: '',
        firstNameError: '',
        isFirstNameValid: false,
        isLoading: false,
        isCompleted: false,
      );
    } catch (e) {
      throw Exception('Failed to get onboarding data: $e');
    }
  }

  /// Validate first name
  bool validateFirstName(String firstName) {
    return firstName.isNotEmpty && RegExp(r'^[a-zA-Z]+$').hasMatch(firstName);
  }

  /// Complete onboarding and save user profile
  Future<void> completeOnboarding({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Check if user is authenticated
      final currentUser = FirebaseService.getCurrentUser();
      
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Save user profile to Firestore
      await FirebaseService.saveUserProfile(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  /// Check if user is authenticated
  bool isUserAuthenticated() {
    try {
      return FirebaseService.getCurrentUser() != null;
    } catch (e) {
      throw Exception('Failed to check authentication: $e');
    }
  }

  /// Get current user
  dynamic getCurrentUser() {
    try {
      return FirebaseService.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
} 