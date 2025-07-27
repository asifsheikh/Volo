// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherProviderHash() => r'6726539f279f68b39f868994502c32cbcb846a19';

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

/// Provider for weather state management
///
/// Copied from [weatherProvider].
@ProviderFor(weatherProvider)
const weatherProviderProvider = WeatherProviderFamily();

/// Provider for weather state management
///
/// Copied from [weatherProvider].
class WeatherProviderFamily
    extends Family<AsyncValue<List<domain.WeatherState>>> {
  /// Provider for weather state management
  ///
  /// Copied from [weatherProvider].
  const WeatherProviderFamily();

  /// Provider for weather state management
  ///
  /// Copied from [weatherProvider].
  WeatherProviderProvider call(List<String> iataCodes) {
    return WeatherProviderProvider(iataCodes);
  }

  @override
  WeatherProviderProvider getProviderOverride(
    covariant WeatherProviderProvider provider,
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
  String? get name => r'weatherProviderProvider';
}

/// Provider for weather state management
///
/// Copied from [weatherProvider].
class WeatherProviderProvider
    extends AutoDisposeFutureProvider<List<domain.WeatherState>> {
  /// Provider for weather state management
  ///
  /// Copied from [weatherProvider].
  WeatherProviderProvider(List<String> iataCodes)
    : this._internal(
        (ref) => weatherProvider(ref as WeatherProviderRef, iataCodes),
        from: weatherProviderProvider,
        name: r'weatherProviderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weatherProviderHash,
        dependencies: WeatherProviderFamily._dependencies,
        allTransitiveDependencies:
            WeatherProviderFamily._allTransitiveDependencies,
        iataCodes: iataCodes,
      );

  WeatherProviderProvider._internal(
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
    FutureOr<List<domain.WeatherState>> Function(WeatherProviderRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeatherProviderProvider._internal(
        (ref) => create(ref as WeatherProviderRef),
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
    return _WeatherProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeatherProviderProvider && other.iataCodes == iataCodes;
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
mixin WeatherProviderRef
    on AutoDisposeFutureProviderRef<List<domain.WeatherState>> {
  /// The parameter `iataCodes` of this provider.
  List<String> get iataCodes;
}

class _WeatherProviderProviderElement
    extends AutoDisposeFutureProviderElement<List<domain.WeatherState>>
    with WeatherProviderRef {
  _WeatherProviderProviderElement(super.provider);

  @override
  List<String> get iataCodes => (origin as WeatherProviderProvider).iataCodes;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
