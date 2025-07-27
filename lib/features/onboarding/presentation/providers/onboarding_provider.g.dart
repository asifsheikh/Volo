// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingProviderHash() =>
    r'8590e8867caa635e907627f5fcffbc46268dd1ed';

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

/// Provider for onboarding state management
///
/// Copied from [onboardingProvider].
@ProviderFor(onboardingProvider)
const onboardingProviderProvider = OnboardingProviderFamily();

/// Provider for onboarding state management
///
/// Copied from [onboardingProvider].
class OnboardingProviderFamily
    extends Family<AsyncValue<domain.OnboardingState>> {
  /// Provider for onboarding state management
  ///
  /// Copied from [onboardingProvider].
  const OnboardingProviderFamily();

  /// Provider for onboarding state management
  ///
  /// Copied from [onboardingProvider].
  OnboardingProviderProvider call(String phoneNumber) {
    return OnboardingProviderProvider(phoneNumber);
  }

  @override
  OnboardingProviderProvider getProviderOverride(
    covariant OnboardingProviderProvider provider,
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
  String? get name => r'onboardingProviderProvider';
}

/// Provider for onboarding state management
///
/// Copied from [onboardingProvider].
class OnboardingProviderProvider
    extends AutoDisposeFutureProvider<domain.OnboardingState> {
  /// Provider for onboarding state management
  ///
  /// Copied from [onboardingProvider].
  OnboardingProviderProvider(String phoneNumber)
    : this._internal(
        (ref) => onboardingProvider(ref as OnboardingProviderRef, phoneNumber),
        from: onboardingProviderProvider,
        name: r'onboardingProviderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$onboardingProviderHash,
        dependencies: OnboardingProviderFamily._dependencies,
        allTransitiveDependencies:
            OnboardingProviderFamily._allTransitiveDependencies,
        phoneNumber: phoneNumber,
      );

  OnboardingProviderProvider._internal(
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
  Override overrideWith(
    FutureOr<domain.OnboardingState> Function(OnboardingProviderRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OnboardingProviderProvider._internal(
        (ref) => create(ref as OnboardingProviderRef),
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
  AutoDisposeFutureProviderElement<domain.OnboardingState> createElement() {
    return _OnboardingProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OnboardingProviderProvider &&
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
mixin OnboardingProviderRef
    on AutoDisposeFutureProviderRef<domain.OnboardingState> {
  /// The parameter `phoneNumber` of this provider.
  String get phoneNumber;
}

class _OnboardingProviderProviderElement
    extends AutoDisposeFutureProviderElement<domain.OnboardingState>
    with OnboardingProviderRef {
  _OnboardingProviderProviderElement(super.provider);

  @override
  String get phoneNumber => (origin as OnboardingProviderProvider).phoneNumber;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
