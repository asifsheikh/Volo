import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/flight_confirmation_state.dart' as domain;
import '../../domain/usecases/get_confirmation_data.dart';
import '../../models/confirmation_args.dart';

part 'flight_confirmation_provider.g.dart';

/// Provider for flight confirmation state management
@riverpod
Future<domain.FlightConfirmationState> flightConfirmationProvider(FlightConfirmationProviderRef ref, ConfirmationArgs args) async {
  return await ref.watch(getConfirmationDataProvider(args).future);
} 