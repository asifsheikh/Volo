import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/add_contacts_state.dart' as domain;
import '../repositories/add_contacts_repository.dart';
import '../../data/repositories/add_contacts_repository_impl.dart';

part 'get_device_contacts.g.dart';

/// Use case for getting device contacts
@riverpod
class GetDeviceContacts extends _$GetDeviceContacts {
  @override
  Future<List<domain.Contact>> build() async {
    return _getDeviceContacts();
  }

  Future<List<domain.Contact>> _getDeviceContacts() async {
    try {
      final repository = ref.read(addContactsRepositoryImplProvider.notifier);
      
      // Request permission first
      final hasPermission = await repository.requestContactsPermission();
      if (!hasPermission) {
        throw Exception('Contacts permission denied');
      }

      // Get contacts
      final contacts = await repository.getDeviceContacts();
      return contacts;
    } catch (e) {
      throw Exception('Failed to get device contacts: $e');
    }
  }

  /// Refresh contacts
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getDeviceContacts());
  }
} 