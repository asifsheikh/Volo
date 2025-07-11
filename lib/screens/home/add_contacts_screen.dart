import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:math' as math;
import 'city_connection_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'confirmation_screen.dart';
import '../../widgets/contact_picker_dialog.dart';

// Data model for a contact
class ContactModel {
  final String name;
  final String? avatar; // URL or asset
  final String? platform; // e.g., 'WhatsApp'
  final String? phoneNumber;
  ContactModel({
    required this.name,
    this.avatar,
    this.platform,
    this.phoneNumber,
  });
}

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
            platform: 'WhatsApp', // For now, assume WhatsApp
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
            fontSize: 24,
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
                    // Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: CityConnectionHeader(
                        fromCity: args.departureCity,
                        fromThumbnail: args.departureThumbnail,
                        toCity: args.arrivalCity,
                        toThumbnail: args.arrivalThumbnail,
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          // Title
                          const Text(
                            'Who should we notify?',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Subtitle
                          const Text(
                            'Select the people you want to keep updated about your flight status.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Selected contacts
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Selected contacts',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    if (_selectedContacts.isNotEmpty)
                                      Text(
                                        '${_selectedContacts.length} contact${_selectedContacts.length == 1 ? '' : 's'}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_selectedContacts.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No contacts selected',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Add WhatsApp contact so they can receive flight updates',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  ..._selectedContacts.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final contact = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _buildContactTile(contact, i),
                                    );
                                  }).toList(),
                                // Add Contact button
                                GestureDetector(
                                  onTap: _pickContact,
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Color(0xFFE5E7EB)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add, color: Color(0xFF1F2937)),
                                        SizedBox(width: 8),
                                        Text(
                                          'WhatsApp contact',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Center(
                                  child: Text(
                                    'Select WhatsApp contact to receive live flight updates',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20), // Add bottom padding for scroll
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky confirm button
            Container(
              width: double.infinity,
              color: const Color(0xFFE5E7EB),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: 350,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedContacts.isEmpty ? null : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ConfirmationScreen(
                          fromCity: args.departureCity,
                          toCity: args.arrivalCity,
                          contactNames: _selectedContacts.map((c) => c.name).toList(),
                          contactAvatars: _selectedContacts.map((c) => 'initials').toList(), // Using initials instead of avatars
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedContacts.isEmpty 
                        ? const Color(0xFF9CA3AF) 
                        : const Color(0xFF1F2937),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _selectedContacts.isEmpty ? 0 : 10,
                    shadowColor: Colors.black.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 22),
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

  Widget _buildContactTile(ContactModel contact, int index) {
    // Generate initials from contact name
    String getInitials(String name) {
      final nameParts = name.trim().split(' ');
      if (nameParts.isEmpty) return '?';
      if (nameParts.length == 1) return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '?';
      return '${nameParts[0][0].toUpperCase()}${nameParts.last[0].toUpperCase()}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF1F2937),
          child: Text(
            getInitials(contact.name),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: contact.phoneNumber != null
            ? Text(
                contact.phoneNumber!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              )
            : null,
        trailing: InkWell(
          onTap: () => _removeContact(index),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 24),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 0,
      ),
    );
  }
}

// Custom painter for spiral dotted line
class _SpiralDottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashLength = 6.0;
    const gap = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    double angle = 0;
    double radius = 10;
    while (radius < size.width / 2) {
      final x1 = center.dx + radius * math.cos(angle);
      final y1 = center.dy + radius * math.sin(angle);
      angle += dashLength / radius;
      final x2 = center.dx + radius * math.cos(angle);
      final y2 = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      angle += gap / radius;
      radius += 0.7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 