// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_flight_select_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getFlightSelectDataHash() =>
    r'f6c92734d8aa3a37db5bff9891f48019c355faad';

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

abstract class _$GetFlightSelectData
    extends BuildlessAutoDisposeAsyncNotifier<domain.FlightSelectState> {
  late final String departureCity;
  late final String arrivalCity;
  late final String date;
  late final String? flightNumber;

  FutureOr<domain.FlightSelectState> build({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  });
}

/// Use case for getting flight select data
///
/// Copied from [GetFlightSelectData].
@ProviderFor(GetFlightSelectData)
const getFlightSelectDataProvider = GetFlightSelectDataFamily();

/// Use case for getting flight select data
///
/// Copied from [GetFlightSelectData].
class GetFlightSelectDataFamily
    extends Family<AsyncValue<domain.FlightSelectState>> {
  /// Use case for getting flight select data
  ///
  /// Copied from [GetFlightSelectData].
  const GetFlightSelectDataFamily();

  /// Use case for getting flight select data
  ///
  /// Copied from [GetFlightSelectData].
  GetFlightSelectDataProvider call({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) {
    return GetFlightSelectDataProvider(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  @override
  GetFlightSelectDataProvider getProviderOverride(
    covariant GetFlightSelectDataProvider provider,
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
  String? get name => r'getFlightSelectDataProvider';
}

/// Use case for getting flight select data
///
/// Copied from [GetFlightSelectData].
class GetFlightSelectDataProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GetFlightSelectData,
          domain.FlightSelectState
        > {
  /// Use case for getting flight select data
  ///
  /// Copied from [GetFlightSelectData].
  GetFlightSelectDataProvider({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) : this._internal(
         () => GetFlightSelectData()
           ..departureCity = departureCity
           ..arrivalCity = arrivalCity
           ..date = date
           ..flightNumber = flightNumber,
         from: getFlightSelectDataProvider,
         name: r'getFlightSelectDataProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$getFlightSelectDataHash,
         dependencies: GetFlightSelectDataFamily._dependencies,
         allTransitiveDependencies:
             GetFlightSelectDataFamily._allTransitiveDependencies,
         departureCity: departureCity,
         arrivalCity: arrivalCity,
         date: date,
         flightNumber: flightNumber,
       );

  GetFlightSelectDataProvider._internal(
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
  FutureOr<domain.FlightSelectState> runNotifierBuild(
    covariant GetFlightSelectData notifier,
  ) {
    return notifier.build(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  @override
  Override overrideWith(GetFlightSelectData Function() create) {
    return ProviderOverride(
      origin: this,
      override: GetFlightSelectDataProvider._internal(
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
    GetFlightSelectData,
    domain.FlightSelectState
  >
  createElement() {
    return _GetFlightSelectDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFlightSelectDataProvider &&
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
mixin GetFlightSelectDataRef
    on AutoDisposeAsyncNotifierProviderRef<domain.FlightSelectState> {
  /// The parameter `departureCity` of this provider.
  String get departureCity;

  /// The parameter `arrivalCity` of this provider.
  String get arrivalCity;

  /// The parameter `date` of this provider.
  String get date;

  /// The parameter `flightNumber` of this provider.
  String? get flightNumber;
}

class _GetFlightSelectDataProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GetFlightSelectData,
          domain.FlightSelectState
        >
    with GetFlightSelectDataRef {
  _GetFlightSelectDataProviderElement(super.provider);

  @override
  String get departureCity =>
      (origin as GetFlightSelectDataProvider).departureCity;
  @override
  String get arrivalCity => (origin as GetFlightSelectDataProvider).arrivalCity;
  @override
  String get date => (origin as GetFlightSelectDataProvider).date;
  @override
  String? get flightNumber =>
      (origin as GetFlightSelectDataProvider).flightNumber;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
