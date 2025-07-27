// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_home_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loadHomeDataHash() => r'5775e07db43147945d6b743d0931dc3a26dd4017';

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

abstract class _$LoadHomeData
    extends BuildlessAutoDisposeAsyncNotifier<HomeState> {
  late final String username;

  FutureOr<HomeState> build(String username);
}

/// Use case for loading home screen data
///
/// Copied from [LoadHomeData].
@ProviderFor(LoadHomeData)
const loadHomeDataProvider = LoadHomeDataFamily();

/// Use case for loading home screen data
///
/// Copied from [LoadHomeData].
class LoadHomeDataFamily extends Family<AsyncValue<HomeState>> {
  /// Use case for loading home screen data
  ///
  /// Copied from [LoadHomeData].
  const LoadHomeDataFamily();

  /// Use case for loading home screen data
  ///
  /// Copied from [LoadHomeData].
  LoadHomeDataProvider call(String username) {
    return LoadHomeDataProvider(username);
  }

  @override
  LoadHomeDataProvider getProviderOverride(
    covariant LoadHomeDataProvider provider,
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
  String? get name => r'loadHomeDataProvider';
}

/// Use case for loading home screen data
///
/// Copied from [LoadHomeData].
class LoadHomeDataProvider
    extends AutoDisposeAsyncNotifierProviderImpl<LoadHomeData, HomeState> {
  /// Use case for loading home screen data
  ///
  /// Copied from [LoadHomeData].
  LoadHomeDataProvider(String username)
    : this._internal(
        () => LoadHomeData()..username = username,
        from: loadHomeDataProvider,
        name: r'loadHomeDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$loadHomeDataHash,
        dependencies: LoadHomeDataFamily._dependencies,
        allTransitiveDependencies:
            LoadHomeDataFamily._allTransitiveDependencies,
        username: username,
      );

  LoadHomeDataProvider._internal(
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
  FutureOr<HomeState> runNotifierBuild(covariant LoadHomeData notifier) {
    return notifier.build(username);
  }

  @override
  Override overrideWith(LoadHomeData Function() create) {
    return ProviderOverride(
      origin: this,
      override: LoadHomeDataProvider._internal(
        () => create()..username = username,
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
  AutoDisposeAsyncNotifierProviderElement<LoadHomeData, HomeState>
  createElement() {
    return _LoadHomeDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoadHomeDataProvider && other.username == username;
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
mixin LoadHomeDataRef on AutoDisposeAsyncNotifierProviderRef<HomeState> {
  /// The parameter `username` of this provider.
  String get username;
}

class _LoadHomeDataProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LoadHomeData, HomeState>
    with LoadHomeDataRef {
  _LoadHomeDataProviderElement(super.provider);

  @override
  String get username => (origin as LoadHomeDataProvider).username;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
