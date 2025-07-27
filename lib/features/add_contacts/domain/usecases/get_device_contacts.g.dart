// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_device_contacts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getDeviceContactsHash() => r'3d2adc6beeb7dd329350c5b7189652408d2d7f82';

/// Use case for getting device contacts
///
/// Copied from [GetDeviceContacts].
@ProviderFor(GetDeviceContacts)
final getDeviceContactsProvider =
    AutoDisposeAsyncNotifierProvider<
      GetDeviceContacts,
      List<domain.Contact>
    >.internal(
      GetDeviceContacts.new,
      name: r'getDeviceContactsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getDeviceContactsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GetDeviceContacts = AutoDisposeAsyncNotifier<List<domain.Contact>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
