import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/flight_confirmation_state.dart' as domain;
import '../../domain/repositories/flight_confirmation_repository.dart';
import '../datasources/flight_confirmation_local_data_source.dart';
import '../../models/confirmation_args.dart';

part 'flight_confirmation_repository_impl.g.dart';

/// Repository implementation for flight confirmation
@riverpod
class FlightConfirmationRepositoryImpl extends _$FlightConfirmationRepositoryImpl implements FlightConfirmationRepository {
  @override
  Future<void> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  @override
  Future<domain.FlightConfirmationState> getConfirmationData(ConfirmationArgs args) async {
    final dataSource = ref.read(flightConfirmationLocalDataSourceProvider.notifier);
    return await dataSource.getConfirmationData(args);
  }

  @override
  Future<void> markConfettiShown() async {
    final dataSource = ref.read(flightConfirmationLocalDataSourceProvider.notifier);
    return await dataSource.markConfettiShown();
  }

  @override
  Future<bool> hasConfettiBeenShown() async {
    final dataSource = ref.read(flightConfirmationLocalDataSourceProvider.notifier);
    return await dataSource.hasConfettiBeenShown();
  }

  @override
  Future<void> resetConfettiForNewJourney() async {
    final dataSource = ref.read(flightConfirmationLocalDataSourceProvider.notifier);
    return await dataSource.resetConfettiForNewJourney();
  }
} 