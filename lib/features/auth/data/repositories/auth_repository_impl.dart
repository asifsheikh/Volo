import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, UserEntity>> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signInWithPhone(
          phoneNumber: phoneNumber,
          verificationId: verificationId,
          smsCode: smsCode,
        );
        return Right(user);
      } catch (e) {
        return Left(AuthFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> sendOTP({
    required String phoneNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendOTP(phoneNumber: phoneNumber);
        return const Right(null);
      } catch (e) {
        return Left(AuthFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getCurrentUser();
        return Right(user);
      } catch (e) {
        return Left(AuthFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.signOut();
        return const Right(null);
      } catch (e) {
        return Left(AuthFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String displayName,
    String? photoURL,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.updateUserProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
        return Right(user);
      } catch (e) {
        return Left(AuthFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }
}

// Riverpod provider for the repository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AuthRepositoryImpl(remoteDataSource, networkInfo);
} 