import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/home_state.dart';
import '../../domain/usecases/load_home_data.dart';

part 'home_provider.g.dart';

/// Provider for home screen state management
@riverpod
Future<HomeState> homeProvider(HomeProviderRef ref, String username) async {
  return await ref.watch(loadHomeDataProvider(username).future);
} 