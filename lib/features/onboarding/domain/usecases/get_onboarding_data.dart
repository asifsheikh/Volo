import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/onboarding_state.dart' as domain;
import '../repositories/onboarding_repository.dart';
import '../../data/repositories/onboarding_repository_impl.dart';

part 'get_onboarding_data.g.dart';

/// Use case for getting onboarding data
@riverpod
class GetOnboardingData extends _$GetOnboardingData {
  @override
  Future<domain.OnboardingState> build(String phoneNumber) async {
    return _getOnboardingData(phoneNumber);
  }

  Future<domain.OnboardingState> _getOnboardingData(String phoneNumber) async {
    try {
      final repository = ref.read(onboardingRepositoryImplProvider.notifier);
      
      // Get onboarding data
      final onboardingData = await repository.getOnboardingData(phoneNumber);
      
      return onboardingData;
    } catch (e) {
      throw Exception('Failed to get onboarding data: $e');
    }
  }

  /// Validate first name
  bool validateFirstName(String firstName) {
    try {
      final repository = ref.read(onboardingRepositoryImplProvider.notifier);
      return repository.validateFirstName(firstName);
    } catch (e) {
      throw Exception('Failed to validate first name: $e');
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final repository = ref.read(onboardingRepositoryImplProvider.notifier);
      await repository.completeOnboarding(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  /// Check if user is authenticated
  bool isUserAuthenticated() {
    try {
      final repository = ref.read(onboardingRepositoryImplProvider.notifier);
      return repository.isUserAuthenticated();
    } catch (e) {
      throw Exception('Failed to check authentication: $e');
    }
  }

  /// Get current user
  dynamic getCurrentUser() {
    try {
      final repository = ref.read(onboardingRepositoryImplProvider.notifier);
      return repository.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
} 