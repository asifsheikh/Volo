// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherNotifierHash() => r'f67d9509e40bd526f21ab8d4170737bff416f393';

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

/// Legacy provider for backward compatibility
///
/// Copied from [weatherNotifier].
@ProviderFor(weatherNotifier)
const weatherNotifierProvider = WeatherNotifierFamily();

/// Legacy provider for backward compatibility
///
/// Copied from [weatherNotifier].
class WeatherNotifierFamily
    extends Family<AsyncValue<List<domain.WeatherState>>> {
  /// Legacy provider for backward compatibility
  ///
  /// Copied from [weatherNotifier].
  const WeatherNotifierFamily();

  /// Legacy provider for backward compatibility
  ///
  /// Copied from [weatherNotifier].
  WeatherNotifierProvider call(List<String> iataCodes) {
    return WeatherNotifierProvider(iataCodes);
  }

  @override
  WeatherNotifierProvider getProviderOverride(
    covariant WeatherNotifierProvider provider,
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
  String? get name => r'weatherNotifierProvider';
}

/// Legacy provider for backward compatibility
///
/// Copied from [weatherNotifier].
class WeatherNotifierProvider
    extends AutoDisposeFutureProvider<List<domain.WeatherState>> {
  /// Legacy provider for backward compatibility
  ///
  /// Copied from [weatherNotifier].
  WeatherNotifierProvider(List<String> iataCodes)
    : this._internal(
        (ref) => weatherNotifier(ref as WeatherNotifierRef, iataCodes),
        from: weatherNotifierProvider,
        name: r'weatherNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weatherNotifierHash,
        dependencies: WeatherNotifierFamily._dependencies,
        allTransitiveDependencies:
            WeatherNotifierFamily._allTransitiveDependencies,
        iataCodes: iataCodes,
      );

  WeatherNotifierProvider._internal(
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
  Override overrideWith(
    FutureOr<List<domain.WeatherState>> Function(WeatherNotifierRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeatherNotifierProvider._internal(
        (ref) => create(ref as WeatherNotifierRef),
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
  AutoDisposeFutureProviderElement<List<domain.WeatherState>> createElement() {
    return _WeatherNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeatherNotifierProvider && other.iataCodes == iataCodes;
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
mixin WeatherNotifierRef
    on AutoDisposeFutureProviderRef<List<domain.WeatherState>> {
  /// The parameter `iataCodes` of this provider.
  List<String> get iataCodes;
}

class _WeatherNotifierProviderElement
    extends AutoDisposeFutureProviderElement<List<domain.WeatherState>>
    with WeatherNotifierRef {
  _WeatherNotifierProviderElement(super.provider);

  @override
  List<String> get iataCodes => (origin as WeatherNotifierProvider).iataCodes;
}

String _$globalWeatherNotifierHash() =>
    r'f55085e91ea64d01d5d8287b2ee811be193f2a83';

/// Global weather provider that manages all weather data
///
/// Copied from [GlobalWeatherNotifier].
@ProviderFor(GlobalWeatherNotifier)
final globalWeatherNotifierProvider =
    AutoDisposeNotifierProvider<
      GlobalWeatherNotifier,
      Map<String, domain.WeatherState>
    >.internal(
      GlobalWeatherNotifier.new,
      name: r'globalWeatherNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$globalWeatherNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GlobalWeatherNotifier =
    AutoDisposeNotifier<Map<String, domain.WeatherState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
