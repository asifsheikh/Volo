import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../features/my_circle/data/models/my_circle_contact_model.dart';
import '../features/my_circle/domain/entities/my_circle_contact.dart';

/// Service for managing My Circle contacts in Firestore
class MyCircleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Get My Circle collection reference for current user
  static CollectionReference<Map<String, dynamic>> _getMyCircleCollection() {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('myCircle');
  }

  /// Get all contacts from user's My Circle
  static Future<List<MyCircleContactModel>> getMyCircleContacts() async {
    try {
      developer.log('MyCircleService: Fetching My Circle contacts', name: 'VoloMyCircle');
      
      final querySnapshot = await _getMyCircleCollection()
          .orderBy('createdAt', descending: true)
          .get();

      final contacts = querySnapshot.docs.map((doc) {
        return MyCircleContactModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      developer.log('MyCircleService: Found ${contacts.length} contacts', name: 'VoloMyCircle');
      return contacts;
    } catch (e) {
      developer.log('MyCircleService: Error fetching contacts: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  /// Add a new contact to My Circle
  static Future<String> addContact(MyCircleContactForm contact) async {
    try {
      developer.log('MyCircleService: Adding new contact: ${contact.name}', name: 'VoloMyCircle');
      
      // Check if contact already exists
      final exists = await contactExists(contact.whatsappNumber);
      if (exists) {
        throw Exception('A contact with this WhatsApp number already exists in your circle');
      }

      final now = DateTime.now();
      final contactData = {
        'name': contact.name.trim(),
        'whatsappNumber': contact.whatsappNumber.trim(),
        'timezone': contact.timezone,
        'language': contact.language,
        'isActive': true,
        'createdAt': now,
        'updatedAt': now,
      };

      final docRef = await _getMyCircleCollection().add(contactData);
      
      developer.log('MyCircleService: Contact added with ID: ${docRef.id}', name: 'VoloMyCircle');
      return docRef.id;
    } catch (e) {
      developer.log('MyCircleService: Error adding contact: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  /// Update an existing contact
  static Future<void> updateContact(String contactId, MyCircleContactForm contact) async {
    try {
      developer.log('MyCircleService: Updating contact: $contactId', name: 'VoloMyCircle');
      
      // Check if contact exists
      final doc = await _getMyCircleCollection().doc(contactId).get();
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
        'updatedAt': DateTime.now(),
      };

      await _getMyCircleCollection().doc(contactId).update(updates);
      
      developer.log('MyCircleService: Contact updated successfully', name: 'VoloMyCircle');
    } catch (e) {
      developer.log('MyCircleService: Error updating contact: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  /// Delete a contact from My Circle
  static Future<void> deleteContact(String contactId) async {
    try {
      developer.log('MyCircleService: Deleting contact: $contactId', name: 'VoloMyCircle');
      
      await _getMyCircleCollection().doc(contactId).delete();
      
      developer.log('MyCircleService: Contact deleted successfully', name: 'VoloMyCircle');
    } catch (e) {
      developer.log('MyCircleService: Error deleting contact: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  /// Toggle contact active status
  static Future<void> toggleContactStatus(String contactId, bool isActive) async {
    try {
      developer.log('MyCircleService: Toggling contact status: $contactId to $isActive', name: 'VoloMyCircle');
      
      await _getMyCircleCollection().doc(contactId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now(),
      });
      
      developer.log('MyCircleService: Contact status updated successfully', name: 'VoloMyCircle');
    } catch (e) {
      developer.log('MyCircleService: Error toggling contact status: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  /// Check if a contact exists by WhatsApp number
  static Future<bool> contactExists(String whatsappNumber) async {
    try {
      final querySnapshot = await _getMyCircleCollection()
          .where('whatsappNumber', isEqualTo: whatsappNumber.trim())
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      developer.log('MyCircleService: Error checking contact existence: $e', name: 'VoloMyCircle');
      return false;
    }
  }

  /// Get active contacts only
  static Future<List<MyCircleContactModel>> getActiveContacts() async {
    try {
      final allContacts = await getMyCircleContacts();
      return allContacts.where((contact) => contact.isActive).toList();
    } catch (e) {
      developer.log('MyCircleService: Error getting active contacts: $e', name: 'VoloMyCircle');
      rethrow;
    }
  }

  /// Get contact by ID
  static Future<MyCircleContactModel?> getContactById(String contactId) async {
    try {
      final doc = await _getMyCircleCollection().doc(contactId).get();
      if (doc.exists) {
        return MyCircleContactModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      developer.log('MyCircleService: Error getting contact by ID: $e', name: 'VoloMyCircle');
      return null;
    }
  }
}
