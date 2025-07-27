import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/home_state.dart';
import '../repositories/home_repository.dart';
import '../../data/repositories/home_repository_impl.dart';

part 'load_home_data.g.dart';

/// Use case for loading home screen data
@riverpod
class LoadHomeData extends _$LoadHomeData {
  @override
  Future<HomeState> build(String username) async {
    return _loadHomeData(username);
  }

  Future<HomeState> _loadHomeData(String username) async {
    try {
      final repository = ref.read(homeRepositoryImplProvider);
      
      // Check network connectivity first
      final hasInternet = await repository.hasInternetConnection();
      
      if (!hasInternet) {
        return HomeState(
          username: username,
          isLoadingProfile: false,
          isOffline: true,
        );
      }

      // Load profile picture if online
      final profilePictureUrl = await repository.getUserProfilePictureUrl();
      
      return HomeState(
        username: username,
        profilePictureUrl: profilePictureUrl,
        isLoadingProfile: false,
        isOffline: false,
      );
    } catch (e) {
      return HomeState(
        username: username,
        isLoadingProfile: false,
        isOffline: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh home data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadHomeData(state.value?.username ?? ''));
  }
} 