// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_select_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flightSelectProviderHash() =>
    r'dc23267667eef217d4516d181c56d45be07264fc';

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

/// Provider for flight select state management
///
/// Copied from [flightSelectProvider].
@ProviderFor(flightSelectProvider)
const flightSelectProviderProvider = FlightSelectProviderFamily();

/// Provider for flight select state management
///
/// Copied from [flightSelectProvider].
class FlightSelectProviderFamily
    extends Family<AsyncValue<domain.FlightSelectState>> {
  /// Provider for flight select state management
  ///
  /// Copied from [flightSelectProvider].
  const FlightSelectProviderFamily();

  /// Provider for flight select state management
  ///
  /// Copied from [flightSelectProvider].
  FlightSelectProviderProvider call({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) {
    return FlightSelectProviderProvider(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  @override
  FlightSelectProviderProvider getProviderOverride(
    covariant FlightSelectProviderProvider provider,
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
  String? get name => r'flightSelectProviderProvider';
}

/// Provider for flight select state management
///
/// Copied from [flightSelectProvider].
class FlightSelectProviderProvider
    extends AutoDisposeFutureProvider<domain.FlightSelectState> {
  /// Provider for flight select state management
  ///
  /// Copied from [flightSelectProvider].
  FlightSelectProviderProvider({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) : this._internal(
         (ref) => flightSelectProvider(
           ref as FlightSelectProviderRef,
           departureCity: departureCity,
           arrivalCity: arrivalCity,
           date: date,
           flightNumber: flightNumber,
         ),
         from: flightSelectProviderProvider,
         name: r'flightSelectProviderProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$flightSelectProviderHash,
         dependencies: FlightSelectProviderFamily._dependencies,
         allTransitiveDependencies:
             FlightSelectProviderFamily._allTransitiveDependencies,
         departureCity: departureCity,
         arrivalCity: arrivalCity,
         date: date,
         flightNumber: flightNumber,
       );

  FlightSelectProviderProvider._internal(
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
    FutureOr<domain.FlightSelectState> Function(
      FlightSelectProviderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FlightSelectProviderProvider._internal(
        (ref) => create(ref as FlightSelectProviderRef),
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
  AutoDisposeFutureProviderElement<domain.FlightSelectState> createElement() {
    return _FlightSelectProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FlightSelectProviderProvider &&
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
mixin FlightSelectProviderRef
    on AutoDisposeFutureProviderRef<domain.FlightSelectState> {
  /// The parameter `departureCity` of this provider.
  String get departureCity;

  /// The parameter `arrivalCity` of this provider.
  String get arrivalCity;

  /// The parameter `date` of this provider.
  String get date;

  /// The parameter `flightNumber` of this provider.
  String? get flightNumber;
}

class _FlightSelectProviderProviderElement
    extends AutoDisposeFutureProviderElement<domain.FlightSelectState>
    with FlightSelectProviderRef {
  _FlightSelectProviderProviderElement(super.provider);

  @override
  String get departureCity =>
      (origin as FlightSelectProviderProvider).departureCity;
  @override
  String get arrivalCity =>
      (origin as FlightSelectProviderProvider).arrivalCity;
  @override
  String get date => (origin as FlightSelectProviderProvider).date;
  @override
  String? get flightNumber =>
      (origin as FlightSelectProviderProvider).flightNumber;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
