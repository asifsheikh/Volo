import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/flight_entity.dart';
import '../repositories/add_flight_repository.dart';
import '../../data/repositories/add_flight_repository_impl.dart';

part 'extract_flight_from_ticket.g.dart';

class ExtractFlightFromTicketParams extends Equatable {
  final String imagePath;

  const ExtractFlightFromTicketParams({
    required this.imagePath,
  });

  @override
  List<Object> get props => [imagePath];
}

class ExtractFlightFromTicket implements UseCase<FlightEntity, ExtractFlightFromTicketParams> {
  final AddFlightRepository repository;

  ExtractFlightFromTicket(this.repository);

  @override
  Future<Either<Failure, FlightEntity>> call(ExtractFlightFromTicketParams params) async {
    return await repository.extractFlightFromTicket(params.imagePath);
  }
}

// Riverpod provider for the use case
@riverpod
ExtractFlightFromTicket extractFlightFromTicket(Ref ref) {
  final repository = ref.watch(addFlightRepositoryProvider);
  return ExtractFlightFromTicket(repository);
} 