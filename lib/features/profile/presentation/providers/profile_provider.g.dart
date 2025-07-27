// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileProviderHash() => r'beebb863460763a8e5dd13e83a78909a60b983e1';

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

/// Provider for profile state management
///
/// Copied from [profileProvider].
@ProviderFor(profileProvider)
const profileProviderProvider = ProfileProviderFamily();

/// Provider for profile state management
///
/// Copied from [profileProvider].
class ProfileProviderFamily extends Family<AsyncValue<domain.ProfileState>> {
  /// Provider for profile state management
  ///
  /// Copied from [profileProvider].
  const ProfileProviderFamily();

  /// Provider for profile state management
  ///
  /// Copied from [profileProvider].
  ProfileProviderProvider call(String username, String phoneNumber) {
    return ProfileProviderProvider(username, phoneNumber);
  }

  @override
  ProfileProviderProvider getProviderOverride(
    covariant ProfileProviderProvider provider,
  ) {
    return call(provider.username, provider.phoneNumber);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileProviderProvider';
}

/// Provider for profile state management
///
/// Copied from [profileProvider].
class ProfileProviderProvider
    extends AutoDisposeFutureProvider<domain.ProfileState> {
  /// Provider for profile state management
  ///
  /// Copied from [profileProvider].
  ProfileProviderProvider(String username, String phoneNumber)
    : this._internal(
        (ref) =>
            profileProvider(ref as ProfileProviderRef, username, phoneNumber),
        from: profileProviderProvider,
        name: r'profileProviderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileProviderHash,
        dependencies: ProfileProviderFamily._dependencies,
        allTransitiveDependencies:
            ProfileProviderFamily._allTransitiveDependencies,
        username: username,
        phoneNumber: phoneNumber,
      );

  ProfileProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.username,
    required this.phoneNumber,
  }) : super.internal();

  final String username;
  final String phoneNumber;

  @override
  Override overrideWith(
    FutureOr<domain.ProfileState> Function(ProfileProviderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileProviderProvider._internal(
        (ref) => create(ref as ProfileProviderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        username: username,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<domain.ProfileState> createElement() {
    return _ProfileProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileProviderProvider &&
        other.username == username &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);
    hash = _SystemHash.combine(hash, phoneNumber.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileProviderRef on AutoDisposeFutureProviderRef<domain.ProfileState> {
  /// The parameter `username` of this provider.
  String get username;

  /// The parameter `phoneNumber` of this provider.
  String get phoneNumber;
}

class _ProfileProviderProviderElement
    extends AutoDisposeFutureProviderElement<domain.ProfileState>
    with ProfileProviderRef {
  _ProfileProviderProviderElement(super.provider);

  @override
  String get username => (origin as ProfileProviderProvider).username;
  @override
  String get phoneNumber => (origin as ProfileProviderProvider).phoneNumber;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
