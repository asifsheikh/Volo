import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/profile_state.dart' as domain;
import '../../domain/usecases/get_profile_data.dart';

part 'profile_provider.g.dart';

/// Provider for profile state management
@riverpod
Future<domain.ProfileState> profileProvider(ProfileProviderRef ref, String username, String phoneNumber) async {
  return await ref.watch(getProfileDataProvider(username, phoneNumber).future);
} 