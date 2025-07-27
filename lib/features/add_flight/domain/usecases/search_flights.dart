import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/flight_entity.dart';
import '../repositories/add_flight_repository.dart';
import '../../data/repositories/add_flight_repository_impl.dart';

part 'search_flights.g.dart';

class SearchFlightsParams extends Equatable {
  final String departureIata;
  final String arrivalIata;
  final DateTime date;

  const SearchFlightsParams({
    required this.departureIata,
    required this.arrivalIata,
    required this.date,
  });

  @override
  List<Object> get props => [departureIata, arrivalIata, date];
}

class SearchFlights implements UseCase<List<FlightEntity>, SearchFlightsParams> {
  final AddFlightRepository repository;

  SearchFlights(this.repository);

  @override
  Future<Either<Failure, List<FlightEntity>>> call(SearchFlightsParams params) async {
    return await repository.searchFlights(
      departureIata: params.departureIata,
      arrivalIata: params.arrivalIata,
      date: params.date,
    );
  }
}

// Riverpod provider for the use case
@riverpod
SearchFlights searchFlights(Ref ref) {
  final repository = ref.watch(addFlightRepositoryProvider);
  return SearchFlights(repository);
} 