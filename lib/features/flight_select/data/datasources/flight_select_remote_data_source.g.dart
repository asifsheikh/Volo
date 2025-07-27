// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_select_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flightSelectRemoteDataSourceHash() =>
    r'66313e10bef23cae75d66ffa4badcde573380597';

/// Remote data source for flight select
///
/// Copied from [FlightSelectRemoteDataSource].
@ProviderFor(FlightSelectRemoteDataSource)
final flightSelectRemoteDataSourceProvider =
    AutoDisposeAsyncNotifierProvider<
      FlightSelectRemoteDataSource,
      domain.FlightSelectState
    >.internal(
      FlightSelectRemoteDataSource.new,
      name: r'flightSelectRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$flightSelectRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FlightSelectRemoteDataSource =
    AutoDisposeAsyncNotifier<domain.FlightSelectState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
