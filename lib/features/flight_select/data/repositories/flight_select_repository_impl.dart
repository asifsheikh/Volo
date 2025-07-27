import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/flight_select_state.dart' as domain;
import '../../domain/repositories/flight_select_repository.dart';
import '../datasources/flight_select_remote_data_source.dart';

part 'flight_select_repository_impl.g.dart';

/// Repository implementation for flight select
@riverpod
class FlightSelectRepositoryImpl extends _$FlightSelectRepositoryImpl implements FlightSelectRepository {
  @override
  Future<domain.FlightSelectState> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  @override
  Future<domain.FlightSelectState> getFlightSelectData({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) async {
    final dataSource = ref.read(flightSelectRemoteDataSourceProvider.notifier);
    return await dataSource.getFlightSelectData(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  @override
  Future<bool> hasInternetConnection() async {
    final dataSource = ref.read(flightSelectRemoteDataSourceProvider.notifier);
    return await dataSource.hasInternetConnection();
  }
} 