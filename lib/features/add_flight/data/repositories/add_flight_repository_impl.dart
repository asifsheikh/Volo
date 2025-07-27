import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/add_flight_remote_data_source.dart';
import '../models/airport_model.dart';
import '../models/flight_model.dart';
import '../../domain/entities/airport_entity.dart';
import '../../domain/entities/flight_entity.dart';
import '../../domain/repositories/add_flight_repository.dart';

part 'add_flight_repository_impl.g.dart';

class AddFlightRepositoryImpl implements AddFlightRepository {
  final AddFlightRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddFlightRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<AirportEntity>>> getAirports() async {
    if (await networkInfo.isConnected) {
      try {
        final airports = await remoteDataSource.getAirports();
        return Right(airports);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<FlightEntity>>> searchFlights({
    required String departureIata,
    required String arrivalIata,
    required DateTime date,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final flights = await remoteDataSource.searchFlights(
          departureIata: departureIata,
          arrivalIata: arrivalIata,
          date: date,
        );
        return Right(flights);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, FlightEntity>> extractFlightFromTicket(String imagePath) async {
    if (await networkInfo.isConnected) {
      try {
        final flight = await remoteDataSource.extractFlightFromTicket(imagePath);
        return Right(flight);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, FlightEntity>> saveFlight(FlightEntity flight) async {
    if (await networkInfo.isConnected) {
      try {
        final savedFlight = await remoteDataSource.saveFlight(FlightModel(
          id: flight.id,
          departureCity: flight.departureCity,
          departureAirport: flight.departureAirport,
          departureIata: flight.departureIata,
          arrivalCity: flight.arrivalCity,
          arrivalAirport: flight.arrivalAirport,
          arrivalIata: flight.arrivalIata,
          departureDate: flight.departureDate,
          arrivalDate: flight.arrivalDate,
          airline: flight.airline,
          flightNumber: flight.flightNumber,
          gate: flight.gate,
          terminal: flight.terminal,
          status: flight.status,
        ));
        return Right(savedFlight);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}

// Riverpod provider for the repository
@riverpod
AddFlightRepository addFlightRepository(Ref ref) {
  final remoteDataSource = ref.watch(addFlightRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AddFlightRepositoryImpl(remoteDataSource, networkInfo);
} 