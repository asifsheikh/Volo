// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_results_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flightResultsProviderHash() =>
    r'165fef5cfe08779f755b72842be8d80034fe8d25';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for flight results state management
///
/// Copied from [flightResultsProvider].
@ProviderFor(flightResultsProvider)
const flightResultsProviderProvider = FlightResultsProviderFamily();

/// Provider for flight results state management
///
/// Copied from [flightResultsProvider].
class FlightResultsProviderFamily
    extends Family<AsyncValue<domain.FlightResultsState>> {
  /// Provider for flight results state management
  ///
  /// Copied from [flightResultsProvider].
  const FlightResultsProviderFamily();

  /// Provider for flight results state management
  ///
  /// Copied from [flightResultsProvider].
  FlightResultsProviderProvider call({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) {
    return FlightResultsProviderProvider(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  @override
  FlightResultsProviderProvider getProviderOverride(
    covariant FlightResultsProviderProvider provider,
  ) {
    return call(
      departureCity: provider.departureCity,
      arrivalCity: provider.arrivalCity,
      date: provider.date,
      flightNumber: provider.flightNumber,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'flightResultsProviderProvider';
}

/// Provider for flight results state management
///
/// Copied from [flightResultsProvider].
class FlightResultsProviderProvider
    extends AutoDisposeFutureProvider<domain.FlightResultsState> {
  /// Provider for flight results state management
  ///
  /// Copied from [flightResultsProvider].
  FlightResultsProviderProvider({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) : this._internal(
         (ref) => flightResultsProvider(
           ref as FlightResultsProviderRef,
           departureCity: departureCity,
           arrivalCity: arrivalCity,
           date: date,
           flightNumber: flightNumber,
         ),
         from: flightResultsProviderProvider,
         name: r'flightResultsProviderProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$flightResultsProviderHash,
         dependencies: FlightResultsProviderFamily._dependencies,
         allTransitiveDependencies:
             FlightResultsProviderFamily._allTransitiveDependencies,
         departureCity: departureCity,
         arrivalCity: arrivalCity,
         date: date,
         flightNumber: flightNumber,
       );

  FlightResultsProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.departureCity,
    required this.arrivalCity,
    required this.date,
    required this.flightNumber,
  }) : super.internal();

  final String departureCity;
  final String arrivalCity;
  final String date;
  final String? flightNumber;

  @override
  Override overrideWith(
    FutureOr<domain.FlightResultsState> Function(
      FlightResultsProviderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FlightResultsProviderProvider._internal(
        (ref) => create(ref as FlightResultsProviderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        departureCity: departureCity,
        arrivalCity: arrivalCity,
        date: date,
        flightNumber: flightNumber,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<domain.FlightResultsState> createElement() {
    return _FlightResultsProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FlightResultsProviderProvider &&
        other.departureCity == departureCity &&
        other.arrivalCity == arrivalCity &&
        other.date == date &&
        other.flightNumber == flightNumber;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, departureCity.hashCode);
    hash = _SystemHash.combine(hash, arrivalCity.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, flightNumber.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FlightResultsProviderRef
    on AutoDisposeFutureProviderRef<domain.FlightResultsState> {
  /// The parameter `departureCity` of this provider.
  String get departureCity;

  /// The parameter `arrivalCity` of this provider.
  String get arrivalCity;

  /// The parameter `date` of this provider.
  String get date;

  /// The parameter `flightNumber` of this provider.
  String? get flightNumber;
}

class _FlightResultsProviderProviderElement
    extends AutoDisposeFutureProviderElement<domain.FlightResultsState>
    with FlightResultsProviderRef {
  _FlightResultsProviderProviderElement(super.provider);

  @override
  String get departureCity =>
      (origin as FlightResultsProviderProvider).departureCity;
  @override
  String get arrivalCity =>
      (origin as FlightResultsProviderProvider).arrivalCity;
  @override
  String get date => (origin as FlightResultsProviderProvider).date;
  @override
  String? get flightNumber =>
      (origin as FlightResultsProviderProvider).flightNumber;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
