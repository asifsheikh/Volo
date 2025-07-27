// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherRemoteDataSourceHash() =>
    r'7e7923b4ef0926a8243c7dccc000b4392b20b82c';

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
