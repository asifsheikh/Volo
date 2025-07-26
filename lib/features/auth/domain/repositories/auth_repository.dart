import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  });
  
  Future<Either<Failure, void>> sendOTP({
    required String phoneNumber,
  });
  
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  Future<Either<Failure, void>> signOut();
  
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String displayName,
    String? photoURL,
  });
  
  Stream<UserEntity?> get authStateChanges;
} 