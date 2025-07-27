import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/onboarding_state.dart' as domain;
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_data_source.dart';

part 'onboarding_repository_impl.g.dart';

/// Repository implementation for onboarding
@riverpod
class OnboardingRepositoryImpl extends _$OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  Future<void> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  @override
  Future<domain.OnboardingState> getOnboardingData(String phoneNumber) async {
    final dataSource = ref.read(onboardingRemoteDataSourceProvider.notifier);
    return await dataSource.getOnboardingData(phoneNumber);
  }

  @override
  bool validateFirstName(String firstName) {
    final dataSource = ref.read(onboardingRemoteDataSourceProvider.notifier);
    return dataSource.validateFirstName(firstName);
  }

  @override
  Future<void> completeOnboarding({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final dataSource = ref.read(onboardingRemoteDataSourceProvider.notifier);
    return await dataSource.completeOnboarding(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
  }

  @override
  bool isUserAuthenticated() {
    final dataSource = ref.read(onboardingRemoteDataSourceProvider.notifier);
    return dataSource.isUserAuthenticated();
  }

  @override
  dynamic getCurrentUser() {
    final dataSource = ref.read(onboardingRemoteDataSourceProvider.notifier);
    return dataSource.getCurrentUser();
  }
} 