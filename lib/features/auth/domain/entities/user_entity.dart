import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  const UserEntity({
    required this.id,
    this.phoneNumber,
    this.displayName,
    this.email,
    this.photoURL,
    this.isEmailVerified = false,
    this.createdAt,
    this.lastSignInAt,
  });

  @override
  List<Object?> get props => [
    id,
    phoneNumber,
    displayName,
    email,
    photoURL,
    isEmailVerified,
    createdAt,
    lastSignInAt,
  ];

  UserEntity copyWith({
    String? id,
    String? phoneNumber,
    String? displayName,
    String? email,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
} 