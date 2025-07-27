import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/onboarding_state.dart' as domain;
import '../../domain/usecases/get_onboarding_data.dart';

part 'onboarding_provider.g.dart';

/// Provider for onboarding state management
@riverpod
Future<domain.OnboardingState> onboardingProvider(OnboardingProviderRef ref, String phoneNumber) async {
  return await ref.watch(getOnboardingDataProvider(phoneNumber).future);
} 