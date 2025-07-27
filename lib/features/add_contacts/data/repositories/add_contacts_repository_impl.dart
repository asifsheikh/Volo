import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/add_contacts_state.dart' as domain;
import '../../domain/repositories/add_contacts_repository.dart';
import '../datasources/add_contacts_local_data_source.dart';

part 'add_contacts_repository_impl.g.dart';

/// Repository implementation for add contacts
@riverpod
class AddContactsRepositoryImpl extends _$AddContactsRepositoryImpl implements AddContactsRepository {
  @override
  Future<void> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  @override
  Future<List<domain.Contact>> getDeviceContacts() async {
    final dataSource = ref.read(addContactsLocalDataSourceProvider.notifier);
    return await dataSource.getDeviceContacts();
  }

  @override
  Future<bool> requestContactsPermission() async {
    final dataSource = ref.read(addContactsLocalDataSourceProvider.notifier);
    return await dataSource.requestContactsPermission();
  }

  @override
  Future<void> saveTrip({
    required dynamic flightOption,
    required List<domain.Contact> contacts,
    required bool userNotifications,
    required String departureCity,
    required String arrivalCity,
  }) async {
    final dataSource = ref.read(addContactsLocalDataSourceProvider.notifier);
    return await dataSource.saveTrip(
      flightOption: flightOption,
      contacts: contacts,
      userNotifications: userNotifications,
      departureCity: departureCity,
      arrivalCity: arrivalCity,
    );
  }

  @override
  String? getCurrentUserId() {
    final dataSource = ref.read(addContactsLocalDataSourceProvider.notifier);
    return dataSource.getCurrentUserId();
  }
} 