import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

part 'home_repository_impl.g.dart';

/// Repository implementation for home feature
@riverpod
class HomeRepositoryImpl extends _$HomeRepositoryImpl implements HomeRepository {
  @override
  HomeRepository build() {
    return this;
  }

  @override
  Future<String?> getUserProfilePictureUrl() async {
    final dataSource = ref.read(homeRemoteDataSourceProvider);
    return await dataSource.getUserProfilePictureUrl();
  }

  @override
  Future<bool> hasInternetConnection() async {
    final dataSource = ref.read(homeRemoteDataSourceProvider);
    return await dataSource.hasInternetConnection();
  }

  @override
  String? getUserPhoneNumber() {
    final dataSource = ref.read(homeRemoteDataSourceProvider);
    return dataSource.getUserPhoneNumber();
  }
} 