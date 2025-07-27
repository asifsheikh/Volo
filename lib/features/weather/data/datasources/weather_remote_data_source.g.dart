// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherRemoteDataSourceHash() =>
    r'b313fd01edfca3f6551042f2d5aa6c10cf0af5ce';

/// Remote data source for weather API
///
/// Copied from [WeatherRemoteDataSource].
@ProviderFor(WeatherRemoteDataSource)
final weatherRemoteDataSourceProvider =
    AutoDisposeAsyncNotifierProvider<
      WeatherRemoteDataSource,
      List<domain.WeatherState>
    >.internal(
      WeatherRemoteDataSource.new,
      name: r'weatherRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weatherRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WeatherRemoteDataSource =
    AutoDisposeAsyncNotifier<List<domain.WeatherState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
