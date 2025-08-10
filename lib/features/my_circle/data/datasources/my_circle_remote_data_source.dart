import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../models/my_circle_contact_model.dart';
import '../../domain/entities/my_circle_contact.dart';

abstract class MyCircleRemoteDataSource {
  /// Get all contacts from user's My Circle
  Future<List<MyCircleContactModel>> getMyCircleContacts();
  
  /// Add a new contact to My Circle
  Future<String> addContact(MyCircleContactForm contact);
  
  /// Update an existing contact
  Future<void> updateContact(String contactId, MyCircleContactForm contact);
  
  /// Delete a contact from My Circle
  Future<void> deleteContact(String contactId);
  

  
  /// Check if a contact exists by WhatsApp number
  Future<bool> contactExists(String whatsappNumber);
}

class MyCircleRemoteDataSourceImpl implements MyCircleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MyCircleRemoteDataSourceImpl(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _myCircleCollection {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(_userId).collection('myCircle');
  }

  @override
  Future<List<MyCircleContactModel>> getMyCircleContacts() async {
    try {
      developer.log('MyCircleRemoteDataSource: Fetching My Circle contacts', name: 'VoloMyCircle');
      
      final querySnapshot = await _myCircleCollection
          .orderBy('createdAt', descending: true)
          .get();

      final contacts = querySnapshot.docs.map((doc) {
        return MyCircleContactModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      developer.log('MyCircleRemoteDataSource: Found ${contacts.length} contacts', name: 'VoloMyCircle');
      return contacts;
    } catch (e) {
      developer.log('MyCircleRemoteDataSource: Error fetching contacts: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  @override
  Future<String> addContact(MyCircleContactForm contact) async {
    try {
      developer.log('MyCircleRemoteDataSource: Adding new contact: ${contact.name}', name: 'VoloMyCircle');
      
      // Check if contact already exists
      final exists = await contactExists(contact.whatsappNumber);
      if (exists) {
        throw Exception('A contact with this WhatsApp number already exists in your circle');
      }

      final contactData = {
        'name': contact.name.trim(),
        'whatsappNumber': contact.whatsappNumber.trim(),
        'timezone': contact.timezone,
        'language': contact.language,
      };

      final docRef = await _myCircleCollection.add(contactData);
      
      developer.log('MyCircleRemoteDataSource: Contact added with ID: ${docRef.id}', name: 'VoloMyCircle');
      return docRef.id;
    } catch (e) {
      developer.log('MyCircleRemoteDataSource: Error adding contact: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  @override
  Future<void> updateContact(String contactId, MyCircleContactForm contact) async {
    try {
      developer.log('MyCircleRemoteDataSource: Updating contact: $contactId', name: 'VoloMyCircle');
      
      // Check if contact exists
      final doc = await _myCircleCollection.doc(contactId).get();
      if (!doc.exists) {
        throw Exception('Contact not found');
      }

      // Check if new WhatsApp number conflicts with existing contact
      final existingContact = doc.data() as Map<String, dynamic>;
      if (existingContact['whatsappNumber'] != contact.whatsappNumber) {
        final exists = await contactExists(contact.whatsappNumber);
        if (exists) {
          throw Exception('A contact with this WhatsApp number already exists in your circle');
        }
      }

      final updates = {
        'name': contact.name.trim(),
        'whatsappNumber': contact.whatsappNumber.trim(),
        'timezone': contact.timezone,
        'language': contact.language,
      };

      await _myCircleCollection.doc(contactId).update(updates);
      
      developer.log('MyCircleRemoteDataSource: Contact updated successfully', name: 'VoloMyCircle');
    } catch (e) {
      developer.log('MyCircleRemoteDataSource: Error updating contact: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    try {
      developer.log('MyCircleRemoteDataSource: Deleting contact: $contactId', name: 'VoloMyCircle');
      
      await _myCircleCollection.doc(contactId).delete();
      
      developer.log('MyCircleRemoteDataSource: Contact deleted successfully', name: 'VoloMyCircle');
    } catch (e) {
      developer.log('MyCircleRemoteDataSource: Error deleting contact: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }



  @override
  Future<bool> contactExists(String whatsappNumber) async {
    try {
      final querySnapshot = await _myCircleCollection
          .where('whatsappNumber', isEqualTo: whatsappNumber.trim())
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      developer.log('MyCircleRemoteDataSource: Error checking contact existence: $e', name: 'VoloMyCircle');
      return false;
    }
  }
}
