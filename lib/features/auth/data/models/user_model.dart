import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.phoneNumber,
    super.displayName,
    super.email,
    super.photoURL,
    super.isEmailVerified,
    super.createdAt,
    super.lastSignInAt,
  });

  factory UserModel.fromFirebaseUser(dynamic user) {
    try {
      print('UserModel.fromFirebaseUser: Starting conversion for user: ${user.uid}');
      print('UserModel.fromFirebaseUser: creationTime type: ${user.metadata.creationTime.runtimeType}');
      print('UserModel.fromFirebaseUser: lastSignInTime type: ${user.metadata.lastSignInTime.runtimeType}');
      
      return UserModel(
        id: user.uid,
        phoneNumber: user.phoneNumber,
        displayName: user.displayName,
        email: user.email,
        photoURL: user.photoURL,
        isEmailVerified: user.emailVerified,
        createdAt: user.metadata.creationTime,
        lastSignInAt: user.metadata.lastSignInTime,
      );
    } catch (e) {
      print('UserModel.fromFirebaseUser: Error converting user: $e');
      print('UserModel.fromFirebaseUser: Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoURL: json['photoURL'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastSignInAt: json['lastSignInAt'] != null 
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? displayName,
    String? email,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserModel(
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