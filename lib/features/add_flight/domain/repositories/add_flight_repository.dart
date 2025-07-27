import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/flight_entity.dart';
import '../entities/airport_entity.dart';

abstract class AddFlightRepository {
  Future<Either<Failure, List<AirportEntity>>> getAirports();
  Future<Either<Failure, List<FlightEntity>>> searchFlights({
    required String departureIata,
    required String arrivalIata,
    required DateTime date,
  });
  Future<Either<Failure, FlightEntity>> extractFlightFromTicket(String imagePath);
  Future<Either<Failure, FlightEntity>> saveFlight(FlightEntity flight);
} 