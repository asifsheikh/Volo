import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

/// Home screen state entity
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default('') String username,
    @Default('') String? profilePictureUrl,
    @Default(true) bool isLoadingProfile,
    @Default(false) bool isOffline,
    @Default('') String? errorMessage,
  }) = _HomeState;
} 