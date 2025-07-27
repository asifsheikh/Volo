// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_flight_results.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getFlightResultsHash() => r'a258192bae71c8d23e857f0254c43954581aef9f';

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

abstract class _$GetFlightResults
    extends BuildlessAutoDisposeAsyncNotifier<domain.FlightResultsState> {
  late final String departureCity;
  late final String arrivalCity;
  late final String date;
  late final String? flightNumber;

  FutureOr<domain.FlightResultsState> build({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  });
}

/// Use case for getting flight results
///
/// Copied from [GetFlightResults].
@ProviderFor(GetFlightResults)
const getFlightResultsProvider = GetFlightResultsFamily();

/// Use case for getting flight results
///
/// Copied from [GetFlightResults].
class GetFlightResultsFamily
    extends Family<AsyncValue<domain.FlightResultsState>> {
  /// Use case for getting flight results
  ///
  /// Copied from [GetFlightResults].
  const GetFlightResultsFamily();

  /// Use case for getting flight results
  ///
  /// Copied from [GetFlightResults].
  GetFlightResultsProvider call({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) {
    return GetFlightResultsProvider(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  @override
  GetFlightResultsProvider getProviderOverride(
    covariant GetFlightResultsProvider provider,
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
  String? get name => r'getFlightResultsProvider';
}

/// Use case for getting flight results
///
/// Copied from [GetFlightResults].
class GetFlightResultsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GetFlightResults,
          domain.FlightResultsState
        > {
  /// Use case for getting flight results
  ///
  /// Copied from [GetFlightResults].
  GetFlightResultsProvider({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) : this._internal(
         () => GetFlightResults()
           ..departureCity = departureCity
           ..arrivalCity = arrivalCity
           ..date = date
           ..flightNumber = flightNumber,
         from: getFlightResultsProvider,
         name: r'getFlightResultsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$getFlightResultsHash,
         dependencies: GetFlightResultsFamily._dependencies,
         allTransitiveDependencies:
             GetFlightResultsFamily._allTransitiveDependencies,
         departureCity: departureCity,
         arrivalCity: arrivalCity,
         date: date,
         flightNumber: flightNumber,
       );

  GetFlightResultsProvider._internal(
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
  FutureOr<domain.FlightResultsState> runNotifierBuild(
    covariant GetFlightResults notifier,
  ) {
    return notifier.build(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  @override
  Override overrideWith(GetFlightResults Function() create) {
    return ProviderOverride(
      origin: this,
      override: GetFlightResultsProvider._internal(
        () => create()
          ..departureCity = departureCity
          ..arrivalCity = arrivalCity
          ..date = date
          ..flightNumber = flightNumber,
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
  AutoDisposeAsyncNotifierProviderElement<
    GetFlightResults,
    domain.FlightResultsState
  >
  createElement() {
    return _GetFlightResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFlightResultsProvider &&
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
mixin GetFlightResultsRef
    on AutoDisposeAsyncNotifierProviderRef<domain.FlightResultsState> {
  /// The parameter `departureCity` of this provider.
  String get departureCity;

  /// The parameter `arrivalCity` of this provider.
  String get arrivalCity;

  /// The parameter `date` of this provider.
  String get date;

  /// The parameter `flightNumber` of this provider.
  String? get flightNumber;
}

class _GetFlightResultsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GetFlightResults,
          domain.FlightResultsState
        >
    with GetFlightResultsRef {
  _GetFlightResultsProviderElement(super.provider);

  @override
  String get departureCity =>
      (origin as GetFlightResultsProvider).departureCity;
  @override
  String get arrivalCity => (origin as GetFlightResultsProvider).arrivalCity;
  @override
  String get date => (origin as GetFlightResultsProvider).date;
  @override
  String? get flightNumber => (origin as GetFlightResultsProvider).flightNumber;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
