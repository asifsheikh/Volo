import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

// Auth State
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((user) {
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        error: null,
      );
    });
  }

  Future<void> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.signInWithPhone(
      phoneNumber: phoneNumber,
      verificationId: verificationId,
      smsCode: smsCode,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
          error: null,
        );
      },
    );
  }

  Future<void> sendOTP({required String phoneNumber}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.sendOTP(phoneNumber: phoneNumber);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          user: null,
          isAuthenticated: false,
          error: null,
        );
      },
    );
  }

  Future<void> updateProfile({
    required String displayName,
    String? photoURL,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
@riverpod
AuthNotifier authNotifier(AuthNotifierRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
}

// State provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).error;
}); 