import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    required String phoneNumber,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String firstNameError,
    @Default(false) bool isFirstNameValid,
    @Default(false) bool isLoading,
    @Default(false) bool isCompleted,
    String? errorMessage,
  }) = _OnboardingState;
}

@freezed
class OnboardingArgs with _$OnboardingArgs {
  const factory OnboardingArgs({
    required String phoneNumber,
  }) = _OnboardingArgs;
}

@freezed
class WelcomeBackArgs with _$WelcomeBackArgs {
  const factory WelcomeBackArgs({
    required String userName,
  }) = _WelcomeBackArgs;
} 