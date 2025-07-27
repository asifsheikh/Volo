import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    required String username,
    required String phoneNumber,
    String? profilePictureUrl,
    @Default(false) bool isLoading,
    @Default(false) bool isUpdatingProfilePicture,
    @Default(false) bool isSigningOut,
    @Default(false) bool isDeletingAccount,
    String? errorMessage,
  }) = _ProfileState;
}

@freezed
class ProfileArgs with _$ProfileArgs {
  const factory ProfileArgs({
    required String username,
    required String phoneNumber,
  }) = _ProfileArgs;
} 