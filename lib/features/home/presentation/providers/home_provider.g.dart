// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeProviderHash() => r'05315ecf72348b8e2533a1948ab1a751bc47a6e4';

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

/// Provider for home screen state management
///
/// Copied from [homeProvider].
@ProviderFor(homeProvider)
const homeProviderProvider = HomeProviderFamily();

/// Provider for home screen state management
///
/// Copied from [homeProvider].
class HomeProviderFamily extends Family<AsyncValue<HomeState>> {
  /// Provider for home screen state management
  ///
  /// Copied from [homeProvider].
  const HomeProviderFamily();

  /// Provider for home screen state management
  ///
  /// Copied from [homeProvider].
  HomeProviderProvider call(String username) {
    return HomeProviderProvider(username);
  }

  @override
  HomeProviderProvider getProviderOverride(
    covariant HomeProviderProvider provider,
  ) {
    return call(provider.username);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'homeProviderProvider';
}

/// Provider for home screen state management
///
/// Copied from [homeProvider].
class HomeProviderProvider extends AutoDisposeFutureProvider<HomeState> {
  /// Provider for home screen state management
  ///
  /// Copied from [homeProvider].
  HomeProviderProvider(String username)
    : this._internal(
        (ref) => homeProvider(ref as HomeProviderRef, username),
        from: homeProviderProvider,
        name: r'homeProviderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$homeProviderHash,
        dependencies: HomeProviderFamily._dependencies,
        allTransitiveDependencies:
            HomeProviderFamily._allTransitiveDependencies,
        username: username,
      );

  HomeProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.username,
  }) : super.internal();

  final String username;

  @override
  Override overrideWith(
    FutureOr<HomeState> Function(HomeProviderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HomeProviderProvider._internal(
        (ref) => create(ref as HomeProviderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        username: username,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<HomeState> createElement() {
    return _HomeProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeProviderProvider && other.username == username;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HomeProviderRef on AutoDisposeFutureProviderRef<HomeState> {
  /// The parameter `username` of this provider.
  String get username;
}

class _HomeProviderProviderElement
    extends AutoDisposeFutureProviderElement<HomeState>
    with HomeProviderRef {
  _HomeProviderProviderElement(super.provider);

  @override
  String get username => (origin as HomeProviderProvider).username;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
