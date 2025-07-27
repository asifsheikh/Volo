import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/airport_entity.dart';
import '../../domain/entities/flight_entity.dart';
import '../../domain/usecases/get_airports.dart';
import '../../domain/usecases/search_flights.dart';
import '../../domain/usecases/extract_flight_from_ticket.dart';
import '../../data/repositories/add_flight_repository_impl.dart';

part 'add_flight_provider.g.dart';

// Add Flight State
class AddFlightState {
  final bool isLoading;
  final List<AirportEntity> airports;
  final List<FlightEntity> searchResults;
  final FlightEntity? extractedFlight;
  final String? error;
  final bool isSearching;
  final bool isExtracting;

  const AddFlightState({
    this.isLoading = false,
    this.airports = const [],
    this.searchResults = const [],
    this.extractedFlight,
    this.error,
    this.isSearching = false,
    this.isExtracting = false,
  });

  AddFlightState copyWith({
    bool? isLoading,
    List<AirportEntity>? airports,
    List<FlightEntity>? searchResults,
    FlightEntity? extractedFlight,
    String? error,
    bool? isSearching,
    bool? isExtracting,
  }) {
    return AddFlightState(
      isLoading: isLoading ?? this.isLoading,
      airports: airports ?? this.airports,
      searchResults: searchResults ?? this.searchResults,
      extractedFlight: extractedFlight ?? this.extractedFlight,
      error: error ?? this.error,
      isSearching: isSearching ?? this.isSearching,
      isExtracting: isExtracting ?? this.isExtracting,
    );
  }
}

// Add Flight Notifier
class AddFlightNotifier extends StateNotifier<AddFlightState> {
  final GetAirports _getAirports;
  final SearchFlights _searchFlights;
  final ExtractFlightFromTicket _extractFlightFromTicket;

  AddFlightNotifier(
    this._getAirports,
    this._searchFlights,
    this._extractFlightFromTicket,
  ) : super(const AddFlightState()) {
    _loadAirports();
  }

  Future<void> _loadAirports() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAirports(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message ?? 'Failed to load airports',
        );
      },
      (airports) {
        state = state.copyWith(
          isLoading: false,
          airports: airports,
          error: null,
        );
      },
    );
  }

  Future<void> searchFlights({
    required String departureIata,
    required String arrivalIata,
    required DateTime date,
  }) async {
    state = state.copyWith(isSearching: true, error: null);

    final result = await _searchFlights(SearchFlightsParams(
      departureIata: departureIata,
      arrivalIata: arrivalIata,
      date: date,
    ));

    result.fold(
      (failure) {
        state = state.copyWith(
          isSearching: false,
          error: failure.message ?? 'Failed to search flights',
        );
      },
      (flights) {
        state = state.copyWith(
          isSearching: false,
          searchResults: flights,
          error: null,
        );
      },
    );
  }

  Future<void> extractFlightFromTicket(String imagePath) async {
    state = state.copyWith(isExtracting: true, error: null);

    final result = await _extractFlightFromTicket(
      ExtractFlightFromTicketParams(imagePath: imagePath),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isExtracting: false,
          error: failure.message ?? 'Failed to extract flight from ticket',
        );
      },
      (flight) {
        state = state.copyWith(
          isExtracting: false,
          extractedFlight: flight,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSearchResults() {
    state = state.copyWith(searchResults: []);
  }

  void clearExtractedFlight() {
    state = state.copyWith(extractedFlight: null);
  }
}

// Provider
@riverpod
AddFlightNotifier addFlightNotifier(Ref ref) {
  final getAirports = ref.watch(getAirportsProvider);
  final searchFlights = ref.watch(searchFlightsProvider);
  final extractFlightFromTicket = ref.watch(extractFlightFromTicketProvider);
  return AddFlightNotifier(getAirports, searchFlights, extractFlightFromTicket);
}

// State provider
final addFlightStateProvider = StateNotifierProvider<AddFlightNotifier, AddFlightState>((ref) {
  return ref.watch(addFlightNotifierProvider);
});

// Convenience providers
final airportsProvider = Provider<List<AirportEntity>>((ref) {
  return ref.watch(addFlightStateProvider).airports;
});

final searchResultsProvider = Provider<List<FlightEntity>>((ref) {
  return ref.watch(addFlightStateProvider).searchResults;
});

final extractedFlightProvider = Provider<FlightEntity?>((ref) {
  return ref.watch(addFlightStateProvider).extractedFlight;
});

final addFlightLoadingProvider = Provider<bool>((ref) {
  return ref.watch(addFlightStateProvider).isLoading;
});

final addFlightErrorProvider = Provider<String?>((ref) {
  return ref.watch(addFlightStateProvider).error;
});

final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(addFlightStateProvider).isSearching;
});

final isExtractingProvider = Provider<bool>((ref) {
  return ref.watch(addFlightStateProvider).isExtracting;
}); 