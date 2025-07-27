// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeState {
  String get username => throw _privateConstructorUsedError;
  String? get profilePictureUrl => throw _privateConstructorUsedError;
  bool get isLoadingProfile => throw _privateConstructorUsedError;
  bool get isOffline => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call({
    String username,
    String? profilePictureUrl,
    bool isLoadingProfile,
    bool isOffline,
    String? errorMessage,
  });
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? profilePictureUrl = freezed,
    Object? isLoadingProfile = null,
    Object? isOffline = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            profilePictureUrl: freezed == profilePictureUrl
                ? _value.profilePictureUrl
                : profilePictureUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLoadingProfile: null == isLoadingProfile
                ? _value.isLoadingProfile
                : isLoadingProfile // ignore: cast_nullable_to_non_nullable
                      as bool,
            isOffline: null == isOffline
                ? _value.isOffline
                : isOffline // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
    _$HomeStateImpl value,
    $Res Function(_$HomeStateImpl) then,
  ) = __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String username,
    String? profilePictureUrl,
    bool isLoadingProfile,
    bool isOffline,
    String? errorMessage,
  });
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
    _$HomeStateImpl _value,
    $Res Function(_$HomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? profilePictureUrl = freezed,
    Object? isLoadingProfile = null,
    Object? isOffline = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$HomeStateImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        profilePictureUrl: freezed == profilePictureUrl
            ? _value.profilePictureUrl
            : profilePictureUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLoadingProfile: null == isLoadingProfile
            ? _value.isLoadingProfile
            : isLoadingProfile // ignore: cast_nullable_to_non_nullable
                  as bool,
        isOffline: null == isOffline
            ? _value.isOffline
            : isOffline // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl({
    this.username = '',
    this.profilePictureUrl = '',
    this.isLoadingProfile = true,
    this.isOffline = false,
    this.errorMessage = '',
  });

  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String? profilePictureUrl;
  @override
  @JsonKey()
  final bool isLoadingProfile;
  @override
  @JsonKey()
  final bool isOffline;
  @override
  @JsonKey()
  final String? errorMessage;

  @override
  String toString() {
    return 'HomeState(username: $username, profilePictureUrl: $profilePictureUrl, isLoadingProfile: $isLoadingProfile, isOffline: $isOffline, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profilePictureUrl, profilePictureUrl) ||
                other.profilePictureUrl == profilePictureUrl) &&
            (identical(other.isLoadingProfile, isLoadingProfile) ||
                other.isLoadingProfile == isLoadingProfile) &&
            (identical(other.isOffline, isOffline) ||
                other.isOffline == isOffline) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    username,
    profilePictureUrl,
    isLoadingProfile,
    isOffline,
    errorMessage,
  );

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState({
    final String username,
    final String? profilePictureUrl,
    final bool isLoadingProfile,
    final bool isOffline,
    final String? errorMessage,
  }) = _$HomeStateImpl;

  @override
  String get username;
  @override
  String? get profilePictureUrl;
  @override
  bool get isLoadingProfile;
  @override
  bool get isOffline;
  @override
  String? get errorMessage;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
