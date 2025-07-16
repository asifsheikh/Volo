import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../screens/home/city_connection_header.dart';
import '../../../features/flight_confirmation/screens/confirmation_screen.dart';
import '../../../features/flight_confirmation/models/confirmation_args.dart';
import '../widgets/contact_picker_dialog.dart';
import '../models/contact_model.dart';

// Arguments for AddContactsScreen
class AddContactsScreenArgs {
  final dynamic selectedFlight; // Replace with your Flight model
  final String departureCity;
  final String departureThumbnail;
  final String arrivalCity;
  final String arrivalThumbnail;
  
  AddContactsScreenArgs({
    required this.selectedFlight,
    required this.departureCity,
    required this.departureThumbnail,
    required this.arrivalCity,
    required this.arrivalThumbnail,
  });
}

class AddContactsScreen extends StatefulWidget {
  final AddContactsScreenArgs args;
  const AddContactsScreen({Key? key, required this.args}) : super(key: key);

  @override
  State<AddContactsScreen> createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends State<AddContactsScreen> {
  final List<ContactModel> _selectedContacts = [];

  Future<void> _pickContact() async {
    try {
      // Request permission to access contacts
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        // Show permission denied message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('We need access to your contacts to add people to notify.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get all contacts with phone numbers
      final List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Filter contacts that have phone numbers
      final contactsWithPhones = contacts.where((contact) => contact.phones.isNotEmpty).toList();

      if (contactsWithPhones.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No contacts with phone numbers found in your device.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get list of already selected phone numbers
      final selectedPhoneNumbers = _selectedContacts
          .where((contact) => contact.phoneNumber != null)
          .map((contact) => contact.phoneNumber!)
          .toList();

      // Show modern contact picker dialog
      final Contact? selectedContact = await showDialog<Contact>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ContactPickerDialog(
            contacts: contactsWithPhones,
            selectedPhoneNumbers: selectedPhoneNumbers,
          );
        },
      );

      if (selectedContact != null) {
        final phoneNumber = selectedContact.phones.first.number;
        final contactName = selectedContact.displayName.isNotEmpty 
            ? selectedContact.displayName 
            : (selectedContact.name.first.isNotEmpty || selectedContact.name.last.isNotEmpty)
                ? '${selectedContact.name.first} ${selectedContact.name.last}'.trim()
                : 'Unknown Contact';
        
        // Check if contact already exists
        final existingContact = _selectedContacts.any((c) => 
            c.phoneNumber == phoneNumber || c.name == contactName);
        
        if (existingContact) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This contact is already added to your list.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        setState(() {
          _selectedContacts.add(ContactModel(
            name: contactName,
            phoneNumber: phoneNumber,
          ));
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${contactName} to your notification list.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to access contacts. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeContact(int index) {
    setState(() {
      _selectedContacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E7EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Contacts',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Journey Banner Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CityConnectionHeader(
                        fromCity: args.departureCity,
                        fromThumbnail: args.departureThumbnail,
                        toCity: args.arrivalCity,
                        toThumbnail: args.arrivalThumbnail,
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          
                          // Title
                          const Text(
                            'Who should we notify?',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          
                          // Subtitle
                          const Text(
                            'Add your loved ones\' WhatsApp contacts',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),
                          
                          // Add Contact Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _pickContact,
                              icon: const Icon(Icons.add, color: Color(0xFF374151), size: 24),
                              label: const Text(
                                'Add Contact',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          
                          // Selected Contacts List
                          if (_selectedContacts.isNotEmpty) ...[
                            const Text(
                              'Selected Contacts',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            ..._selectedContacts.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final ContactModel contact = entry.value;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF008080).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Color(0xFF008080),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Contact Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contact.name,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                          if (contact.phoneNumber != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              contact.phoneNumber!,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],

                                        ],
                                      ),
                                    ),
                                    
                                    // Remove Button
                                    IconButton(
                                      onPressed: () => _removeContact(index),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Color(0xFFDC2626),
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Button
            Container(
              width: double.infinity,
              color: const Color(0xFFE5E7EB),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: 350,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedContacts.isNotEmpty
                      ? () {
                          // Navigate to confirmation screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConfirmationScreen(
                                args: ConfirmationArgs(
                                  fromCity: args.departureCity,
                                  toCity: args.arrivalCity,
                                  contactNames: _selectedContacts.map((c) => c.name).toList(),
                                  contactAvatars: _selectedContacts.map((c) => c.avatar ?? '').toList(),
                                ),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Continue (${_selectedContacts.length})',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 