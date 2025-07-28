import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

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
      print('AuthNotifier: Auth state changed - user: ${user?.id}');
      try {
        print('AuthNotifier: About to update auth state');
        state = state.copyWith(
          user: user,
          isAuthenticated: user != null,
          error: null,
        );
        print('AuthNotifier: Auth state updated successfully');
      } catch (e) {
        print('AuthNotifier: Error in auth state change listener: $e');
        print('AuthNotifier: Error stack trace: ${StackTrace.current}');
        state = state.copyWith(
          error: 'Auth state change error: $e',
        );
      }
    });
  }

  Future<void> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    print('AuthNotifier: Starting signInWithPhone');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authRepository.signInWithPhone(
        phoneNumber: phoneNumber,
        verificationId: verificationId,
        smsCode: smsCode,
      );

      print('AuthNotifier: Repository result received');

      result.fold(
        (failure) {
          print('AuthNotifier: SignInWithPhone failed - ${failure.message}');
          state = state.copyWith(
            isLoading: false,
            error: failure.message ?? 'An error occurred',
          );
        },
        (user) {
          print('AuthNotifier: SignInWithPhone successful - user: ${user.id}');
          state = state.copyWith(
            isLoading: false,
            user: user,
            isAuthenticated: true,
            error: null,
          );
        },
      );
    } catch (e) {
      print('AuthNotifier: Exception in signInWithPhone: $e');
      print('AuthNotifier: Exception stack trace: ${StackTrace.current}');
      state = state.copyWith(
        isLoading: false,
        error: 'Sign in failed: $e',
      );
    }
  }

  Future<String?> sendOTP({required String phoneNumber}) async {
    developer.log('AuthNotifier: Starting sendOTP for phone: $phoneNumber', name: 'VoloAuth');
    print('AuthNotifier: Starting sendOTP for phone: $phoneNumber');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authRepository.sendOTP(phoneNumber: phoneNumber);
      developer.log('AuthNotifier: Repository result received', name: 'VoloAuth');
      print('AuthNotifier: Repository result received for sendOTP');

      return result.fold(
        (failure) {
          developer.log('AuthNotifier: SendOTP failed - ${failure.message}', name: 'VoloAuth');
          print('AuthNotifier: SendOTP failed - ${failure.message}');
          state = state.copyWith(
            isLoading: false,
            error: failure.message ?? 'An error occurred',
          );
          return null;
        },
        (verificationId) {
          developer.log('AuthNotifier: SendOTP successful - verificationId: $verificationId', name: 'VoloAuth');
          print('AuthNotifier: SendOTP successful - verificationId: $verificationId');
          state = state.copyWith(
            isLoading: false,
            error: null,
          );
          return verificationId;
        },
      );
    } catch (e) {
      developer.log('AuthNotifier: SendOTP exception - $e', name: 'VoloAuth');
      print('AuthNotifier: SendOTP exception - $e');
      print('AuthNotifier: SendOTP exception stack trace: ${StackTrace.current}');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send OTP: $e',
      );
      return null;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message ?? 'An error occurred',
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
          error: failure.message ?? 'An error occurred',
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
    print('AuthNotifier: Clearing error');
    state = state.copyWith(error: null);
  }
}

// Provider
@riverpod
AuthNotifier authNotifier(Ref ref) {
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