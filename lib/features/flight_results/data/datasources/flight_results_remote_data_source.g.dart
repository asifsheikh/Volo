// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_results_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flightResultsRemoteDataSourceHash() =>
    r'36fe6cffcaf521a94661bcee21febdfa0c46bd17';

/// Remote data source for flight results
///
/// Copied from [FlightResultsRemoteDataSource].
@ProviderFor(FlightResultsRemoteDataSource)
final flightResultsRemoteDataSourceProvider =
    AutoDisposeAsyncNotifierProvider<
      FlightResultsRemoteDataSource,
      domain.FlightResultsState
    >.internal(
      FlightResultsRemoteDataSource.new,
      name: r'flightResultsRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$flightResultsRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FlightResultsRemoteDataSource =
    AutoDisposeAsyncNotifier<domain.FlightResultsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
