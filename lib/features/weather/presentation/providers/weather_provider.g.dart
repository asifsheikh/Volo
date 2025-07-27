// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherNotifierHash() => r'5a42f0ee3a1abb6473e206fc5248dcfed5e07151';

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

abstract class _$WeatherNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<domain.WeatherState>> {
  late final List<String> iataCodes;

  FutureOr<List<domain.WeatherState>> build(List<String> iataCodes);
}

/// Provider for weather state management
///
/// Copied from [WeatherNotifier].
@ProviderFor(WeatherNotifier)
const weatherNotifierProvider = WeatherNotifierFamily();

/// Provider for weather state management
///
/// Copied from [WeatherNotifier].
class WeatherNotifierFamily
    extends Family<AsyncValue<List<domain.WeatherState>>> {
  /// Provider for weather state management
  ///
  /// Copied from [WeatherNotifier].
  const WeatherNotifierFamily();

  /// Provider for weather state management
  ///
  /// Copied from [WeatherNotifier].
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

/// Provider for weather state management
///
/// Copied from [WeatherNotifier].
class WeatherNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          WeatherNotifier,
          List<domain.WeatherState>
        > {
  /// Provider for weather state management
  ///
  /// Copied from [WeatherNotifier].
  WeatherNotifierProvider(List<String> iataCodes)
    : this._internal(
        () => WeatherNotifier()..iataCodes = iataCodes,
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
  FutureOr<List<domain.WeatherState>> runNotifierBuild(
    covariant WeatherNotifier notifier,
  ) {
    return notifier.build(iataCodes);
  }

  @override
  Override overrideWith(WeatherNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: WeatherNotifierProvider._internal(
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
    WeatherNotifier,
    List<domain.WeatherState>
  >
  createElement() {
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
    on AutoDisposeAsyncNotifierProviderRef<List<domain.WeatherState>> {
  /// The parameter `iataCodes` of this provider.
  List<String> get iataCodes;
}

class _WeatherNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          WeatherNotifier,
          List<domain.WeatherState>
        >
    with WeatherNotifierRef {
  _WeatherNotifierProviderElement(super.provider);

  @override
  List<String> get iataCodes => (origin as WeatherNotifierProvider).iataCodes;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
