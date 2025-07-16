import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../screens/home/city_connection_header.dart';
import '../../../features/flight_confirmation/screens/confirmation_screen.dart';
import '../../../features/flight_confirmation/models/confirmation_args.dart';
import '../widgets/contact_picker_dialog.dart';
import '../models/contact_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.4; // 40% of screen height
    
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar for the banner with fade effect
          SliverAppBar(
            expandedHeight: bannerHeight,
            floating: false,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background Images
                  Row(
                    children: [
                      // Departing City (Left 50%)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(args.departureThumbnail.isNotEmpty 
                                  ? args.departureThumbnail 
                                  : 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&h=400&fit=crop'),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Fallback to gradient
                              },
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.flight_takeoff,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Arriving City (Right 50%)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(args.arrivalThumbnail.isNotEmpty 
                                  ? args.arrivalThumbnail 
                                  : 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400&h=400&fit=crop'),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Fallback to gradient
                              },
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.flight_land,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Back button and title row (top left)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        // Circular back button
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6B7280), size: 16),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Left-aligned title
                        Text(
                          'Add Contacts',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // City names at bottom of banner
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          '${args.departureCity.toUpperCase()} → ${args.arrivalCity.toUpperCase()}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 120,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.8),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content below banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                    
                  // Bottom Button - Only show when contacts are selected
                  if (_selectedContacts.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: SizedBox(
                        width: 350,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to confirmation screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ConfirmationScreen(
                                  args: ConfirmationArgs(
                                    fromCity: args.departureCity,
                                    toCity: args.arrivalCity,
                                    contactNames: _selectedContacts.map((c) => c.name).toList(),
                                    contactAvatars: _selectedContacts.map((c) => c.avatar ?? '').toList(),
                                    departureThumbnail: args.departureThumbnail,
                                    arrivalThumbnail: args.arrivalThumbnail,
                                  ),
                                ),
                              ),
                            );
                          },
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 