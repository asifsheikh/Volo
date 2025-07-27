// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_onboarding_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getOnboardingDataHash() => r'992579ea67420c8555caeb600705d52137db5197';

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

abstract class _$GetOnboardingData
    extends BuildlessAutoDisposeAsyncNotifier<domain.OnboardingState> {
  late final String phoneNumber;

  FutureOr<domain.OnboardingState> build(String phoneNumber);
}

/// Use case for getting onboarding data
///
/// Copied from [GetOnboardingData].
@ProviderFor(GetOnboardingData)
const getOnboardingDataProvider = GetOnboardingDataFamily();

/// Use case for getting onboarding data
///
/// Copied from [GetOnboardingData].
class GetOnboardingDataFamily
    extends Family<AsyncValue<domain.OnboardingState>> {
  /// Use case for getting onboarding data
  ///
  /// Copied from [GetOnboardingData].
  const GetOnboardingDataFamily();

  /// Use case for getting onboarding data
  ///
  /// Copied from [GetOnboardingData].
  GetOnboardingDataProvider call(String phoneNumber) {
    return GetOnboardingDataProvider(phoneNumber);
  }

  @override
  GetOnboardingDataProvider getProviderOverride(
    covariant GetOnboardingDataProvider provider,
  ) {
    return call(provider.phoneNumber);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getOnboardingDataProvider';
}

/// Use case for getting onboarding data
///
/// Copied from [GetOnboardingData].
class GetOnboardingDataProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GetOnboardingData,
          domain.OnboardingState
        > {
  /// Use case for getting onboarding data
  ///
  /// Copied from [GetOnboardingData].
  GetOnboardingDataProvider(String phoneNumber)
    : this._internal(
        () => GetOnboardingData()..phoneNumber = phoneNumber,
        from: getOnboardingDataProvider,
        name: r'getOnboardingDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getOnboardingDataHash,
        dependencies: GetOnboardingDataFamily._dependencies,
        allTransitiveDependencies:
            GetOnboardingDataFamily._allTransitiveDependencies,
        phoneNumber: phoneNumber,
      );

  GetOnboardingDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.phoneNumber,
  }) : super.internal();

  final String phoneNumber;

  @override
  FutureOr<domain.OnboardingState> runNotifierBuild(
    covariant GetOnboardingData notifier,
  ) {
    return notifier.build(phoneNumber);
  }

  @override
  Override overrideWith(GetOnboardingData Function() create) {
    return ProviderOverride(
      origin: this,
      override: GetOnboardingDataProvider._internal(
        () => create()..phoneNumber = phoneNumber,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    GetOnboardingData,
    domain.OnboardingState
  >
  createElement() {
    return _GetOnboardingDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetOnboardingDataProvider &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, phoneNumber.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetOnboardingDataRef
    on AutoDisposeAsyncNotifierProviderRef<domain.OnboardingState> {
  /// The parameter `phoneNumber` of this provider.
  String get phoneNumber;
}

class _GetOnboardingDataProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GetOnboardingData,
          domain.OnboardingState
        >
    with GetOnboardingDataRef {
  _GetOnboardingDataProviderElement(super.provider);

  @override
  String get phoneNumber => (origin as GetOnboardingDataProvider).phoneNumber;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
