import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/trip/trip_model.dart';
import '../../../../services/trip_service.dart';

part 'flights_provider.g.dart';

@riverpod
class FlightsNotifier extends _$FlightsNotifier {
  @override
  Future<FlightsState> build() async {
    return await _loadTrips();
  }

  Future<FlightsState> _loadTrips() async {
    try {
      final userId = TripService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final allTrips = await TripService.getUserTrips(userId);
      final now = DateTime.now();

      // Separate trips into upcoming and past
      final upcoming = <Trip>[];
      final past = <Trip>[];

      for (final trip in allTrips) {
        final departureTime = trip.tripData.departureTime;
        if (departureTime.isAfter(now)) {
          upcoming.add(trip);
        } else {
          past.add(trip);
        }
      }

      // Sort upcoming trips by departure time (earliest first)
      upcoming.sort((a, b) => a.tripData.departureTime.compareTo(b.tripData.departureTime));
      
      // Sort past trips by departure time (most recent first)
      past.sort((a, b) => b.tripData.departureTime.compareTo(a.tripData.departureTime));

      return FlightsState(
        upcomingTrips: upcoming,
        pastTrips: past,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      return FlightsState(
        upcomingTrips: [],
        pastTrips: [],
        isLoading: false,
        errorMessage: 'Failed to load trips: ${e.toString()}',
      );
    }
  }

  Future<void> refreshTrips() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadTrips());
  }
}

class FlightsState {
  final List<Trip> upcomingTrips;
  final List<Trip> pastTrips;
  final bool isLoading;
  final String? errorMessage;

  const FlightsState({
    required this.upcomingTrips,
    required this.pastTrips,
    required this.isLoading,
    this.errorMessage,
  });
} 