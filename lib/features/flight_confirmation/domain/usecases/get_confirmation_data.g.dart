// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_confirmation_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getConfirmationDataHash() =>
    r'0a7e677e649cad0b3030024cff154010eeb0e25a';

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

abstract class _$GetConfirmationData
    extends BuildlessAutoDisposeAsyncNotifier<domain.FlightConfirmationState> {
  late final ConfirmationArgs args;

  FutureOr<domain.FlightConfirmationState> build(ConfirmationArgs args);
}

/// Use case for getting confirmation data
///
/// Copied from [GetConfirmationData].
@ProviderFor(GetConfirmationData)
const getConfirmationDataProvider = GetConfirmationDataFamily();

/// Use case for getting confirmation data
///
/// Copied from [GetConfirmationData].
class GetConfirmationDataFamily
    extends Family<AsyncValue<domain.FlightConfirmationState>> {
  /// Use case for getting confirmation data
  ///
  /// Copied from [GetConfirmationData].
  const GetConfirmationDataFamily();

  /// Use case for getting confirmation data
  ///
  /// Copied from [GetConfirmationData].
  GetConfirmationDataProvider call(ConfirmationArgs args) {
    return GetConfirmationDataProvider(args);
  }

  @override
  GetConfirmationDataProvider getProviderOverride(
    covariant GetConfirmationDataProvider provider,
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
  String? get name => r'getConfirmationDataProvider';
}

/// Use case for getting confirmation data
///
/// Copied from [GetConfirmationData].
class GetConfirmationDataProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GetConfirmationData,
          domain.FlightConfirmationState
        > {
  /// Use case for getting confirmation data
  ///
  /// Copied from [GetConfirmationData].
  GetConfirmationDataProvider(ConfirmationArgs args)
    : this._internal(
        () => GetConfirmationData()..args = args,
        from: getConfirmationDataProvider,
        name: r'getConfirmationDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getConfirmationDataHash,
        dependencies: GetConfirmationDataFamily._dependencies,
        allTransitiveDependencies:
            GetConfirmationDataFamily._allTransitiveDependencies,
        args: args,
      );

  GetConfirmationDataProvider._internal(
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
  FutureOr<domain.FlightConfirmationState> runNotifierBuild(
    covariant GetConfirmationData notifier,
  ) {
    return notifier.build(args);
  }

  @override
  Override overrideWith(GetConfirmationData Function() create) {
    return ProviderOverride(
      origin: this,
      override: GetConfirmationDataProvider._internal(
        () => create()..args = args,
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
  AutoDisposeAsyncNotifierProviderElement<
    GetConfirmationData,
    domain.FlightConfirmationState
  >
  createElement() {
    return _GetConfirmationDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetConfirmationDataProvider && other.args == args;
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
mixin GetConfirmationDataRef
    on AutoDisposeAsyncNotifierProviderRef<domain.FlightConfirmationState> {
  /// The parameter `args` of this provider.
  ConfirmationArgs get args;
}

class _GetConfirmationDataProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GetConfirmationData,
          domain.FlightConfirmationState
        >
    with GetConfirmationDataRef {
  _GetConfirmationDataProviderElement(super.provider);

  @override
  ConfirmationArgs get args => (origin as GetConfirmationDataProvider).args;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
