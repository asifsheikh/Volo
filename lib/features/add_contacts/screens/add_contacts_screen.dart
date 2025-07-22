import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../features/flight_confirmation/screens/confirmation_screen.dart';
import '../../../features/flight_confirmation/models/confirmation_args.dart';
import '../widgets/contact_picker_dialog.dart';
import '../models/contact_model.dart';
import '../../../services/trip_service.dart';
import '../../../widgets/loading_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

// Arguments for AddContactsScreen
class AddContactsScreenArgs {
  final dynamic selectedFlight; // Replace with your Flight model
  final String departureCity;
  final String departureAirportCode;
  final String departureImage;
  final String departureThumbnail;
  final String arrivalCity;
  final String arrivalAirportCode;
  final String arrivalImage;
  final String arrivalThumbnail;
  
  AddContactsScreenArgs({
    required this.selectedFlight,
    required this.departureCity,
    required this.departureAirportCode,
    required this.departureImage,
    required this.departureThumbnail,
    required this.arrivalCity,
    required this.arrivalAirportCode,
    required this.arrivalImage,
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
  bool _enableNotifications = false; // Track notification preference
  bool _showFlightUpdates = false; // Track expandable card state

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

  /// Save trip to Firestore and navigate to confirmation screen
  Future<void> _saveTripAndContinue() async {
    try {
      // Get current user ID
      final userId = TripService.getCurrentUserId();
      if (userId == null) {
        _showErrorSnackBar('User not authenticated. Please login again.');
        return;
      }

      // Show loading dialog
      await LoadingDialog.show(
        context: context,
        message: 'Saving your trip...',
      );

      // Create trip from flight option and contacts
      final trip = TripService.createTripFromFlightOption(
        flightOption: widget.args.selectedFlight,
        contacts: _selectedContacts,
        userNotifications: _enableNotifications,
        departureCity: widget.args.departureCity,
        arrivalCity: widget.args.arrivalCity,
      );

      // Save trip to Firestore
      await TripService.saveTrip(
        trip: trip,
        userId: userId,
      );

      // Hide loading dialog
      LoadingDialog.hide(context);

      // Show success message briefly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip saved successfully!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to confirmation screen
      _navigateToConfirmationScreen();

    } catch (e) {
      // Hide loading dialog if it's still showing
      LoadingDialog.hide(context);
      
      // Show error message
      _showErrorSnackBar('Failed to save trip: ${e.toString()}');
    }
  }

  /// Navigate to confirmation screen
  void _navigateToConfirmationScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          args: ConfirmationArgs(
            fromCity: widget.args.departureCity,
            toCity: widget.args.arrivalCity,
            contactNames: _selectedContacts.map((c) => c.name).toList(),
            contactAvatars: _selectedContacts.map((c) => c.avatar ?? '').toList(),
            departureAirportCode: widget.args.departureAirportCode,
            departureImage: widget.args.departureImage,
            departureThumbnail: widget.args.departureThumbnail,
            arrivalAirportCode: widget.args.arrivalAirportCode,
            arrivalImage: widget.args.arrivalImage,
            arrivalThumbnail: widget.args.arrivalThumbnail,
            enableNotifications: _enableNotifications,
          ),
        ),
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.4; // 40% of screen height
    
    // Check if at least one action is taken
    final bool hasActionTaken = _enableNotifications || _selectedContacts.isNotEmpty;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: CustomScrollView(
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
                                    image: NetworkImage(args.departureImage.isNotEmpty 
                                        ? args.departureImage 
                                        : args.departureThumbnail.isNotEmpty
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
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.flight_takeoff,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          args.departureAirportCode.toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 32,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
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
                                    image: NetworkImage(args.arrivalImage.isNotEmpty 
                                        ? args.arrivalImage 
                                        : args.arrivalThumbnail.isNotEmpty
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
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.flight_land,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          args.arrivalAirportCode.toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 32,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
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
                        
                        // Your Own Updates Section
                        const Text(
                          'Your Own Updates',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Checkbox for own updates
                        Row(
                          children: [
                            Checkbox(
                              value: _enableNotifications,
                              onChanged: (value) {
                                setState(() {
                                  _enableNotifications = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF008080),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Send me updates about this flight',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "I'll receive all flight updates and notifications for this journey.",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Share With Close Ones Section
                        const Text(
                          'Share With Close Ones',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        const Text(
                          'Notify my close ones (via WhatsApp)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Compact Add Contact Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _pickContact,
                            icon: const Icon(Icons.add, color: Color(0xFF008080), size: 20),
                            label: const Text(
                              'Add Contact',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF008080),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF008080), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        
                        // Selected Contacts
                        if (_selectedContacts.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          
                          ..._selectedContacts.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final ContactModel contact = entry.value;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                children: [
                                  // Avatar with emoji
                                  Container(
                                    width: 32,
                                    height: 32,
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
                                          fontSize: 14,
                                          color: Color(0xFF008080),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Contact Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.name,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        if (contact.phoneNumber != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            contact.phoneNumber!,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
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
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Simple Disclaimer
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF6B7280),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'What flight updates do we send?',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Description
                        Text(
                          'You and your selected contacts will be notified if there\'s a schedule change, gate change, delay, or cancellation.',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                        
                        // Bottom padding to account for the pinned button
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Pinned Continue Button at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: hasActionTaken ? () => _saveTripAndContinue() : null,
                style: ElevatedButton.styleFrom(
                                      backgroundColor: hasActionTaken ? const Color(0xFF059393) : const Color(0xFF9CA3AF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: hasActionTaken ? 10 : 0,
                  shadowColor: hasActionTaken ? Colors.black.withOpacity(0.1) : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check, 
                      color: hasActionTaken ? Colors.white : const Color(0xFF6B7280), 
                      size: 20
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: hasActionTaken ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 