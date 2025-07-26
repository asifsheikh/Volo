import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

part 'sign_in_with_phone.g.dart';

class SignInWithPhoneParams extends Equatable {
  final String phoneNumber;
  final String verificationId;
  final String smsCode;

  const SignInWithPhoneParams({
    required this.phoneNumber,
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [phoneNumber, verificationId, smsCode];
}

class SignInWithPhone implements UseCase<UserEntity, SignInWithPhoneParams> {
  final AuthRepository repository;

  SignInWithPhone(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithPhoneParams params) async {
    return await repository.signInWithPhone(
      phoneNumber: params.phoneNumber,
      verificationId: params.verificationId,
      smsCode: params.smsCode,
    );
  }
}

// Riverpod provider for the use case
@riverpod
SignInWithPhone signInWithPhone(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithPhone(repository);
} 