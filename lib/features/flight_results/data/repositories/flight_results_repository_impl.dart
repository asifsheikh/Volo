import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/flight_results_state.dart' as domain;
import '../../domain/repositories/flight_results_repository.dart';
import '../datasources/flight_results_remote_data_source.dart';

part 'flight_results_repository_impl.g.dart';

/// Repository implementation for flight results
@riverpod
class FlightResultsRepositoryImpl extends _$FlightResultsRepositoryImpl implements FlightResultsRepository {
  @override
  Future<domain.FlightResultsState> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  @override
  Future<domain.FlightResultsState> getFlightResults({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) async {
    final dataSource = ref.read(flightResultsRemoteDataSourceProvider.notifier);
    return await dataSource.getFlightResults(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  @override
  Future<bool> hasInternetConnection() async {
    final dataSource = ref.read(flightResultsRemoteDataSourceProvider.notifier);
    return await dataSource.hasInternetConnection();
  }
} 