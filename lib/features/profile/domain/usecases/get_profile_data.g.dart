// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_profile_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getProfileDataHash() => r'd1cc6021b1977ab68c2a0f37b5d6f425185c64f4';

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

abstract class _$GetProfileData
    extends BuildlessAutoDisposeAsyncNotifier<domain.ProfileState> {
  late final String username;
  late final String phoneNumber;

  FutureOr<domain.ProfileState> build(String username, String phoneNumber);
}

/// Use case for getting profile data
///
/// Copied from [GetProfileData].
@ProviderFor(GetProfileData)
const getProfileDataProvider = GetProfileDataFamily();

/// Use case for getting profile data
///
/// Copied from [GetProfileData].
class GetProfileDataFamily extends Family<AsyncValue<domain.ProfileState>> {
  /// Use case for getting profile data
  ///
  /// Copied from [GetProfileData].
  const GetProfileDataFamily();

  /// Use case for getting profile data
  ///
  /// Copied from [GetProfileData].
  GetProfileDataProvider call(String username, String phoneNumber) {
    return GetProfileDataProvider(username, phoneNumber);
  }

  @override
  GetProfileDataProvider getProviderOverride(
    covariant GetProfileDataProvider provider,
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
  String? get name => r'getProfileDataProvider';
}

/// Use case for getting profile data
///
/// Copied from [GetProfileData].
class GetProfileDataProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GetProfileData,
          domain.ProfileState
        > {
  /// Use case for getting profile data
  ///
  /// Copied from [GetProfileData].
  GetProfileDataProvider(String username, String phoneNumber)
    : this._internal(
        () => GetProfileData()
          ..username = username
          ..phoneNumber = phoneNumber,
        from: getProfileDataProvider,
        name: r'getProfileDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getProfileDataHash,
        dependencies: GetProfileDataFamily._dependencies,
        allTransitiveDependencies:
            GetProfileDataFamily._allTransitiveDependencies,
        username: username,
        phoneNumber: phoneNumber,
      );

  GetProfileDataProvider._internal(
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
  FutureOr<domain.ProfileState> runNotifierBuild(
    covariant GetProfileData notifier,
  ) {
    return notifier.build(username, phoneNumber);
  }

  @override
  Override overrideWith(GetProfileData Function() create) {
    return ProviderOverride(
      origin: this,
      override: GetProfileDataProvider._internal(
        () => create()
          ..username = username
          ..phoneNumber = phoneNumber,
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
  AutoDisposeAsyncNotifierProviderElement<GetProfileData, domain.ProfileState>
  createElement() {
    return _GetProfileDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetProfileDataProvider &&
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
mixin GetProfileDataRef
    on AutoDisposeAsyncNotifierProviderRef<domain.ProfileState> {
  /// The parameter `username` of this provider.
  String get username;

  /// The parameter `phoneNumber` of this provider.
  String get phoneNumber;
}

class _GetProfileDataProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GetProfileData,
          domain.ProfileState
        >
    with GetProfileDataRef {
  _GetProfileDataProviderElement(super.provider);

  @override
  String get username => (origin as GetProfileDataProvider).username;
  @override
  String get phoneNumber => (origin as GetProfileDataProvider).phoneNumber;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
