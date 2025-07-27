// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_confirmation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flightConfirmationProviderHash() =>
    r'ac5eaff59b02564a1c882fbc0d6d59421baad19b';

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

/// Provider for flight confirmation state management
///
/// Copied from [flightConfirmationProvider].
@ProviderFor(flightConfirmationProvider)
const flightConfirmationProviderProvider = FlightConfirmationProviderFamily();

/// Provider for flight confirmation state management
///
/// Copied from [flightConfirmationProvider].
class FlightConfirmationProviderFamily
    extends Family<AsyncValue<domain.FlightConfirmationState>> {
  /// Provider for flight confirmation state management
  ///
  /// Copied from [flightConfirmationProvider].
  const FlightConfirmationProviderFamily();

  /// Provider for flight confirmation state management
  ///
  /// Copied from [flightConfirmationProvider].
  FlightConfirmationProviderProvider call(ConfirmationArgs args) {
    return FlightConfirmationProviderProvider(args);
  }

  @override
  FlightConfirmationProviderProvider getProviderOverride(
    covariant FlightConfirmationProviderProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'flightConfirmationProviderProvider';
}

/// Provider for flight confirmation state management
///
/// Copied from [flightConfirmationProvider].
class FlightConfirmationProviderProvider
    extends AutoDisposeFutureProvider<domain.FlightConfirmationState> {
  /// Provider for flight confirmation state management
  ///
  /// Copied from [flightConfirmationProvider].
  FlightConfirmationProviderProvider(ConfirmationArgs args)
    : this._internal(
        (ref) => flightConfirmationProvider(
          ref as FlightConfirmationProviderRef,
          args,
        ),
        from: flightConfirmationProviderProvider,
        name: r'flightConfirmationProviderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$flightConfirmationProviderHash,
        dependencies: FlightConfirmationProviderFamily._dependencies,
        allTransitiveDependencies:
            FlightConfirmationProviderFamily._allTransitiveDependencies,
        args: args,
      );

  FlightConfirmationProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final ConfirmationArgs args;

  @override
  Override overrideWith(
    FutureOr<domain.FlightConfirmationState> Function(
      FlightConfirmationProviderRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FlightConfirmationProviderProvider._internal(
        (ref) => create(ref as FlightConfirmationProviderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<domain.FlightConfirmationState>
  createElement() {
    return _FlightConfirmationProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FlightConfirmationProviderProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FlightConfirmationProviderRef
    on AutoDisposeFutureProviderRef<domain.FlightConfirmationState> {
  /// The parameter `args` of this provider.
  ConfirmationArgs get args;
}

class _FlightConfirmationProviderProviderElement
    extends AutoDisposeFutureProviderElement<domain.FlightConfirmationState>
    with FlightConfirmationProviderRef {
  _FlightConfirmationProviderProviderElement(super.provider);

  @override
  ConfirmationArgs get args =>
      (origin as FlightConfirmationProviderProvider).args;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
