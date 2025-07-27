import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/airport_entity.dart';
import '../repositories/add_flight_repository.dart';
import '../../data/repositories/add_flight_repository_impl.dart';

part 'get_airports.g.dart';

class GetAirports implements UseCase<List<AirportEntity>, NoParams> {
  final AddFlightRepository repository;

  GetAirports(this.repository);

  @override
  Future<Either<Failure, List<AirportEntity>>> call(NoParams params) async {
    return await repository.getAirports();
  }
}

// Riverpod provider for the use case
@riverpod
GetAirports getAirports(Ref ref) {
  final repository = ref.watch(addFlightRepositoryProvider);
  return GetAirports(repository);
} 