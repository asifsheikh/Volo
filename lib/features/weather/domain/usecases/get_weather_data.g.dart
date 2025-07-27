// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_weather_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getWeatherDataHash() => r'89fe682dd5b43a3f040f27a5486ba851b68b86dd';

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

abstract class _$GetWeatherData
    extends BuildlessAutoDisposeAsyncNotifier<List<domain.WeatherState>> {
  late final List<String> iataCodes;

  FutureOr<List<domain.WeatherState>> build(List<String> iataCodes);
}

/// Use case for getting weather data
///
/// Copied from [GetWeatherData].
@ProviderFor(GetWeatherData)
const getWeatherDataProvider = GetWeatherDataFamily();

/// Use case for getting weather data
///
/// Copied from [GetWeatherData].
class GetWeatherDataFamily
    extends Family<AsyncValue<List<domain.WeatherState>>> {
  /// Use case for getting weather data
  ///
  /// Copied from [GetWeatherData].
  const GetWeatherDataFamily();

  /// Use case for getting weather data
  ///
  /// Copied from [GetWeatherData].
  GetWeatherDataProvider call(List<String> iataCodes) {
    return GetWeatherDataProvider(iataCodes);
  }

  @override
  GetWeatherDataProvider getProviderOverride(
    covariant GetWeatherDataProvider provider,
  ) {
    return call(provider.iataCodes);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getWeatherDataProvider';
}

/// Use case for getting weather data
///
/// Copied from [GetWeatherData].
class GetWeatherDataProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GetWeatherData,
          List<domain.WeatherState>
        > {
  /// Use case for getting weather data
  ///
  /// Copied from [GetWeatherData].
  GetWeatherDataProvider(List<String> iataCodes)
    : this._internal(
        () => GetWeatherData()..iataCodes = iataCodes,
        from: getWeatherDataProvider,
        name: r'getWeatherDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getWeatherDataHash,
        dependencies: GetWeatherDataFamily._dependencies,
        allTransitiveDependencies:
            GetWeatherDataFamily._allTransitiveDependencies,
        iataCodes: iataCodes,
      );

  GetWeatherDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.iataCodes,
  }) : super.internal();

  final List<String> iataCodes;

  @override
  FutureOr<List<domain.WeatherState>> runNotifierBuild(
    covariant GetWeatherData notifier,
  ) {
    return notifier.build(iataCodes);
  }

  @override
  Override overrideWith(GetWeatherData Function() create) {
    return ProviderOverride(
      origin: this,
      override: GetWeatherDataProvider._internal(
        () => create()..iataCodes = iataCodes,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        iataCodes: iataCodes,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    GetWeatherData,
    List<domain.WeatherState>
  >
  createElement() {
    return _GetWeatherDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetWeatherDataProvider && other.iataCodes == iataCodes;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, iataCodes.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetWeatherDataRef
    on AutoDisposeAsyncNotifierProviderRef<List<domain.WeatherState>> {
  /// The parameter `iataCodes` of this provider.
  List<String> get iataCodes;
}

class _GetWeatherDataProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GetWeatherData,
          List<domain.WeatherState>
        >
    with GetWeatherDataRef {
  _GetWeatherDataProviderElement(super.provider);

  @override
  List<String> get iataCodes => (origin as GetWeatherDataProvider).iataCodes;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
